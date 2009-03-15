require 'rubygems'
require 'hpricot'
require 'net/http'
require 'net/https'
require 'uri'

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

    # API Paths
    API_URL_ADD_POST       = '/v1/posts/add?'
    API_URL_DELETE_POST    = '/v1/posts/delete?'
    API_URL_RECENT_POSTS   = '/v1/posts/recent?'

    ##
    # Add a post to Delicious
    # Arguments
    # 
    # &url={URL}
    #     (required) the url of the item.
    # &description={...}
    #     (required) the description of the item.
    # &extended={...}
    #     (optional) notes for the item.
    # &tags={...}
    #     (optional) tags for the item (space delimited).
    # &dt={CCYY-MM-DDThh:mm:ssZ}
    #     (optional) datestamp of the item (format "CCYY-MM-DDThh:mm:ssZ"). Requires a LITERAL "T" and "Z" like in ISO8601 at http://www.cl.cam.ac.uk/~mgk25/iso-time.html for example: "1984-09-01T14:21:31Z"
    # &replace=no
    #     (optional) don't replace post if given url has already been posted.
    # &shared=no
    #     (optional) make the item private
    def add_bookmark(url, description, options = {})
      optional = [:extended, :tags, :dt, :replace, :shared]
      options.assert_valid_keys(optional)
      options[:url], options[:description] = url, description
      doc = retrieve_data(API_URL_ADD_POST + options.to_query)
      doc.at('result')['code'] == 'done'      
    end

    ##
    # Delete a post from Delicious
    # Arguments
    # 
    # &url={URL}
    #     (required) the url of the item.
    def delete_bookmark(url)
      options = { :url => url }
      doc = retrieve_data(API_URL_DELETE_POST + options.to_query)
      doc.at('result')['code'] == 'done'      
    end

    ##
    # Returns a list of the most recent posts, filtered by argument. Maximum 100.
    #
    # Arguments
    #   &tag={TAG}
    #     (optional) Filter by this tag.
    #   &count={1..100}
    #     (optional) Number of items to retrieve (Default:15, Maximum:100). 
    def recent_bookmarks(options = {})
      options.assert_valid_keys(:tag, :count)
      doc = retrieve_data(API_URL_RECENT_POSTS + options.to_query)
      (doc/'posts/post').collect{ |post| Bookmark.new(post.attributes) }
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