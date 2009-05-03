require 'hpricot'
require 'net/http'
require 'net/https'
require 'uri'

module DeliciousApi

  class HTTPError < DeliciousApiError; end

  class Wrapper

    # del.icio.us account username
    attr_reader :user

    # del.icio.us account password
    attr_reader :password

    # request user agent
    attr_reader :user_agent

    # requests time gap
    attr_reader :waiting_time_gap

    # http client
    attr_reader :http_client

    ##
    # Wrapper initialize method
    # ==== Parameters
    # * <tt>user</tt> - Delicious username
    # * <tt>password</tt> - Delicious password
    # * <tt>options</tt> - A <tt>Hash</tt> containing any of the following:
    #   - <tt>user_agent</tt> - User agent to sent to the server.
    #   - <tt>waiting_time_gap</tt> - Time gap between requests. By default is set to 1.
    # ==== Result
    # An new instance of the current class
    def initialize(user, password, options = {})
      raise ArgumentError if (user.nil? || password.nil?)
      options.assert_valid_keys(:user_agent, :waiting_time_gap)
      @user = user
      @password = password
      @user_agent = options[:user_agent] || default_user_agent
      @waiting_time_gap = options[:waiting_time_gap] || 1
    end

    # API URL to add a new bookmark
    API_URL_ADD_BOOKMARK          = '/v1/posts/add?'
    # API URL to delete an existing bookmark
    API_URL_DELETE_BOOKMARK       = '/v1/posts/delete?'
    # API URL to get a collection of bookmarks filtered by date
    API_URL_GET_BOOKMARKS_BY_DATE = '/v1/posts/get?'
    # API URL to get the most recent bookmarks
    API_URL_RECENT_BOOKMARKS      = '/v1/posts/recent?'
    # API URL to get all the bookmarks
    API_URL_ALL_BOOKMARKS         = '/v1/posts/all?'
    # API URL to get all the tag
    API_URL_ALL_TAGS              = '/v1/tags/get'
    # API URL to rename an existing tag
    API_URL_RENAME_TAG            = '/v1/tags/rename?'    
    # API URL to delete an existing tag
    API_URL_DELETE_TAG            = '/v1/tags/delete?'
    # API URL to get popular, recommended and network tags for a particular url
    API_URL_SUGGEST_TAG           = '/v1/posts/suggest?'
    # API URL to get all of a user's bundles.
    API_URL_ALL_BUNDLES           = '/v1/tags/bundles/all?'
    # API URL to set a tag bundle
    API_URL_SET_BUNDLE            = '/v1/tags/bundles/set?'
    # API URL to delete an existing bundle
    API_URL_DELETE_BUNDLE         = '/v1/tags/bundles/delete?'

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
      doc = process_request(API_URL_ADD_BOOKMARK + options.to_query)
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
      doc = process_request(API_URL_DELETE_BOOKMARK + options.to_query)
      doc.at('result')['code'] == 'done' || doc.at('result')['code'] == 'item not found'
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
    def get_bookmarks_by_date(dt, options)
      options = { :dt => dt } unless dt.nil?
      options.assert_valid_keys(:tag, :dt, :url, :hashes, :meta)
      doc = process_request(API_URL_GET_BOOKMARKS_BY_DATE + options.to_query)
      (doc/'posts/post').collect{ |post| Bookmark.new(post['href'], post.attributes) }
    end

    ##
    # Returns a <tt>Bookmark</tt> for the <tt>url</tt>
    # ==== Parameters
    # * <tt>url</tt> - Fetch a bookmark for this URL.
    # ==== Result
    # A <tt>Bookmark</tt> matching the criteria or nil
    def get_bookmark_by_url(url)
      get_bookmarks_by_date(nil, :url=> url).first
    end

    ##
    # Returns a list of the most recent bookmarks, filtered by argument. Maximum 100.
    # ==== Parameters
    # * <tt>tag</tt> - Filter by this tag.
    # * <tt>count</tt> - Number of items to retrieve (Default:15, Maximum:100). 
    # ==== Result
    # An <tt>Array</tt> of <tt>Bookmarks</tt> matching the criteria
    def get_recent_bookmarks(options = {})
      options.assert_valid_keys(:tag, :count)
      doc = process_request(API_URL_RECENT_BOOKMARKS + options.to_query)
      (doc/'posts/post').collect{ |post| Bookmark.new(post['href'], post.attributes) }
    end

    ##
    # Returns a list with all the bookmarks, filtered by argument.
    # ==== Parameters
    # * <tt>options</tt> - A <tt>Hash</tt> containing any of the following:
    #   - <tt>tag</tt> - Filter by this tag.
    #   - <tt>start</tt> - Start returning bookmarks this many results into the set.
    #   - <tt>results</tt> - Return this many results
    #   - <tt>fromdt</tt> - Filter for posts on this date or later (format "CCYY-MM-DDThh:mm:ssZ"). Requires a LITERAL "T" and "Z" like in ISO8601 at http://www.cl.cam.ac.uk/~mgk25/iso-time.html for example: "1984-09-01T14:21:31Z"
    #   - <tt>todt</tt> - Return this many results (format "CCYY-MM-DDThh:mm:ssZ"). Requires a LITERAL "T" and "Z" like in ISO8601 at http://www.cl.cam.ac.uk/~mgk25/iso-time.html for example: "1984-09-01T14:21:31Z"
    #   - <tt>meta=yes</tt> - Include change detection signatures on each item in a 'meta' attribute. Clients wishing to maintain a synchronized local store of bookmarks should retain the value of this attribute - its value will change when any significant field of the bookmark changes.
    # ==== Result
    # An <tt>Array</tt> of <tt>Bookmarks</tt> matching the criteria
    def get_all_bookmarks(options = {})
      options.assert_valid_keys(:tag, :start, :results, :fromdt, :todt, :meta)
      doc = process_request(API_URL_ALL_BOOKMARKS + options.to_query)
      (doc/'posts/post').collect{ |post| Bookmark.new(post['href'], post.attributes) }
    end
    
    ##
    # Returns a list of tags and number of times used by a user.
    # ==== Result
    # An <tt>Array</tt> of <tt>Tags</tt>
    def get_all_tags
      doc = process_request(API_URL_ALL_TAGS)
      (doc/'tags/tag').collect{ |tag| Tag.new(tag['tag'], tag.attributes) }
    end
    
    ##
    # Rename an existing tag with a new tag name.
    # ==== Parameters
    # * <tt>old_name</tt> - Original tag name.
    # * <tt>new_name</tt> - New tag name.
    # ==== Result
    # * <tt>true</tt> if the tag was successfully renamed
    # * <tt>false</tt> otherwise   
    def rename_tag(old_name, new_name)
      options = { :old => old_name, :new => new_name }
      doc = process_request(API_URL_RENAME_TAG + options.to_query)
      doc.at('result')['code'] == 'done'      
    end
    
    # Delete a tag from Delicious
    # ==== Parameters
    # * <tt>tag_to_delete</tt> - tag name to delete.
    # ==== Result
    # * <tt>true</tt> if the tag was successfully deleted
    # * <tt>false</tt> if the deletion failed   
    def delete_tag(tag_to_delete)
      options = { :tag => tag_to_delete }
      doc = process_request(API_URL_DELETE_TAG + options.to_query)
      doc.at('result')['code'] == 'done'      
    end

    ##
    # Returns a list of popular tags, recommended tags and network tags for the given url.
    # This method is intended to provide suggestions for tagging a particular url. 
    # ==== Parameters
    # * <tt>url</tt> - URL for which you'd like suggestions.
    # ==== Result
    # A <tt>Hash</tt> containing three arrays of <tt>Tags</tt>: <tt>:popular</tt>, <tt>:recommended</tt> and <tt>:network</tt>
    def get_suggested_tags_for_url(url)
      options = { :url => url }
      doc = process_request(API_URL_SUGGEST_TAG + options.to_query)
      result = { }
      result[:popular]     = (doc/'suggest/popular').collect{ |tag| Tag.new(tag.inner_html) }
      result[:recommended] = (doc/'suggest/recommended').collect{ |tag| Tag.new(tag.inner_html) }
      result[:network]     = (doc/'suggest/network').collect{ |tag| Tag.new(tag.inner_html) }
      result
    end

    ##
    # Retrieve all of a user's bundles.
    # ==== Parameters
    # * <tt>options</tt> - A <tt>Hash</tt> containing any of the following:
    #   - <tt>bundle</tt> - Fetch just the named bundle.
    # ==== Result
    # An <tt>Array</tt> of <tt>Bundles</tt> matching the criteria
    def get_all_bundles(options = {})
      options.assert_valid_keys(:bundle)
      doc = process_request(API_URL_ALL_BUNDLES + options.to_query)
      (doc/'bundles/bundle').collect{ |bundle| Bundle.new(bundle['name'], bundle['tags'].split(' ')) }
    end

    ##
    # Returns the user <tt>Bundle</tt> with the given <tt>name</tt>
    # ==== Parameters
    # * <tt>name</tt> - User's bundle name.
    # ==== Result
    # A <tt>Bundle</tt> matching the criteria or nil
    def get_bundle_by_name(name)
      get_all_bundles(:bundle => name).first
    end

    ##
    # Assign a set of tags to a single bundle, wipes away previous settings for bundle.
    # ==== Parameters
    # * <tt>name</tt> - bundle's name.
    # * <tt>tags</tt> - tags for the bundle (space delimited).
    # ==== Result
    # * <tt>true</tt> if the bundle was set
    # * <tt>false</tt> if the bundle was not set
    def set_bundle(name, tags)
      options = { :bundle => name, :tags => tags }
      doc = process_request(API_URL_SET_BUNDLE + options.to_query)
      doc.at('result').inner_html == 'ok'
    end

    ##
    # Delete a bundle from Delicious
    # ==== Parameters
    # * <tt>name</tt> - name of the bundle
    # ==== Result
    # * <tt>true</tt> if the bundle was successfully deleted
    # * <tt>false</tt> if the deletion failed
    def delete_bundle(name)
      options = { :bundle => name }
      doc = process_request(API_URL_DELETE_BUNDLE + options.to_query)
      doc.at('result')['code'] == 'done'
    end

    private

    def process_request(url)
      init_http_client if @http_client.nil?
      response = make_web_request(url)
      Hpricot.XML(response.body)
    end

    def init_http_client
      @http_client = Net::HTTP.new('api.del.icio.us', 443)
      @http_client.use_ssl = true
      @http_client.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    def make_web_request(url)
      http_client.start do |http|
          req = Net::HTTP::Get.new(url, {'User-Agent' => @user_agent} )
          req.basic_auth(@user, @password)
          current_time = Time.now
          @@last_request ||= current_time - waiting_time_gap
          current_window = [current_time - @@last_request, waiting_time_gap].max
          sleep(current_window) if current_window <= waiting_time_gap
          response = @http_client.request(req)
          case response
            when Net::HTTPSuccess
              return response
            when Net::HTTPUnauthorized        # 401 - HTTPUnauthorized
              raise HTTPError, 'Invalid username or password'
            when Net::HTTPServiceUnavailable  # 503 - HTTPServiceUnavailable
              raise HTTPError, 'You have been throttled. Try increasing the time gap between requests.'
            else
              raise HTTPError, "HTTP #{response.code}: #{response.message}"
          end
      end
    end
    
    def default_user_agent
      return "#{NAME}/#{VERSION} (Ruby/#{RUBY_VERSION})"
    end
    
  end
end