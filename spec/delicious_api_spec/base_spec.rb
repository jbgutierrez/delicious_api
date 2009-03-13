require File.dirname(__FILE__) + '/../spec_helper'

include DeliciousApi

describe Base do
 
  describe "Initialization" do
    
    it "should raise error when no credentials have been specified"
    
    it "should set user and password"
    
    it "should set a default User-Agent"
    
    it "should allow an optional User-Agent"
    
  end
  
  describe "Generic request" do

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

  describe "Bookmark request" do

    it "should be able to add a new bookmark"
  
    it "should be able to delete an existing bookmark"
  
    it "should be able to get bookmark for a single date, or fetch specific items"
  
    it "should be able to fetch recent bookmarks"
  
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