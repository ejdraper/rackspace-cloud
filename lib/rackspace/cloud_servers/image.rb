class Rackspace::CloudServers::Image < Rackspace::CloudServers::Base
  attr_accessor :name, :serverId, :updated, :created, :status, :progress
  
  # Updating isn't allowed for images
  def update
    false
  end
end
