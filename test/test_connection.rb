require File.join(File.dirname(__FILE__), "test_helper")

class Rackspace::ConnectionTest < ActiveSupport::TestCase
  context "working with Rackspace::Connection" do
    should "have JSON as the default accept type" do
      assert_equal "application/json", Rackspace::Connection.default_headers[:accept]
    end

    should "have JSON as the default content type" do
      assert_equal "application/json", Rackspace::Connection.default_headers[:content_type]
    end
  end

  context "querying for API versions" do
    setup do
      expects_versions_response
    end
    
    should "receive the right arguments for the HTTP request" do
      Rackspace::Connection.versions
    end

    should "return the right data" do
      versions = Rackspace::Connection.versions
      assert_equal 2, versions.length
      assert_equal true, versions.include?("v1.1")
      assert_equal true, versions.include?("v1.0")
    end
  end

  context "initializing Rackspace::Connection with default version" do
    setup do
      expects_versions_response
      Rackspace::Connection.init "test_user", "test_key"
    end

    should "have set API user" do
      assert_equal "test_user", Rackspace::Connection.api_user
    end

    should "have set API key" do
      assert_equal "test_key", Rackspace::Connection.api_key
    end

    should "have set API version" do
      assert_equal "v1.0", Rackspace::Connection.api_version
    end
  end
  
  context "initializing Rackspace::Connection with specific version" do
    setup do
      expects_versions_response
      Rackspace::Connection.init "test_user", "test_key", "v1.1"
    end

    should "have set API user" do
      assert_equal "test_user", Rackspace::Connection.api_user
    end

    should "have set API key" do
      assert_equal "test_key", Rackspace::Connection.api_key
    end

    should "have set API version" do
      assert_equal "v1.1", Rackspace::Connection.api_version
    end
  end

  context "initializing Rackspace::Connection with invalid version" do
    setup do
      expects_versions_response
    end
    
    should "raise an exception" do
      assert_raise Rackspace::InvalidVersion do
        Rackspace::Connection.init "test_user", "test_key", "v1.2"
      end
    end
  end
  
  context "before authenticating with Rackspace a call to authentication info" do
    should "trigger an authentication first time ONLY (auth_response)" do
      Rackspace::Connection.instance_variable_set("@auth_response", nil)
      mock_api_init
      expects_authentication
      Rackspace::Connection.auth_response
      Rackspace::Connection.auth_response
    end
    
    should "call auth_response to find the right value (auth_token)" do
      response = mock
      response.expects(:[]).with(:auth_token).returns("123456789")
      Rackspace::Connection.expects(:auth_response).returns(response)
      token = Rackspace::Connection.auth_token
      assert_equal "123456789", token
    end

    should "call auth_response to find the right value (storage_url)" do
      response = mock
      response.expects(:[]).with(:storage_url).returns("http://test/storage")
      Rackspace::Connection.expects(:auth_response).returns(response)
      url = Rackspace::Connection.storage_url
      assert_equal "http://test/storage", url
    end

    should "call auth_response to find the right value (server_management_url)" do
      response = mock
      response.expects(:[]).with(:server_management_url).returns("http://test/servers")
      Rackspace::Connection.expects(:auth_response).returns(response)
      url = Rackspace::Connection.server_management_url
      assert_equal "http://test/servers", url
    end

    should "call auth_response to find the right value (cdn_management_url)" do
      response = mock
      response.expects(:[]).with(:cdn_management_url).returns("http://test/content")
      Rackspace::Connection.expects(:auth_response).returns(response)
      url = Rackspace::Connection.cdn_management_url
      assert_equal "http://test/content", url
    end
  end
  
  context "authenticating with Rackspace" do
    setup do
      mock_api_init
      expects_authentication
    end
    
    should "receive the right arguments for the HTTP request" do
      Rackspace::Connection.authenticate
    end

    should "return the important authentication details" do
      response = Rackspace::Connection.authenticate
      assert_equal Hash, response.class
      assert_equal 4, response.keys.length
      assert_equal "123456789", response[:auth_token]
      assert_equal "http://test/storage", response[:storage_url]
      assert_equal "http://test/servers", response[:server_management_url]
      assert_equal "http://test/content", response[:cdn_management_url]
    end
  end

  context "authenticating with Rackspace without initializing" do
    setup do
      Rackspace::Connection.send(:instance_variable_set, "@initialized", false)
    end
    
    should "raise an exception" do
      assert_raise Rackspace::NotInitialized do
        Rackspace::Connection.authenticate
      end
    end
  end

  context "making GET requests to Rackspace" do
    should "build the right GET request" do
      mock_auth_response "123456789"
      expects_get("http://test/url.json", {"X-TestHeader" => "testing"})
      Rackspace::Connection.get "http://test/url", {"X-TestHeader" => "testing"}
    end

    should "re-authenticate if it receives a 401 Unauthorized back" do
      mock_auth_response "123456789"
      expects_get("http://test/url.json").raises(RestClient::Unauthorized, "RestClient::Unauthorized")
      expects_authentication "234567891"
      expects_get("http://test/url.json", {"X-Auth-Token" => "234567891"})
      Rackspace::Connection.get "http://test/url"
    end
  end

  context "making POST requests to Rackspace" do
    should "build the right POST request" do
      mock_auth_response "123456789"
      expects_post("http://test/url.json", {:data1 => "test", :data2 => "test"}, {"X-TestHeader" => "testing"})
      Rackspace::Connection.post "http://test/url", {:data1 => "test", :data2 => "test"}, {"X-TestHeader" => "testing"}
    end

    should "re-authenticate if it receives a 401 Unauthorized back" do 
      mock_auth_response "123456789"
      expects_post("http://test/url.json", {:data1 => "test", :data2 => "test"}).raises(RestClient::Unauthorized, "RestClient::Unauthorized")
      expects_authentication "234567891"
      expects_post("http://test/url.json", {:data1 => "test", :data2 => "test"}, {"X-Auth-Token" => "234567891"})
      Rackspace::Connection.post "http://test/url", {:data1 => "test", :data2 => "test"}
    end
  end
  
  context "making PUT requests to Rackspace" do
    should "build the right PUT request" do
      mock_auth_response "123456789"
      expects_put("http://test/url.json", {:data1 => "test", :data2 => "test"}, {"X-TestHeader" => "testing"})
      Rackspace::Connection.put "http://test/url", {:data1 => "test", :data2 => "test"}, {"X-TestHeader" => "testing"}
    end

    should "re-authenticate if it receives a 401 Unauthorized back" do 
      mock_auth_response "123456789"
      expects_put("http://test/url.json", {:data1 => "test", :data2 => "test"}).raises(RestClient::Unauthorized, "RestClient::Unauthorized")
      expects_authentication "234567891"
      expects_put("http://test/url.json", {:data1 => "test", :data2 => "test"}, {"X-Auth-Token" => "234567891"})
      Rackspace::Connection.put "http://test/url", {:data1 => "test", :data2 => "test"}
    end
  end

  context "making DELETE requests to Rackspace" do
    should "build the right DELETE request" do
      mock_auth_response "123456789"
      expects_delete("http://test/url.json", {"X-TestHeader" => "testing"})
      Rackspace::Connection.delete "http://test/url", {"X-TestHeader" => "testing"}
    end

    should "re-authenticate if it receives a 401 Unauthorized back" do
      mock_auth_response "123456789"
      expects_delete("http://test/url.json").raises(RestClient::Unauthorized, "RestClient::Unauthorized")
      expects_authentication "234567891"
      expects_delete("http://test/url.json", {"X-Auth-Token" => "234567891"})
      Rackspace::Connection.delete "http://test/url"
    end
  end
end
