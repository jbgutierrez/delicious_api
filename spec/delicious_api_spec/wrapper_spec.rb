require File.dirname(__FILE__) + '/../spec_helper'

include DeliciousApi

USER       = 'user'
PASSWORD   = 'password'
USER_AGENT = 'user agent'

def request_should_be_sent_to(url)
  headers = { 'User-Agent' => USER_AGENT }
  Net::HTTP::Get.should_receive(:new).with(url,headers).at_most(2).and_return(@request)
end

def stub_body_response_with(xml)
  @response.stub!(:body).and_return(xml)
end

describe Wrapper do
 
  describe "Initialization" do

    it "should raise error when no credentials have been specified" do
      lambda { Wrapper.new(nil, nil) }.should raise_error(ArgumentError)
      lambda { Wrapper.new(USER, nil) }.should raise_error(ArgumentError)
      lambda { Wrapper.new(nil, PASSWORD) }.should raise_error(ArgumentError)
    end
    
    it "should set user and password and a default User-Agent" do
      wrapper = Wrapper.new(USER, PASSWORD)
      wrapper.user.should eql(USER)
      wrapper.password.should eql(PASSWORD)
    end
    
    it "should allow an optional User-Agent" do      
      wrapper = Wrapper.new(USER, PASSWORD, :user_agent => USER_AGENT)
      wrapper.user_agent.should equal(USER_AGENT)
    end
    
    it "should allow an alternative time gap" do
      waiting_time_gap = 2
      wrapper = Wrapper.new(USER, PASSWORD, :waiting_time_gap => waiting_time_gap)
      wrapper.waiting_time_gap.should equal(waiting_time_gap)
    end
    
  end
  
  describe "Requests" do
  
    before do
      options = { :user_agent => USER_AGENT, :waiting_time_gap => 0 }
      
      @wrapper     = Wrapper.new(USER, PASSWORD, options )
      @request     = Net::HTTP::Get.new('/')
      @response    = Net::HTTPSuccess.new('httpv', '200', 'msg')
      @http_client = Net::HTTP.new('api.del.icio.us')
      
      Net::HTTP.stub!(:new).and_return(@http_client)
      @http_client.stub!(:start).and_yield(@http_client) # behaviour overriden so that it doesn't open a TCP connection
      @http_client.stub!(:request).with(@request).and_return(@response)
    end

    describe "Generic request" do
      
      def send_fake_request
        request_should_be_sent_to "/"
        stub_body_response_with "response"        
        @wrapper.send :process_request, "/" # not quite sure if sending a message to a a private method is a good practice
      end
      
      it "should use SSL" do
        Net::HTTP.should_receive(:new).with('api.del.icio.us', 443)
        @http_client.should_receive(:use_ssl=).with(true)
        send_fake_request
      end
  
      it "should set user and password" do
        @request.should_receive(:basic_auth).with(USER, PASSWORD).once
        send_fake_request
      end
      
      it "should set User-Agent to something identifiable"

      it "should wait AT LEAST ONE SECOND between queries" do
        @wrapper = Wrapper.new(USER, PASSWORD, :user_agent => USER_AGENT )
        measurement = Benchmark.measure{ send_fake_request; send_fake_request; }
        measurement.real.should take_more_than(1.second)
        measurement.real.should_not take_more_than(1.05.second)
      end

      it "should handle 401 errors" do
        response_401 = Net::HTTPUnauthorized.new nil, nil, nil
        @http_client.stub!(:request).with(@request).and_return(response_401)
        lambda { send_fake_request }.should raise_error(HTTPError)
      end

      it "should handle 503 errors" do
        response_503 = Net::HTTPServiceUnavailable.new nil, nil, nil
        @http_client.stub!(:request).with(@request).and_return(response_503)
        lambda { send_fake_request }.should raise_error(HTTPError)
      end
      
      it "should raise an exception when something goes wrong"

    end

    describe "Tags requests" do

      it "should fetch all tags" do
        #mocking
        request_should_be_sent_to '/v1/tags/get'
        stub_body_response_with <<-EOS
        <tags>
          <tag count="1" tag="activedesktop" />
          <tag count="1" tag="business" />
          <tag count="3" tag="radio" />
          <tag count="5" tag="xml" />
          <tag count="1" tag="xp" />
          <tag count="1" tag="xpi" />
        </tags>
        EOS
        # actual method call
        tags = @wrapper.get_all_tags
    
        # return value expectations
        tags.size.should == 6
        tag = tags.first
        tag.should be_a_kind_of(Tag)

        tag.name.should  == "activedesktop"
        tag.count.should == "1"
      end

      it "should rename a tag on all posts" do
        # mocking
        request_should_be_sent_to '/v1/tags/rename?new=new_name&old=original_name'
        stub_body_response_with '<result code="done" />'
    
        # actual method call
        result = @wrapper.rename_tag 'original_name', 'new_name'
    
        # return value expectations
        result.should == true
        
      end

      it "should delete a tag from all posts" do
        # mocking
        request_should_be_sent_to '/v1/tags/delete?tag=tag_to_delete'
        stub_body_response_with '<result code="done" />'
    
        # actual method call
        result = @wrapper.delete_tag 'tag_to_delete'
    
        # return value expectations
        result.should == true        
      end

      it "should fetch popular, recommended and network tags for a specific url" do
        #mocking
        request_should_be_sent_to '/v1/posts/suggest?url=http%3A%2F%2Fyahoo.com%2F'
        stub_body_response_with <<-EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <suggest>
          <popular>yahoo!</popular>
          <popular>yahoo</popular>
          <popular>web</popular>
          <popular>tools</popular>
          <popular>searchengines</popular>
          <recommended>yahoo!</recommended>
          <recommended>yahoo</recommended>
          <recommended>web</recommended>
          <recommended>tools</recommended>
          <recommended>search</recommended>
          <recommended>reference</recommended>
          <recommended>portal</recommended>
          <recommended>news</recommended>
          <recommended>music</recommended>
          <recommended>internet</recommended>
          <recommended>home</recommended>
          <recommended>games</recommended>
          <recommended>entertainment</recommended>
          <recommended>email</recommended>
          <network>for:Bernard</network>
          <network>for:britta</network>
          <network>for:deusx</network>
          <network>for:joshua</network>
          <network>for:stlhood</network>
          <network>for:theteam</network>
        </suggest>
        EOS
        # actual method call
        suggestions = @wrapper.get_suggested_tags_for_url('http://yahoo.com/')
    
        # return value expectations
        suggestions[:popular].size.should     == 5
        suggestions[:recommended].size.should == 14
        suggestions[:network].size.should     == 6

        first_popular = suggestions[:popular].first
        first_popular.should be_a_kind_of(Tag)
        first_popular.name.should == 'yahoo!'

        first_recommended = suggestions[:recommended].first
        first_recommended.should be_a_kind_of(Tag)
        first_recommended.name.should == 'yahoo!'

        first_network = suggestions[:network].first
        first_network.should be_a_kind_of(Tag)
        first_network.name.should == 'for:Bernard'
      end

    end

    describe "Bookmark requests" do

      describe "should add a new bookmark" do
        it do
          request_should_be_sent_to '/v1/posts/add?description=foo&url=bar'
          stub_body_response_with '<result code="done" />'
          result = @wrapper.add_bookmark 'bar', 'foo'
          result.should == true
        end

        it "(item already exists)" do
          request_should_be_sent_to '/v1/posts/add?description=foo&replace=no&url=bar'
          stub_body_response_with '<result code="item already exists" />'
          result = @wrapper.add_bookmark 'bar', 'foo', { :replace => 'no' }
          result.should == true
        end
      end

      describe "should delete an existing bookmark" do
        it do
          request_should_be_sent_to '/v1/posts/delete?url=foo'
          stub_body_response_with '<result code="done" />'
          result = @wrapper.delete_bookmark 'foo'
          result.should == true
        end

        it "(item not found)" do
          request_should_be_sent_to '/v1/posts/delete?url=foo'
          stub_body_response_with '<result code="item not found" />'
          result = @wrapper.delete_bookmark 'foo'
          result.should == true
        end
      end

      it "should get bookmark for a single date" do
        # mocking
        request_should_be_sent_to '/v1/posts/get?meta=yes&tag=webdev'
        stub_body_response_with <<-EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <posts dt="2005-11-28" tag="webdev" user="user">
          <post href="http://www.howtocreate.co.uk/tutorials/texterise.php?dom=1"
              description="JavaScript DOM reference"
              extended="dom reference"
              hash="c0238dc0c44f07daedd9a1fd9bbdeebd"
              meta="92959a96fd69146c5fe7cbde6e5720f2"
              others="55" tag="dom javascript webdev" time="2005-11-28T05:26:09Z" />
        </posts>
        EOS
    
        # actual method
        bookmarks = @wrapper.get_bookmarks_by_date(nil, { :tag => 'webdev', :meta => 'yes'})

        # return value expectations
        bookmarks.size.should == 1
        bookmark = bookmarks.first
        bookmark.should be_a_kind_of(Bookmark)
        bookmark.href.should         == "http://www.howtocreate.co.uk/tutorials/texterise.php?dom=1"
        bookmark.description.should  == "JavaScript DOM reference"
        bookmark.extended.should     == "dom reference"
        bookmark.hash.should         == "c0238dc0c44f07daedd9a1fd9bbdeebd"
        bookmark.meta.should         == "92959a96fd69146c5fe7cbde6e5720f2"
        bookmark.others.should       == "55"
        bookmark.tags.should         == %w[dom javascript webdev]
        bookmark.time.should         == Time.iso8601('2005-11-28T05:26:09Z')
      end

      it "should get fetch a specific bookmark" do
        # mocking
        request_should_be_sent_to '/v1/posts/get?url=http%3A%2F%2Fwww.yahoo.com%2F'
        stub_body_response_with <<-EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <posts user="user" dt="2007-12-11" tag="">
          <post href="http://www.yahoo.com/" 
              hash="2f9704c729e7ed3b41647b7d0ad649fe" 
              description="Yahoo!" 
              extended="My favorite site ever"
              tag="yahoo web search" time="2007-12-11T00:00:07Z" others="433" />
        </posts>
        EOS

        # actual method
        bookmark = @wrapper.get_bookmark_by_url('http://www.yahoo.com/')

        # return value expectations
        bookmark.should be_a_kind_of(Bookmark)
        bookmark.href.should         == "http://www.yahoo.com/"
        bookmark.description.should  == "Yahoo!"
        bookmark.extended.should     == "My favorite site ever"
        bookmark.hash.should         == "2f9704c729e7ed3b41647b7d0ad649fe"
        bookmark.others.should       == "433"
        bookmark.tags.should         == %w[yahoo web search]
        bookmark.time.should         == Time.iso8601('2007-12-11T00:00:07Z')
      end

      it "should fetch recent bookmarks" do
        # mocking
        request_should_be_sent_to '/v1/posts/recent?count=2'
        stub_body_response_with <<-EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <posts user="jbgutierrez" tag="">
          <post href="http://foo/" hash="82860ec95b0c5ca86212bfca3b352ed0" description="Foo Site" tag="Foo" time="2008-01-01T00:00:00Z" extended=""/>
          <post href="http://bar/" hash="fbaf0c0208a3f1664d5e520fd4e8000a" description="Bar Site" tag="Bar" time="2009-01-01T00:00:00Z" extended=""/>
        </posts>
        EOS
    
        # actual method
        bookmarks = @wrapper.get_recent_bookmarks(:count => 2)

        # return value expectations
        bookmarks.size.should == 2
        bookmark = bookmarks.first
        bookmark.should be_a_kind_of(Bookmark)
    
        bookmark.href.should         == "http://foo/"
        bookmark.hash.should         == "82860ec95b0c5ca86212bfca3b352ed0"
        bookmark.description.should  == "Foo Site"
        bookmark.tags.should         == %w[Foo]
        bookmark.time.should         == Time.iso8601('2008-01-01T00:00:00Z')
      end

      it "should fetch all bookmarks by date or index range" do
        # mocking
        request_should_be_sent_to "/v1/posts/all?results=2"
        stub_body_response_with <<-EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <posts user="jbgutierrez" tag="">
          <post href="http://foo/" hash="82860ec95b0c5ca86212bfca3b352ed0" description="Foo Site" tag="Foo" time="2008-01-01T00:00:00Z" extended=""/>
          <post href="http://bar/" hash="fbaf0c0208a3f1664d5e520fd4e8000a" description="Bar Site" tag="Bar" time="2009-01-01T00:00:00Z" extended=""/>
        </posts>
        EOS

        # actual method
        bookmarks = @wrapper.get_all_bookmarks(:results => 2)

        # return value expectations
        bookmarks.size.should == 2
        bookmark = bookmarks.first
        bookmark.should be_a_kind_of(Bookmark)

        bookmark.href.should         == "http://foo/"
        bookmark.hash.should         == "82860ec95b0c5ca86212bfca3b352ed0"
        bookmark.description.should  == "Foo Site"
        bookmark.tags.should         == %w[Foo]
        bookmark.time.should         == Time.iso8601('2008-01-01T00:00:00Z')
      end

    end

    describe "Tag Bundles requests" do

      it "should fetch user bundles" do
        # mocking
        request_should_be_sent_to "/v1/tags/bundles/all?"
        stub_body_response_with <<-EOS
        <bundles>
          <bundle name="languages" tags="galician spanish english french" />
          <bundle name="music" tags="ipod mp3 music" />
        </bundles>
        EOS

        # actual method
        bundles = @wrapper.get_all_bundles

        # return value expectations
        bundles.size.should == 2
        bundle = bundles.first
        bundle.should be_a_kind_of(Bundle)

        bundle.name.should == "languages"
        bundle.tags.should == %w[galician spanish english french]
      end

      it "should fetch a specific tag bundle" do
        # mocking
        request_should_be_sent_to "/v1/tags/bundles/all?bundle=music"
        stub_body_response_with <<-EOS
        <bundles>
          <bundle name="music" tags="ipod mp3 music" />
        </bundles>
        EOS

        # actual method
        bundle = @wrapper.get_bundle_by_name 'music'

        # return value expectations
        bundle.should be_a_kind_of(Bundle)
        bundle.name.should == "music"
        bundle.tags.should == %w[ipod mp3 music]
      end

      it "should assign a set of tags to a bundle" do
        # mocking
        request_should_be_sent_to "/v1/tags/bundles/set?bundle=music&tags=ipod+mp3+music"
        stub_body_response_with "<result>ok</result>"

        # actual method
        result = @wrapper.set_bundle 'music', 'ipod mp3 music'

        # return value expectations
        result.should == true
      end

      it "should delete a tag bundle" do
        # mocking
        request_should_be_sent_to '/v1/tags/bundles/delete?bundle=foo'
        stub_body_response_with '<result code="done" />'

        # actual method call
        result = @wrapper.delete_bundle 'foo'

        # return value expectations
        result.should == true
      end
  
    end

    describe "Other requests" do

      it "should fetch a change detection manifest of all items"

      it "should list dates on which bookmarks were posted"

      it "should check to see when a user last posted an item."

    end

  end

end