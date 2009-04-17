require File.dirname(__FILE__) + '/../spec_helper'

include DeliciousApi

describe Base do
  it "should raise an exception when no wrapper has been assigned" do
    lambda { Base.wrapper }.should raise_error(WrapperNotInitialized)
  end
end