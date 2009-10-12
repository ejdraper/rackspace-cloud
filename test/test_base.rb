require File.join(File.dirname(__FILE__), "test_helper")

class Rackspace::CloudServers::BaseTest < ActiveSupport::TestCase
  context "querying a resource with Rackspace" do
    should "return the right resource name" do
      mock_auth_response
      assert_equal "bases", Rackspace::CloudServers::Base.resource
    end
    
    should "build the right resource URL for the index" do
      mock_auth_response
      assert_equal "http://test/servers/bases", Rackspace::CloudServers::Base.resource_url
    end

    should "build the right resource URL for the retrieval" do
      mock_auth_response
      assert_equal "http://test/servers/bases/1", Rackspace::CloudServers::Base.resource_url(1)
    end
    
    should "make the right request for find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/bases/detail.json")
      Rackspace::CloudServers::Base.find(:all)
    end

    should "make the right request for find(:first)" do
      mock_auth_response
      expects_get("http://test/servers/bases/detail.json")
      Rackspace::CloudServers::Base.find(:first)
    end

    should "make the right request for find(:last)" do
      mock_auth_response
      expects_get("http://test/servers/bases/detail.json")
      Rackspace::CloudServers::Base.find(:last)
    end

    should "make the right request for all and default to find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/bases/detail.json")
      Rackspace::CloudServers::Base.all
    end

    should "make the right request for count" do
      mock_auth_response
      expects_get("http://test/servers/bases/detail.json")
      assert_equal 0, Rackspace::CloudServers::Base.count
    end

    should "make the right request for first and default to find(:first)" do
      mock_auth_response
      expects_get("http://test/servers/bases/detail.json")
      Rackspace::CloudServers::Base.first
    end

    should "make the right request for last and default to find(:last)" do
      mock_auth_response
      expects_get("http://test/servers/bases/detail.json")
      Rackspace::CloudServers::Base.last
    end

    should "make the right request for find and default to find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/bases/detail.json")
      Rackspace::CloudServers::Base.find
    end

    should "make the right request for find(1)" do
      mock_auth_response
      expects_get("http://test/servers/bases/1.json")
      Rackspace::CloudServers::Base.find(1)
    end

    should "return the right data for find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/bases/detail.json").returns({"bases" => [{"id" => 1}, {"id" => 2}]}.to_json)
      result = Rackspace::CloudServers::Base.find(:all)
      assert_equal 2, result.length
      assert_equal Rackspace::CloudServers::Base, result.first.class
      assert_equal 1, result.first.id
      assert_equal false, result.first.new_record?
      assert_equal Rackspace::CloudServers::Base, result.last.class
      assert_equal 2, result.last.id
      assert_equal false, result.last.new_record?
    end

    should "return the right data for find(1)" do
      mock_auth_response
      expects_get("http://test/servers/bases/1.json").returns({"base" => {"id" => 1}}.to_json)
      result = Rackspace::CloudServers::Base.find(1)
      assert_equal Rackspace::CloudServers::Base, result.class
      assert_equal 1, result.id
      assert_equal false, result.new_record?
    end
  end

  context "creating a resource with Rackspace" do
    should "be a new record" do
      base = Rackspace::CloudServers::Base.new
      assert_equal true, base.new_record?
    end
    
    should "make the right POST request" do
      mock_auth_response
      expects_post("http://test/servers/bases.json", {"base" => {}}).returns({"base" => {"id" => 1}}.to_json)
      base = Rackspace::CloudServers::Base.new
      assert_equal true, base.save
      assert_equal 1, base.id
    end

    should "make the right POST request on a direct create call too" do
      mock_auth_response
      expects_post("http://test/servers/bases.json", {"base" => {}}).returns({"base" => {"id" => 1}}.to_json)
      base = Rackspace::CloudServers::Base.create
      assert_equal 1, base.id
    end
  end

  context "updating a resource with Rackspace" do
    should "make the right PUT request" do
      mock_auth_response
      expects_put("http://test/servers/bases/1.json", {"base" => {}})
      assert_equal true, Rackspace::CloudServers::Base.new(:id => 1).save
    end
  end
      
  context "deleting a resource with Rackspace" do
    should "make the right DELETE request" do
      mock_auth_response
      expects_delete("http://test/servers/bases/1.json")
      assert_equal true, Rackspace::CloudServers::Base.new(:id => 1).destroy
    end
  end

  context "reloading a resource with Rackspace" do
    should "not be allowed when it's a new record" do
      assert_equal false, Rackspace::CloudServers::Base.new.reload
    end
    
    should "make the GET request for the server" do
      mock_auth_response
      expects_get("http://test/servers/bases/1.json").returns({"base" => {"id" => 2}}.to_json)
      result = Rackspace::CloudServers::Base.new(:id => 1)
      updated = result.reload
      assert_equal 2, updated.id
      assert_equal 2, result.id
    end
  end
end
