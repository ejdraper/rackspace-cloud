class Rackspace::CloudServers::Flavor < Rackspace::CloudServers::Base
  attr_accessor :name, :ram, :disk
  
  # Saving (create/update) isn't allowed for flavors
  def save
    false
  end
  
  # Deletion isn't allowed for flavors
  def destroy
    false
  end
end
