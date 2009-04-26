require File.dirname(__FILE__) + '/../spec_helper'

include DeliciousApi

describe Bundle do

  configure_wrapper

  describe "an instance of the Bundle class" do

    before(:each) do
      @bundle = Bundle.new 'languages', %w[galician spanish english french]
    end

    it "should have a name" do
      @bundle.name.should == 'languages'
    end

    it "should have an array of tags" do
      @bundle.tags.size.should == 4
      @bundle.tags.first.should == 'galician'
      @bundle.tags.last.should == 'french'
    end

    describe "having a save method" do

      it "should do it succesfully" do
        @bundle.wrapper.should_receive(:set_bundle).with(@bundle.name, @bundle.tags.join(' ')).and_return(true)
        @bundle.save
      end

      it "should raise an exception on missing attributes" do
        @bundle.name = nil
        @bundle.tags = nil
        lambda { @bundle.save }.should raise_error(MissingAttributeError)
      end

      it "should raise OperationFailed" do
        @bundle.wrapper.should_receive(:set_bundle).and_return(false)
        lambda { @bundle.save }.should raise_error(OperationFailed)
      end

    end

    describe "having a remove method" do

      it "should do it succesfully" do
        @bundle.wrapper.should_receive(:delete_bundle).with(@bundle.name).and_return(true)
        @bundle.delete
      end

      it "should raise an exception on missing attributes" do
        @bundle.name = nil
        lambda { @bundle.delete }.should raise_error(MissingAttributeError)
      end

      it "should raise OperationFailed" do
        @bundle.wrapper.should_receive(:delete_bundle).and_return(false)
        lambda { @bundle.delete }.should raise_error(OperationFailed)
      end

    end

  end

  describe "Bundle class" do

    it "should fetch tag bundles" do
      LIMIT = 10
      Base.wrapper.should_receive(:get_all_bundles).with(LIMIT)
      Bundle.all(LIMIT)
    end

  end

end