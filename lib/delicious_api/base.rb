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
    API_URL_ADD_BOOKMARK         = '/v1/posts/add?'
    API_URL_DELETE_BOOKMARK      = '/v1/posts/delete?'
    API_URL_GET_BOOKMARK_BY_DATE = '/v1/posts/get?'
    API_URL_RECENT_BOOKMARKS     = '/v1/posts/recent?'

    ##
    # Add a bookmark to Delicious
    # ==== Parameters
    # * <tt>url</tt> - the url of the item.
    # * <tt>description</tt> - the description of the item.
    # * <tt>options</tt> - A <tt>Hash</tt> containing any of the following:
    #   - <tt>extended</tt> - notes for the item.
    #   - <tt>tags</tt> - tags for the item (space delimited).
    #   - <tt>dt</tt> - datestamp of the item (format "CCYY-MM-DDThh:mm:ssZ"). Requires a LITERAL "T" and "Z" like in ISO8601 at http://www.cl.cam.ac.uk/~mgk25/iso-time.html for example: "1984-09-01T14:21:31Z"
    #   - <tt>replace=no</tt> - don't replace bookmark if given url has already been posted.
    #   - <tt>shared=no</tt> - make the item private
    # ==== Result
    # * <tt>true</tt> if the bookmark was successfully added
    # * <tt>false</tt> if the addition failed   
    def add_bookmark(url, description, options = {})
      options.assert_valid_keys(:extended, :tags, :dt, :replace, :shared)
      options[:url], options[:description] = url, description
      doc = retrieve_data(API_URL_ADD_BOOKMARK + options.to_query)
      doc.at('result')['code'] == 'done'      
    end

    ##
    # Delete a bookmark from Delicious
    # ==== Parameters
    # * <tt>url</tt> - the url of the item.
    # ==== Result
    # * <tt>true</tt> if the bookmark was successfully deleted
    # * <tt>false</tt> if the deletion failed   
    def delete_bookmark(url)
      options = { :url => url }
      doc = retrieve_data(API_URL_DELETE_BOOKMARK + options.to_query)
      doc.at('result')['code'] == 'done'      
    end
    
    ##
    # Returns one or more bookmarks on a single day matching the arguments. If no date or url is given, most recent date will be used.
    # ==== Parameters
    # * <tt>dt</tt> - Filter by this date, defaults to the most recent date on which bookmarks were saved.
    # * <tt>options</tt> - A <tt>Hash</tt> containing any of the following:
    #   - <tt>tag</tt> - [TAG,TAG,...TAG] Filter by this tag.
    #   - <tt>url</tt> - Fetch a bookmark for this URL, regardless of date.
    #   - <tt>hashes</tt> - [MD5,MD5,...,MD5] Fetch multiple bookmarks by one or more URL MD5s regardless of date, separated by URL-encoded spaces (ie. '+').
    #   - <tt>meta=yes</tt> - Include change detection signatures on each item in a 'meta' attribute. Clients wishing to maintain a synchronized local store of bookmarks should retain the value of this attribute - its value will change when any significant field of the bookmark changes.
    # ==== Result
    # An <tt>Array</tt> of <tt>Bookmarks</tt> matching the criteria
    def get_bookmark_by_date(dt, options)
      options = { :dt => dt } unless dt.nil?
      options.assert_valid_keys(:tag, :dt, :url, :hashes, :meta)
      doc = retrieve_data(API_URL_GET_BOOKMARK_BY_DATE + options.to_query)
      (doc/'posts/post').collect{ |post| Bookmark.new(post.attributes) }
    end

    ##
    # Returns a <tt>Bookmark</tt> for the <tt>url</tt>
    # ==== Parameters
    # * <tt>url</tt> - Fetch a bookmark for this URL.
    # ==== Result
    # A <tt>Bookmark</tt> matching the criteria
    def get_bookmark_by_url(url)
      get_bookmark_by_date(nil, :url=> url).first
    end

    ##
    # Returns a list of the most recent bookmarks, filtered by argument. Maximum 100.
    # ==== Parameters
    # * <tt>tag</tt> - Filter by this tag.
    # * <tt>count</tt> - Number of items to retrieve (Default:15, Maximum:100). 
    # ==== Result
    # An <tt>Array</tt> of <tt>Bookmarks</tt> matching the criteria
    def recent_bookmarks(options = {})
      options.assert_valid_keys(:tag, :count)
      doc = retrieve_data(API_URL_RECENT_BOOKMARKS + options.to_query)
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