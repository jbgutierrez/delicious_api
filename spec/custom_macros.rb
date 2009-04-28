module CustomMacros
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def configure_wrapper
      before(:all) do
        Tag.wrapper = mock("base.wrapper", :null_object => true)
      end
      after(:all) do
        Tag.wrapper = nil
      end
    end

    def freeze_time
      before(:each) do
        time_now = Time.now.utc
        Time.stub!(:now).and_return(time_now)
      end
    end
  end
end