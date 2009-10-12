class Rackspace::CloudServers::Base
  attr_accessor :id
  
  # The resource can be established with a hash of parameters
  def initialize(attribs = {})
    set_attributes(attribs)
  end
  
  # This sets the relevant accessors using the specified attributes
  def set_attributes(attribs)
    attribs.each_pair do |key, value|
      self.send("#{key}=", value) if self.respond_to?("#{key}=")
    end
  end

  # This returns true if the record hasn't yet been persisted, false otherwise
  def new_record?
    self.id.nil?
  end
  
  # This creates the record if it is new, otherwise it attempts to update the record
  def save
    self.new_record? ? create : update
  end
  
  # This creates the new record using the API
  def create
    set_attributes(JSON.parse(Rackspace::Connection.post(self.class.resource_url, {self.class.resource.singularize => JSON.parse(self.to_json)}))[self.class.resource.singularize])
    true
  end
  
  # This updates the existing record using the API
  def update
    attribs = JSON.parse(self.to_json)
    unless self.attributes_for_update.nil?
      attribs.keys.each do |key|
        attribs.delete(key) unless self.attributes_for_update.include?(key.to_sym)
      end
    end
    Rackspace::Connection.put(self.class.resource_url(self.id), {self.class.resource.singularize => attribs})
    true
  end
  
  # This deletes the record using the API
  def destroy
    Rackspace::Connection.delete(self.class.resource_url(self.id))
    true
  end
  
  # These are the attributes used for the update operations
  # Empty array means no properties will be updated, but this can be overridden with
  # nil (all properties are updated), or an explicit array of properties that can be updated
  def attributes_for_update
    []
  end
  
  # This reloads the current object with the latest persisted data
  def reload
    return false if self.new_record?
    result = Rackspace::Connection.get(self.class.resource_url(self.id))
    return nil if result.to_s.blank?
    json = JSON.parse(result.to_s)
    self.set_attributes(json[self.class.resource.singularize])
    self
  end
  
  class << self
    # This returns the name of the resource, used for the API URLs
    def resource
      self.name.split("::").last.tableize
    end

    # This returns the resource URL
    def resource_url(id = nil)
      root = "#{Rackspace::Connection.server_management_url}/#{self.resource}"
      id.nil? ? root : "#{root}/#{id}"
    end
    
    # This returns all records for the resource
    def all
      self.find
    end
    
    # This returns the first record for the resource
    def first
      self.find(:first)
    end
    
    # This returns the last record for the resource
    def last
      self.find(:last)
    end

    # This finds all records for the resource, or a specific resource by ID
    def find(action = :all)
      result = case action
      when :all
        Rackspace::Connection.get "#{self.resource_url}/detail"
      when :first
        Rackspace::Connection.get "#{self.resource_url}/detail"
      when :last
        Rackspace::Connection.get "#{self.resource_url}/detail"
      else
        Rackspace::Connection.get self.resource_url(action)
      end
      return nil if result.to_s.blank?
      json = JSON.parse(result.to_s)
      case action
      when :all
        json[self.resource].collect { |h| self.new(h) }
      when :first
        json[self.resource].collect { |h| self.new(h) }.first
      when :last
        json[self.resource].collect { |h| self.new(h) }.last
      else
        self.new(json[self.resource.singularize])
      end
    end
    
    # This returns the amount of records for this resource
    def count
      records = self.all
      records.nil? ? 0 : records.length
    end
    
    # This creates and saves a resource with the specified attributes in one call
    def create(attribs = {})
      o = self.new(attribs)
      o.save
      o
    end
  end
end
