require File.dirname(__FILE__) + '/../spec_helper'

include DeliciousApi

describe Tag do

  configure_wrapper

  it "should instantiate correctly" do
    tag = Tag.new 'name', 'count' => '5'
    tag.name.should == 'name'
  end

  it "should fetch all tags" do
    Base.wrapper.should_receive(:get_all_tags)
    Tag.all
  end

  it "should remove a tag" do
    tag = Tag.new 'name'
    tag.wrapper.should_receive(:delete_tag).with(tag.name)
    tag.delete

    tag.name = nil
    lambda { tag.delete }.should raise_error(MissingAttributeError)
  end

  it "should rename a tag" do
    tag = Tag.new 'old_name'
    tag.wrapper.should_receive(:rename_tag).with(tag.name, 'new_name')
    tag.name = 'new_name'
    tag.save

    tag.name = nil
    lambda { tag.save }.should raise_error(MissingAttributeError)
  end
end