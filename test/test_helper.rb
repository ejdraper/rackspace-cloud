require File.join(File.dirname(__FILE__), "..", "lib", "rackspace-cloud")
require "rubygems"
require "active_support/test_case"
gem "mocha"
require "mocha"
gem "thoughtbot-shoulda"
require "shoulda"

ActiveSupport::Inflector.inflections do |inflect|
   inflect.irregular 'base', 'bases'
end

class ActiveSupport::TestCase
  # This sets up the expectation for the API version query
  def expects_versions_response
    RestClient.expects(:get).with("#{Rackspace::Connection::VERSION_URL}/.json", {:accept => "application/json", :content_type => "application/json"}).returns({"versions" => [{"id" => "v1.1", "status" => "BETA"}, {"id" => "v1.0", "status" => "CURRENT"}]}.to_json)
  end
  
  # This sets up the expectations for authenticating against the API
  def expects_authentication(auth_token = "123456789")
    response = RestClient::Response.new "", nil
    response.expects(:headers).returns({:x_auth_token => auth_token, :x_storage_url => "http://test/storage", :x_server_management_url => "http://test/servers", :x_cdn_management_url => "http://test/content"})
    RestClient::Request.expects(:execute).with(:method => :get, :url => "#{Rackspace::Connection::AUTH_URL}/v1.0", :headers => {"X-Auth-User" => "test_user", "X-Auth-Key" => "test_key"}, :raw_response => true).returns(response)
  end
  
  # This returns default headers used for expectations
  def default_headers
    {"X-Auth-Token" => "123456789", :accept => "application/json", :content_type => "application/json"}
  end
  
  # Helper method for building GET expectations
  def expects_get(url, headers = {})
    RestClient.expects(:get).with(url, default_headers.merge(headers))
  end
  
  # Helper method for building POST expectations
  def expects_post(url, payload, headers = {})
    RestClient.expects(:post).with(url, payload.to_json, default_headers.merge(headers))
  end
  
  # Helper method for building PUT expectations
  def expects_put(url, payload, headers = {})
    RestClient.expects(:put).with(url, payload.to_json, default_headers.merge(headers))
  end
  
  # Helper method for building DELETE expectations
  def expects_delete(url, headers = {})
    RestClient.expects(:delete).with(url, default_headers.merge(headers))
  end
  
  # This sets up the necessary values to mock the authentication response as if we had authenticated
  def mock_auth_response(auth_token = "123456789")
    Rackspace::Connection.send(:instance_variable_set, "@auth_response", {:auth_token => auth_token, :storage_url => "http://test/storage", :server_management_url => "http://test/servers", :cdn_management_url => "http://test/content"})
    mock_api_init
  end
  
  # This sets up the necessary values to mock the configuration as if we had initialized
  def mock_api_init
    Rackspace::Connection.send(:instance_variable_set, "@user", "test_user")
    Rackspace::Connection.send(:instance_variable_set, "@key", "test_key")
    Rackspace::Connection.send(:instance_variable_set, "@version", "v1.0")
    Rackspace::Connection.send(:instance_variable_set, "@initialized", true)
  end
end
