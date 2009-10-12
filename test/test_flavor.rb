require File.join(File.dirname(__FILE__), "test_helper")

class Rackspace::CloudServers::FlavorTest < ActiveSupport::TestCase
  context "working with Rackspace::CloudServers::Flavor" do
    should "inherit from Rackspace::CloudServers::Base" do
      assert Rackspace::CloudServers::Flavor.ancestors.include?(Rackspace::CloudServers::Base)
    end
  end

  context "an instance of Rackspace::CloudServers::Flavor" do
    setup do
      @flavor = Rackspace::CloudServers::Flavor.new
    end
    
    [:id, :name, :ram, :disk].each do |attrib|
      should "respond to #{attrib}" do
        assert @flavor.respond_to?(attrib)
      end
    end
  end

  context "querying flavors" do
    should "build the right resource URL for the index" do
      mock_auth_response
      assert_equal "http://test/servers/flavors", Rackspace::CloudServers::Flavor.resource_url
    end

    should "build the right resource URL for the retrieval" do
      mock_auth_response
      assert_equal "http://test/servers/flavors/1", Rackspace::CloudServers::Flavor.resource_url(1)
    end
    
    should "make the right request for find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/flavors/detail.json")
      Rackspace::CloudServers::Flavor.find(:all)
    end

    should "make the right request for find and default to find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/flavors/detail.json")
      Rackspace::CloudServers::Flavor.find
    end

    should "make the right request for find(1)" do
      mock_auth_response
      expects_get("http://test/servers/flavors/1.json")
      Rackspace::CloudServers::Flavor.find(1)
    end

    should "return the right data for find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/flavors/detail.json").returns(find_all_response)
      result = Rackspace::CloudServers::Flavor.find(:all)
      assert_equal 2, result.length
      assert_equal Rackspace::CloudServers::Flavor, result.first.class
      assert_equal 1, result.first.id
      assert_equal Rackspace::CloudServers::Flavor, result.last.class
      assert_equal 2, result.last.id
    end

    should "return the right data for find(1)" do
      mock_auth_response
      expects_get("http://test/servers/flavors/1.json").returns(find_1_response)
      result = Rackspace::CloudServers::Flavor.find(1)
      assert_equal Rackspace::CloudServers::Flavor, result.class
      assert_equal 1, result.id
    end
  end

  context "creating a flavor" do
    should "return false as it's read-only" do
      assert_equal false, Rackspace::CloudServers::Flavor.new(:name => "test").save
    end
  end

  context "deleting a flavor" do
    should "return false as it's read-only" do
      assert_equal false, Rackspace::CloudServers::Flavor.new(:id => 1).destroy
    end
  end
  
  context "reloading a flavor instance" do
    should "not be allowed when it's a new record" do
      assert_equal false, Rackspace::CloudServers::Flavor.new.reload
    end
    
    should "make the GET request for the flavor" do
      mock_auth_response
      expects_get("http://test/servers/flavors/1.json").returns(find_1_response_reloaded)
      result = Rackspace::CloudServers::Flavor.new(:id => 1)
      updated = result.reload
      assert_equal 100, updated.disk
      assert_equal 100, result.disk
    end
  end
  
  def find_all_response
    { 
      "flavors" => [ 
                    { 
                      "id" => 1,
                      "name" => "256 MB Server",
                      "ram" => 256, 
                      "disk" => 10
                    }, 
                    { 
                      "id" => 2, 
                      "name" => "512 MB Server",
                      "ram" => 512, 
                      "disk" => 20
                    } 
                   ] 
    }.to_json
  end

  def find_1_response
    { 
      "flavor" => { 
                      "id" => 1,
                      "name" => "256 MB Server",
                      "ram" => 256, 
                      "disk" => 10
      }
    }.to_json
  end

  def find_1_response_reloaded
    { 
      "flavor" => { 
                      "id" => 1,
                      "name" => "256 MB Server",
                      "ram" => 256, 
                      "disk" => 100
      }
    }.to_json
  end
end
