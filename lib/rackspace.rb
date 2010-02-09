$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
gem "activesupport"
require "active_support"
gem "rest-client"
require "rest_client"
gem "json"

module Rackspace
  VERSION = '0.5'
  
  module CloudServers
  end
end

require File.join(File.dirname(__FILE__), "rackspace", "exceptions")
require File.join(File.dirname(__FILE__), "rackspace", "connection")
require File.join(File.dirname(__FILE__), "rackspace", "cloud_servers", "base")
require File.join(File.dirname(__FILE__), "rackspace", "cloud_servers", "server")
require File.join(File.dirname(__FILE__), "rackspace", "cloud_servers", "flavor")
require File.join(File.dirname(__FILE__), "rackspace", "cloud_servers", "image")
