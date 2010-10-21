require 'rubygems'
require 'active_support'
require 'puppet/application'

module Puppet::Lastcheck
  module Puppet::Lastcheck::Tests
    def self.included(klass)
      klass.extend ClassMethods
    end
    def self.tests
      @tests ||= {}
    end
    module ClassMethods
      def add_test(name, options={})
        include "Puppet::Lastcheck::Tests::#{name.to_s.classify}".constantize
        Puppet::Lastcheck::Tests.tests[name] = options
        attr_accessor "ignore_#{name}".to_sym
        option("--ignore-#{name.to_s.gsub(/_/,'-')}") do
          self.send("ignore_#{name}=", true)
        end
      end
    end
    module Util
      def facts_hosts
        return @facts_hosts if @facts_hosts
        require 'puppet/indirector/facts/yaml'
        @facts_hopsts = Puppet::Node::Facts.search("*").collect do |node|
          { :hostname => node.name, :expired => node.expired?, :timestamp => node.values[:_timestamp], :expiration => node.expiration }
        end
      end
    end
  end
end

module Puppet::Lastcheck::Tests::NoFact
  def analyze_no_facts
    signed_hosts.each{|host| add_failed_host(host,"No facts available") unless facts_hosts.any?{|fhost| fhost[:hostname] == host } }
  end
  def setup_no_facts
    Puppet::SSL::Host.ca_location = :only
  end

  private
  def signed_hosts
    ca.list
  end

  def ca
    @ca ||= Puppet::SSL::CertificateAuthority.new
  end
end

module Puppet::Lastcheck::Tests::ExpiredFact
  include Puppet::Lastcheck::Tests::Util
  def analyze_expired_facts
      facts_hosts.each{|host| add_failed_host(host[:hostname],"Expired at #{host[:expiration]}") if host[:expired] }
  end
end
module Puppet::Lastcheck::Tests::TimedOutFact
  include Puppet::Lastcheck::Tests::Util
  def analyze_timed_out_facts
    require 'time'
    facts_hosts.each{|host| add_failed_host(host[:hostname], "Last facts save at #{host[:timestamp]}") if Time.parse(host[:timestamp]) < (Time.now - @timeout) }
  end

  def setup_timed_out_facts
    if @timeout
      ignore_expired_facts ||= true
    end
  end
end
module Puppet::Lastcheck::Tests::Storedconfig
  def analyze_storedconfigs
    storedconfigs_hosts.each do |host|
      if !facts_hosts.any?{|fact_host| fact_host[:hostname] == host.name }
        add_failed_host(host.name, "In storedconfigs but no facts available!")
      elsif host.updated_at < (Time.now - @timeout)
        add_failed_host(host.name, "Last update in storedconfigs at #{host.updated_at}")
      end
    end
  end

  private
  def storedconfigs_hosts
    return @storedconfigs_hosts if @storedconfigs_hosts
    Puppet::Rails.connect
    @storedconfigs_hosts = Puppet::Rails::Host.all
  end
end
class Puppet::Application::Lastcheck < Puppet::Application

  should_parse_config
  run_mode :master

  include Puppet::Lastcheck::Tests
  add_test :no_facts
  add_test :expired_facts, :ignore_by_default => true
  add_test :timed_out_facts
  add_test :storedconfigs

  option("--timeout TIMEOUT") do |v|
    @timeout = v.to_i
  end

  def main
    Puppet::Lastcheck::Tests.tests.keys.each do |test|
        self.send("analyze_#{test}") unless self.send("ignore_#{test}")
    end
    print unless @failing_hosts.empty?
  end

  def setup
    exit(Puppet.settings.print_configs ? 0 : 1) if Puppet.settings.print_configs?

    Puppet::Util::Log.newdestination :console
    Puppet::Node::Facts.terminus_class = :yaml

    Puppet::Lastcheck::Tests.tests.keys.each do |test|
      self.send("ignore_#{test}=", Puppet::Lastcheck::Tests.tests[test][:ignore_by_default]||false) unless self.send("ignore_#{test}")
      self.send("setup_#{test}") if self.respond_to?("setup_#{test}")
    end

    @failing_hosts = {}
    unless @timeout 
      @timeout = Puppet[:runinterval]
    end
  end

  private
  def print
    puts 'The following hosts are out of date:'
    puts '------------------------------------'
    @failing_hosts.keys.each{ |host| puts "#{host} - Reason: #{@failing_hosts[host][:reason]}" }
  end

  def add_failed_host(hostname,reason)
    @failing_hosts[hostname] = { :reason => reason } unless @failing_hosts[hostname]
  end

end  
