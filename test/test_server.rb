require File.join(File.dirname(__FILE__), "test_helper")

class Rackspace::CloudServers::ServerTest < ActiveSupport::TestCase
  context "working with Rackspace::CloudServers::Server" do
    should "inherit from Rackspace::CloudServers::Base" do
      assert Rackspace::CloudServers::Server.ancestors.include?(Rackspace::CloudServers::Base)
    end
  end

  context "an instance of Rackspace::CloudServers::Server" do
    setup do
      @server = Rackspace::CloudServers::Server.new
    end
    
    [:id, :name, :imageId, :flavorId, :hostId, :status, :progress, :addresses, :metadata].each do |attrib|
      should "respond to #{attrib}" do
        assert @server.respond_to?(attrib)
      end
    end
  end

  context "querying servers" do
    should "build the right resource URL for the index" do
      mock_auth_response
      assert_equal "http://test/servers/servers", Rackspace::CloudServers::Server.resource_url
    end

    should "build the right resource URL for the retrieval" do
      mock_auth_response
      assert_equal "http://test/servers/servers/1", Rackspace::CloudServers::Server.resource_url(1)
    end
    
    should "make the right request for find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/servers/detail.json")
      Rackspace::CloudServers::Server.find(:all)
    end

    should "make the right request for find and default to find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/servers/detail.json")
      Rackspace::CloudServers::Server.find
    end

    should "make the right request for find(1)" do
      mock_auth_response
      expects_get("http://test/servers/servers/1.json")
      Rackspace::CloudServers::Server.find(1)
    end

    should "return the right data for find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/servers/detail.json").returns(find_all_response)
      result = Rackspace::CloudServers::Server.find(:all)
      assert_equal 2, result.length
      assert_equal Rackspace::CloudServers::Server, result.first.class
      assert_equal 1234, result.first.id
      assert_equal Rackspace::CloudServers::Server, result.last.class
      assert_equal 5678, result.last.id
    end

    should "return the right figure for count" do
      mock_auth_response
      expects_get("http://test/servers/servers/detail.json").returns(find_all_response)
      assert_equal 2, Rackspace::CloudServers::Server.count
    end

    should "return the right data for find(1)" do
      mock_auth_response
      expects_get("http://test/servers/servers/1234.json").returns(find_1234_response)
      result = Rackspace::CloudServers::Server.find(1234)
      assert_equal Rackspace::CloudServers::Server, result.class
      assert_equal 1234, result.id
    end
  end

  context "creating a server" do
    should "make the right POST request and return the expected values" do
      mock_auth_response
      expects_post("http://test/servers/servers.json", {"server" => {"name" => "new-server-test", "imageId" => 2, "flavorId" => 1}}).returns(create_response)
      server = Rackspace::CloudServers::Server.create(:name => "new-server-test", :imageId => 2, :flavorId => 1)
      assert_equal 1235, server.id
      assert_equal "new-server-test", server.name
      assert_equal 2, server.imageId
      assert_equal 1, server.flavorId
      assert_equal "e4d909c290d0fb1ca068ffaddf22cbd0", server.hostId
      assert_equal 0, server.progress
      assert_equal "BUILD", server.status
      assert_equal "GFf1j9aP", server.adminPass
      assert server.metadata.keys.include?("internal-server-name")
      assert_equal "test-1", server.metadata["internal-server-name"]
      assert server.addresses.keys.include?("public")
      assert server.addresses.keys.include?("private")
      assert_equal 1, server.addresses["public"].length
      assert_equal "67.23.10.138", server.addresses["public"].first
      assert_equal 1, server.addresses["private"].length
      assert_equal "10.176.42.19", server.addresses["private"].first
    end
  end

  context "updating a server" do
    should "make the PUT request for the server" do
      mock_auth_response
      expects_put("http://test/servers/servers/1.json", {"server" => {"name" => "test-name", :adminPass => "test-pass"}})
      assert_equal true, Rackspace::CloudServers::Server.new(:id => 1, :name => "test-name", :adminPass => "test-pass").save
    end
  end

  context "deleting a server" do
    should "make the DELETE request for the server" do
      mock_auth_response
      expects_delete("http://test/servers/servers/1.json")
      assert_equal true, Rackspace::CloudServers::Server.new(:id => 1).destroy
    end
  end

  context "reloading a server instance" do
    should "not be allowed when it's a new record" do
      assert_equal false, Rackspace::CloudServers::Server.new.reload
    end
    
    should "make the GET request for the server" do
      mock_auth_response
      expects_get("http://test/servers/servers/1234.json").returns(find_1234_response_reloaded)
      result = Rackspace::CloudServers::Server.new(:id => 1234)
      updated = result.reload
      assert_equal 100, updated.progress
      assert_equal 100, result.progress
    end
  end

  def find_all_response
    { 
      "servers" => [ 
                    { 
                      "id" => 1234, 
                      "name" => "sample-server", 
                      "imageId" => 2, 
                      "flavorId" => 1, 
                      "hostId" => "e4d909c290d0fb1ca068ffaddf22cbd0", 
                      "status" => "BUILD", 
                      "progress" => 60, 
                      "addresses" => { 
                        "public" => [ 
                                     "67.23.10.132", 
                                     "67.23.10.131" 
                                    ], 
                        "private" => [ 
                                      "10.176.42.16" 
                                     ] 
                     }, 
                      "metadata" => { 
                        "Server Label" => "Web Head 1", 
                        "Image Version" => "2.1" 
                      } 
                    }, 
                    { 
                      "id" => 5678, 
                      "name" => "sample-server2", 
                      "imageId" => 2, 
                      "flavorId" => 1, 
                      "hostId" => "9e107d9d372bb6826bd81d3542a419d6", 
                      "status" => "ACTIVE", 
                      "addresses" => { 
                        "public" => [ 
                                     "67.23.10.133" 
                                    ], 
                        "private" => [ 
                                      "10.176.42.17" 
                                     ] 
                      }, 
                      "metadata" => { 
                        "Server Label" => "DB 1" 
                      } 
                    } 
                   ] 
    }.to_json
  end

  def find_1234_response
    { 
      "server" => { 
        "id" => 1234, 
        "name" => "sample-server", 
        "imageId" => 2, 
        "flavorId" => 1, 
        "hostId" => "e4d909c290d0fb1ca068ffaddf22cbd0", 
        "status" => "BUILD", 
        "progress" => 60, 
        "addresses" => { 
          "public" => [ 
                       "67.23.10.132", 
                       "67.23.10.131" 
                      ], 
          "private" => [ 
                        "10.176.42.16" 
                       ] 
        }, 
        "metadata" => { 
          "Server Label" => "Web Head 1", 
          "Image Version" => "2.1" 
        } 
      }
    }.to_json
  end

  def find_1234_response_reloaded
    { 
      "server" => { 
        "id" => 1234, 
        "name" => "sample-server", 
        "imageId" => 2, 
        "flavorId" => 1, 
        "hostId" => "e4d909c290d0fb1ca068ffaddf22cbd0", 
        "status" => "BUILD", 
        "progress" => 100, 
        "addresses" => { 
          "public" => [ 
                       "67.23.10.132", 
                       "67.23.10.131" 
                      ], 
          "private" => [ 
                        "10.176.42.16" 
                       ] 
        }, 
        "metadata" => { 
          "Server Label" => "Web Head 1", 
          "Image Version" => "2.1" 
        } 
      }
    }.to_json
  end

  def create_response
    {
      "server" => {
        "id" => 1235,
        "name" => "new-server-test",
        "imageId" => 2,
        "flavorId" => 1,
        "hostId" => "e4d909c290d0fb1ca068ffaddf22cbd0",
        "progress" => 0,
        "status" => "BUILD",
        "adminPass" => "GFf1j9aP",
        "metadata" => {
          "internal-server-name" => "test-1"
        },
        "addresses" => {
          "public" => [
                       "67.23.10.138"
                      ],
          "private" => [
                        "10.176.42.19"
                       ]
        }
      }
    }.to_json
  end
end
