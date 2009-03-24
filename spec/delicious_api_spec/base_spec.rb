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

describe Base do
 
  describe "Initialization" do

    it "should raise error when no credentials have been specified" do
      lambda { DeliciousApi::Base.new(nil, nil) }.should raise_error(ArgumentError)
      lambda { DeliciousApi::Base.new(USER, nil) }.should raise_error(ArgumentError)
      lambda { DeliciousApi::Base.new(nil, PASSWORD) }.should raise_error(ArgumentError)
    end
    
    it "should set user and password and a default User-Agent" do
      base = DeliciousApi::Base.new(USER, PASSWORD)
      base.user.should eql(USER)
      base.password.should eql(PASSWORD)
    end
    
    it "should allow an optional User-Agent" do      
      base = DeliciousApi::Base.new(USER, PASSWORD, :user_agent => USER_AGENT)
      base.user_agent.should equal(USER_AGENT)
    end
    
    it "should allow an alternative time gap" do
      waiting_time_gap = 2
      base = DeliciousApi::Base.new(USER, PASSWORD, :waiting_time_gap => waiting_time_gap)
      base.waiting_time_gap.should equal(waiting_time_gap)
    end
    
  end
  
  describe "Requests" do
  
    before do
      options = { :user_agent => USER_AGENT, :waiting_time_gap => 0 }
      
      @base        = DeliciousApi::Base.new(USER, PASSWORD, options )
      @request     = Net::HTTP::Get.new('/')
      @response    = Net::HTTPSuccess.new('httpv', '200', 'msg')
      @http_client = Net::HTTP.new('api.del.icio.us')
      
      Net::HTTP.stub!(:new).and_return(@http_client)
      @http_client.stub!(:start).and_yield(@http_client) # behaviour overriden so that it doesn't open a TCP connection
      @http_client.stub!(:request).with(@request).and_return(@response)
    end

    describe "Generic request" do
      
      def take_more_than(seconds)
        simple_matcher("to take more than #{seconds} seconds") { |given| given > seconds }
      end
      
      def send_fake_request
        request_should_be_sent_to "/"
        stub_body_response_with "response"        
        @base.send :retrieve_data, "/" # not quite sure if sending a message to a a private method is a good practice
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
        @base = DeliciousApi::Base.new(USER, PASSWORD, :user_agent => USER_AGENT )
        measurement = Benchmark.measure{ send_fake_request; send_fake_request; }
        measurement.real.should take_more_than 1.second
        measurement.real.should_not take_more_than 1.05.second
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

    end

    describe "Tags requests" do

      it "should be able to fetch all tags"

      it "should be able to rename a tag on all posts"

      it "should be able to delete a tag from all posts"

      it "should be able to fetch popular, recommended and network tags for a specific url"

    end

    describe "Bookmark requests" do

      it "should be able to add a new bookmark" do
        # mocking
        request_should_be_sent_to '/v1/posts/add?description=foo&url=bar'
        stub_body_response_with '<result code="done" />'

        # actual method call
        result = @base.add_bookmark 'bar', 'foo'
    
        # return value expectations
        result.should == true
      end

      it "should be able to delete an existing bookmark" do
        # mocking
        request_should_be_sent_to '/v1/posts/delete?url=foo'
        stub_body_response_with '<result code="done" />'
    
        # actual method call
        result = @base.delete_bookmark 'foo'
    
        # return value expectations
        result.should == true
      end

      it "should be able to get bookmark for a single date" do
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
        bookmarks = @base.get_bookmarks_by_date(nil, { :tag => 'webdev', :meta => 'yes'})

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
        bookmark.tags.should         == "dom javascript webdev"
        bookmark.time.should         == DateTime.strptime('2005-11-28T05:26:09Z')
      end

      it "should be able to get fetch a specific bookmark" do
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
        bookmark = @base.get_bookmark_by_url('http://www.yahoo.com/')

        # return value expectations
        bookmark.should be_a_kind_of(Bookmark)
        bookmark.href.should         == "http://www.yahoo.com/"
        bookmark.description.should  == "Yahoo!"
        bookmark.extended.should     == "My favorite site ever"
        bookmark.hash.should         == "2f9704c729e7ed3b41647b7d0ad649fe"
        bookmark.others.should       == "433"
        bookmark.tags.should         == "yahoo web search"
        bookmark.time.should         == DateTime.strptime('2007-12-11T00:00:07Z')
      end

      it "should be able to fetch recent bookmarks" do
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
        bookmarks = @base.recent_bookmarks(:count => 2)

        # return value expectations
        bookmarks.size.should == 2
        bookmark = bookmarks.first
        bookmark.should be_a_kind_of(Bookmark)
    
        bookmark.href.should         == "http://foo/"
        bookmark.hash.should         == "82860ec95b0c5ca86212bfca3b352ed0"
        bookmark.description.should  == "Foo Site"
        bookmark.tags.should         == "Foo"
        bookmark.time.should         == DateTime.strptime('2008-01-01T00:00:00Z')
      end

      it "should be able to fetch all bookmarks by date or index range" do
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
        bookmarks = @base.all_bookmarks(:results => 2)

        # return value expectations
        bookmarks.size.should == 2
        bookmark = bookmarks.first
        bookmark.should be_a_kind_of(Bookmark)

        bookmark.href.should         == "http://foo/"
        bookmark.hash.should         == "82860ec95b0c5ca86212bfca3b352ed0"
        bookmark.description.should  == "Foo Site"
        bookmark.tags.should         == "Foo"
        bookmark.time.should         == DateTime.strptime('2008-01-01T00:00:00Z')
      end

    end

    describe "Tag Bundles requests" do

      it "should be able to fetch tag bundles"

      it "should be able to assign a set of tags to a bundle"

      it "should be able to delete a tag bundle" 
  
    end

    describe "Other requests" do

      it "should be able to fetch a change detection manifest of all items"

      it "should be able to list dates on which bookmarks were posted"

      it "should be able to check to see when a user last posted an item."

    end

  end

end