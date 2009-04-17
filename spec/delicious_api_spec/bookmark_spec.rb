require File.dirname(__FILE__) + '/../spec_helper'

describe Bookmark do
  it "should instantiate correctly"
  it "should be 'shared' by default"
  it "should fetch popular, recommended and network tags for a specific url"
  it "should save a bookmark"
  it "should raise a error on saving an existing bookmark"
  it "should save an existing bookmark (bang method)"
  it "should raise an exception on saving an invalid bookmark"
  it "should find bookmarks filtered by any combination of url, tags and date"
  it "should find a subset of all the bookmarks (start point and limit) filtered by any combination of tag, starting date and ending date"
  it "should fetch recent bookmarks"
  it "should delete bookmark"
end