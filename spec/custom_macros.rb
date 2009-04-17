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
  end
end