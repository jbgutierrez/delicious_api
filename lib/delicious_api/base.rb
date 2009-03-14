require 'rubygems'
require 'hpricot'
require 'net/http'
require 'net/https'
require 'uri'
require 'active_support'

module DeliciousApi
  class Base
    
    # del.icio.us account username
    attr_reader :user
    
    # del.icio.us account password
    attr_reader :password

    # request user agent
    attr_reader :user_agent

    # http client
    attr_reader :http_client

    def initialize(user, password, user_agent = 'DeliciousApi')
      raise ArgumentError if (user.nil? || password.nil?)
      @user = user
      @password = password
      @user_agent = user_agent
    end

    # API Path Recent Posts
    API_URL_RECENT_POSTS   = '/v1/posts/recent?'

    ##
    # Returns a list of the most recent posts, filtered by argument. Maximum 100.
    # Arguments
    #   &tag={TAG}
    #     (optional) Filter by this tag.
    #   &count={1..100}
    #     (optional) Number of items to retrieve (Default:15, Maximum:100). 
    def recent_bookmarks(options = {})
      options.assert_valid_keys(:tag, :count)
      doc = retrieve_data(API_URL_RECENT_POSTS + options.to_query)
      (doc/"posts/post").collect{ |post| Bookmark.new(post.attributes) }
    end

    private

    def retrieve_data(url)
      init_http_client if @http.nil?
      response = make_web_request(url, {'User-Agent' => @user_agent})
      Hpricot.XML(response.body)
    end

    def init_http_client
      @http_client = Net::HTTP.new('api.del.icio.us', 443)
      @http_client.use_ssl = true
    end
    
    def make_web_request(url, headers)
      http_client.start do |http|
          req = Net::HTTP::Get.new(url, headers)
          req.basic_auth(@user, @password)
          @http_client.request(req)
      end
    end
    
  end
end