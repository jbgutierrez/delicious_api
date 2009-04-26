require File.dirname(__FILE__) + '/../spec_helper'

include DeliciousApi

describe Tag do

  configure_wrapper

  describe "an instance of the Tag class" do

    before(:each) do
      @tag = Tag.new 'name', 'count' => '5'
    end

    it "should have a name" do
      @tag.name.should == 'name'
    end

    it "should have a count" do
      @tag.count.should == '5'
    end

    describe "having a remove method" do

      it "should do it succesfully" do
        @tag.wrapper.should_receive(:delete_tag).with(@tag.name).and_return(true)
        @tag.delete
      end

      it "should raise an exception on missing attributes" do
        @tag.name = nil
        lambda { @tag.delete }.should raise_error(MissingAttributeError)
      end

      it "should raise OperationFailed" do
        @tag.wrapper.should_receive(:delete_tag).and_return(false)
        lambda { @tag.delete }.should raise_error(OperationFailed)
      end

    end

    describe "having a save method" do

      it "should do it succesfully" do
        @tag.wrapper.should_receive(:rename_tag).with(@tag.name, 'new_name').and_return(true)
        @tag.name = 'new_name'
        @tag.save
      end

      it "should description" do
        @tag.name = nil
        lambda { @tag.save }.should raise_error(MissingAttributeError)
      end

      it "should raise OperationFailed" do
        @tag.wrapper.should_receive(:rename_tag).and_return(false)
        @tag.name = 'new_name'
        lambda { @tag.save }.should raise_error(OperationFailed)
      end

      it "should do nothing when the name hasn't been change" do
        @tag.wrapper.should_not_receive(:rename_tag)
        @tag.save
      end

    end
  end

  describe "Bundle class" do

    it "should fetch all tags" do
      Base.wrapper.should_receive(:get_all_tags)
      Tag.all
    end

  end

end