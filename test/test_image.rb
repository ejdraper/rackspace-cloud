require File.join(File.dirname(__FILE__), "test_helper")

class Rackspace::CloudServers::ImageTest < ActiveSupport::TestCase
  context "working with Rackspace::CloudServers::Image" do
    should "inherit from Rackspace::CloudServers::Base" do
      assert Rackspace::CloudServers::Image.ancestors.include?(Rackspace::CloudServers::Base)
    end
  end

  context "an instance of Rackspace::CloudServers::Image" do
    setup do
      @image = Rackspace::CloudServers::Image.new
    end
    
    [:id, :name, :updated, :created, :status, :serverId, :progress].each do |attrib|
      should "respond to #{attrib}" do
        assert @image.respond_to?(attrib)
      end
    end
  end

  context "querying images" do
    should "build the right resource URL for the index" do
      mock_auth_response
      assert_equal "http://test/servers/images", Rackspace::CloudServers::Image.resource_url
    end

    should "build the right resource URL for the retrieval" do
      mock_auth_response
      assert_equal "http://test/servers/images/1", Rackspace::CloudServers::Image.resource_url(1)
    end
    
    should "make the right request for find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/images/detail.json")
      Rackspace::CloudServers::Image.find(:all)
    end

    should "make the right request for find and default to find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/images/detail.json")
      Rackspace::CloudServers::Image.find
    end

    should "make the right request for find(1)" do
      mock_auth_response
      expects_get("http://test/servers/images/1.json")
      Rackspace::CloudServers::Image.find(1)
    end

    should "return the right data for find(:all)" do
      mock_auth_response
      expects_get("http://test/servers/images/detail.json").returns(find_all_response)
      result = Rackspace::CloudServers::Image.find(:all)
      assert_equal 2, result.length
      assert_equal Rackspace::CloudServers::Image, result.first.class
      assert_equal 2, result.first.id
      assert_equal Rackspace::CloudServers::Image, result.last.class
      assert_equal 743, result.last.id
    end

    should "return the right data for find(2)" do
      mock_auth_response
      expects_get("http://test/servers/images/2.json").returns(find_2_response)
      result = Rackspace::CloudServers::Image.find(2)
      assert_equal Rackspace::CloudServers::Image, result.class
      assert_equal 2, result.id
    end
  end

  context "creating an image" do
    should "make the right POST request and return the values expected" do
      mock_auth_response
      expects_post("http://test/servers/images.json", {"image" => {"name" => "new-image-test", "serverId" => 1}}).returns(create_response)
      image = Rackspace::CloudServers::Image.create(:name => "new-image-test", :serverId => 1)
      assert_equal 22, image.id
      assert_equal "new-image-test", image.name
      assert_equal 1, image.serverId
      assert_equal "SAVING", image.status
      assert_equal 0, image.progress
    end
  end

  context "updating an image" do
    should "not be allowed" do
      assert_equal false, Rackspace::CloudServers::Image.new(:id => 1).update
    end
  end

  context "deleting a image" do
    should "make the DELETE request for the image" do
      mock_auth_response
      expects_delete("http://test/servers/images/1.json")
      assert_equal true, Rackspace::CloudServers::Image.new(:id => 1).destroy
    end
  end

  context "reloading an image instance" do
    should "not be allowed when it's a new record" do
      assert_equal false, Rackspace::CloudServers::Image.new.reload
    end
    
    should "make the GET request for the image" do
      mock_auth_response
      expects_get("http://test/servers/images/2.json").returns(find_2_response_reloaded)
      result = Rackspace::CloudServers::Image.new(:id => 2)
      updated = result.reload
      assert_equal 100, updated.progress
      assert_equal 100, result.progress
    end
  end

  def find_all_response
    { 
      "images" => [ 
                    { 
                     "id" => 2,
                     "name" => "CentOS 5.2",
                     "updated" => "2010-10-10T12:00:00Z", 
                     "created" => "2010-08-10T12:00:00Z", 
                     "status" => "ACTIVE"
                    }, 
                    { 
                     "id" => 743, 
                     "name" => "My Server Backup", 
                     "serverId" => 12, 
                     "updated" => "2010-10-10T12:00:00Z", 
                     "created" => "2010-08-10T12:00:00Z", 
                     "status" => "SAVING", 
                     "progress" => 80 
                   } 
                  ] 
    }.to_json
  end

  def find_2_response
    { 
      "image" => {
        "id" => 2,
        "name" => "CentOS 5.2",
        "serverId" => 12, 
        "updated" => "2010-10-10T12:00:00Z", 
        "created" => "2010-08-10T12:00:00Z", 
        "status" => "ACTIVE",
        "progress" => 80 
      }
    }.to_json
  end

  def find_2_response_reloaded
    { 
      "image" => {
        "id" => 2,
        "name" => "CentOS 5.2",
        "serverId" => 12, 
        "updated" => "2010-10-10T12:00:00Z", 
        "created" => "2010-08-10T12:00:00Z", 
        "status" => "ACTIVE",
        "progress" => 100
      }
    }.to_json
  end

  def create_response
    { 
      "image" =>
      { 
        "id" => 22, 
        "serverId" => 1,
        "name" => "new-image-test",
        "created" => "2010-10-10T12:00:00Z", 
        "status" => "SAVING", 
        "progress" => 0 
      }
    }.to_json
  end
end
