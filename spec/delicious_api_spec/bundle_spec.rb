require File.dirname(__FILE__) + '/../spec_helper'

include DeliciousApi

describe Bundle do

  configure_wrapper

  it "should instantiate correctly" do
    bundle = Bundle.new 'languages', %w[galician spanish english french]
    bundle.name.should == 'languages'
    bundle.tags.size.should == 4
    bundle.tags.first.should == 'galician'
    bundle.tags.last.should == 'french'
  end

  it "should fetch tag bundles" do
    LIMIT = 10
    Base.wrapper.should_receive(:get_all_bundles).with(LIMIT)
    Bundle.all(LIMIT)
  end

  it "should save a tag bundle" do
    bundle = Bundle.new 'languages', %w[galician spanish english french]
    bundle.wrapper.should_receive(:set_bundle).with(bundle.name, 'galician spanish english french')
    bundle.save

    empty = Bundle.new nil
    lambda { empty.save }.should raise_error(MissingAttributeError)

    without_tags = Bundle.new 'languages'
    lambda { without_tags.save }.should raise_error(MissingAttributeError)

    without_name = Bundle.new nil, %w[galician spanish english french]
    lambda { without_name.save }.should raise_error(MissingAttributeError)
  end

  it "should remove a tag bundle" do
    bundle = Bundle.new 'languages'
    bundle.wrapper.should_receive(:delete_bundle).with(bundle.name)
    bundle.delete

    bundle.name = nil
    lambda { bundle.save }.should raise_error(MissingAttributeError)
  end

end