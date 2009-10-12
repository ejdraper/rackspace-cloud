class Rackspace::CloudServers::Server < Rackspace::CloudServers::Base
  attr_accessor :name, :imageId, :flavorId, :hostId, :status, :progress, :addresses, :metadata, :personality, :adminPass
  
  # Overriding the update attributes so that just name and adminPass are persisted on an update
  def attributes_for_update
    [:name, :adminPass]
  end
end
