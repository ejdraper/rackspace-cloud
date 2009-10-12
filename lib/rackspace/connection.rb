class Rackspace::Connection
  AUTH_URL = "https://auth.api.rackspacecloud.com"
  VERSION_URL = "https://servers.api.rackspacecloud.com"
  
  class << self
    # This initializes the Rackspace environment with the data necessary to make API calls
    def init(user, key, version = "v1.0")
      @user = user
      @key = key
      @version = version
      raise Rackspace::InvalidVersion unless self.versions.include?(version)
      @initialized = true
    end
    
    # This returns the API user being used for calls
    def api_user
      @user
    end
    
    # This returns the API key being used for calls
    def api_key
      @key
    end
    
    # This returns the API version being used for calls
    def api_version
      @version
    end
    
    # This returns whether or not we've been initialized yet
    def initialized?
      @initialized || false
    end
    
    # This authenticates with Rackspace and returns the information necessary to make subsequent authenticated calls to the API
    def authenticate
      raise Rackspace::NotInitialized unless self.initialized?
      headers = RestClient::Request.execute(:method => :get, :url => "#{AUTH_URL}/#{self.api_version}", :headers => {"X-Auth-User" => self.api_user, "X-Auth-Key" => self.api_key}, :raw_response => true).headers
      {:auth_token => headers[:x_auth_token], :storage_url => headers[:x_storage_url], :server_management_url => headers[:x_server_management_url], :cdn_management_url => headers[:x_cdn_management_url]}
    end

    # These are default headers we need to use on all requests
    def default_headers
      {:accept => "application/json", :content_type => "application/json"}
    end
    
    # This returns the available versions of the API
    def versions
      JSON.parse(RestClient.get("#{VERSION_URL}/.json", self.default_headers))["versions"].collect { |v| v["id"] }.uniq
    end
    
    # This caches the authentication response for subsequent usage
    def auth_response
      @auth_response ||= self.authenticate
    end
    
    # This is the auth token provided by Rackspace after a successful authentication
    def auth_token
      self.auth_response[:auth_token]
    end
    
    # This returns the root URL for Cloud Files API queries (not yet implemented)
    def storage_url
      self.auth_response[:storage_url]
    end
    
    # This returns the root URL for Cloud Servers API queries
    def server_management_url
      self.auth_response[:server_management_url]
    end
    
    # This returns the root URL for CDN Cloud Files API queries (not yet implemented)
    def cdn_management_url
      self.auth_response[:cdn_management_url]
    end
    
    # This performs a basic GET request using the supplied URL and headers
    def get(url, headers = {})
      http :get, "#{url}.json", headers
    end
    
    # This performs a basic POST request using the supplied URL, payload and headers
    def post(url, payload = {}, headers = {})
      http :post, "#{url}.json", payload.to_json, headers
    end
    
    # This performs a basic PUT request using the supplied URL, payload and headers
    def put(url, payload = {}, headers = {})
      http :put, "#{url}.json", payload.to_json, headers
    end
    
    # This performs a basic DELETE request using the supplied URL and headers
    def delete(url, headers = {})
      http :delete, "#{url}.json", headers
    end
    
    # This will perform an HTTP call with the specified method, and arguments
    # It will also pick up if the response is that the request was unauthorized, and will attempt
    # the same request again after re-authenticating (in case the auth token has expired)
    def http(method, *args)
      args.last.merge!(self.default_headers).merge!("X-Auth-Token" => self.auth_token)
      response = RestClient.send(method, *args)
      @retried = false
      response
    rescue RestClient::Unauthorized
      @auth_response = nil
      if @retried
        raise
      else
        @retried = true
        retry
      end
    end
  end
end
