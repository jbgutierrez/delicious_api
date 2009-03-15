require File.dirname(__FILE__) + '/../spec_helper'

include DeliciousApi

def instance(*args)
  DeliciousApi::Base.new(*args)
end

describe Base do
 
  describe "Initialization" do
    
    USER = 'user'
    PASSWORD = 'password'
    USER_AGENT = 'Firefox/3.0.7'
    
    it "should raise error when no credentials have been specified" do
      lambda { instance(nil, nil) }.should raise_error(ArgumentError)
      lambda { instance(USER, nil) }.should raise_error(ArgumentError)
      lambda { instance(nil, PASSWORD) }.should raise_error(ArgumentError)
    end
    
    it "should set user and password and a default User-Agent" do
      base = instance(USER, PASSWORD)
      base.user.should eql(USER)
      base.password.should eql(PASSWORD)
    end
    
    it "should allow an optional User-Agent" do      
      base = instance(USER, PASSWORD, USER_AGENT)
      base.user_agent.should equal(USER_AGENT)
    end
    
  end
  
  describe "Generic request", :shared => true do

    it "should set user and password"
    
    it "should set User-Agent to something identifiable"
    
    it "should use SSL"
    
    it "should send a GET request successfully"
    
    it "should raise an error when invalid credentials"

    it "should raise an error when invalid request"
    
    it "should return XML from the body"

  end

  describe "Tags requests" do

    it "should be able to fetch all tags"
  
    it "should be able to rename a tag on all posts"
  
    it "should be able to delete a tag from all posts"

    it "should be able to fetch popular, recommended and network tags for a specific url"

  end

  describe "Bookmark requests" do

    it_should_behave_like "Generic request"

    before do
      @base = instance(USER, PASSWORD)
    end

    it "should be able to add a new bookmark" do
      url = '/v1/posts/add?description=foo&url=bar'
      xml = '<result code="done" />'
      # mocking
      @base.should_receive(:retrieve_data).with(url).and_return(Hpricot.XML(xml))
      
      # actual method call
      result = @base.add_bookmark 'bar', 'foo'
      
      # return value expectations
      result.should == true
    end
  
    it "should be able to delete an existing bookmark" do
      url = '/v1/posts/delete?url=foo'
      xml = '<result code="done" />'
      # mocking
      @base.should_receive(:retrieve_data).with(url).and_return(Hpricot.XML(xml))
      
      # actual method call
      result = @base.delete_bookmark 'foo'
      
      # return value expectations
      result.should == true
    end
  
    it "should be able to get bookmark for a single date, or fetch specific items"
  
    it "should be able to fetch recent bookmarks" do
      url = "/v1/posts/recent?count=2"
      xml = <<-EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <posts user="jbgutierrez" tag="">
        <post href="http://foo/" hash="82860ec95b0c5ca86212bfca3b352ed0" description="Foo Site" tag="Foo" time="2008-01-01T00:00:00Z" extended=""/>
        <post href="http://bar/" hash="fbaf0c0208a3f1664d5e520fd4e8000a" description="Bar Site" tag="Bar" time="2009-01-01T00:00:00Z" extended=""/>
      </posts>
      EOS

      # mocking
      @base.should_receive(:retrieve_data).with(url).and_return(Hpricot.XML(xml))
      
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
  
    it "should be able to fetch all bookmarks by date or index range"
  
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