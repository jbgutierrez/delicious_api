module DeliciousApi

  # Raised when the 'wrapper' has not been specified
  class WrapperNotInitialized < DeliciousApiError; end

  # Raised when you've trying to use the 'wrapper' with incorrect parameters.
  class MissingAttributeError < DeliciousApiError; end

  # Raised when something goes wrong at the 'wrapper'
  class OperationFailed < DeliciousApiError; end

  class Base

    class << self

      @@wrapper = nil

      def wrapper=(wrapper) #:nodoc:
        @@wrapper = wrapper
      end

      def wrapper #:nodoc:
        raise WrapperNotInitialized, "Must initialize the 'wrapper' attribute first" if @@wrapper.nil?
        @@wrapper
      end

    end

    # Accepts an instance of a wrapper class, which will be used as a proxy of 
    # the methods provided by the subclases.
    # This attribute can be both set and retrieved both at class and instance level by calling +wrapper+.
    attr_accessor :wrapper

    def wrapper #:nodoc:
      @wrapper || Base.wrapper
    end

    protected

    # Assign the values of the Hash +params+ to the attributes of +self+ with the same key name 
    def assign(params) #:nodoc:
      params.each_pair do |key, value|
        self.send("#{key}=", value) rescue self.instance_eval("@#{key}=value") rescue next
      end
    end

    def self.before_assign(attribute, filter) #:nodoc:
      alias_method "old_#{attribute}=", "#{attribute}="

      module_eval <<-STR
        def #{attribute}=(#{attribute})
          self.old_#{attribute} = #{filter} #{attribute}
        end
      STR
    end

    def validate_presence_of(*attributes) #:nodoc:
      missing_attributes = []
      attributes.each do |attribute|
        value = self.send(attribute)
        missing_attributes << attribute if value.nil? || value.instance_of?(String) && value.empty?
      end
      raise(MissingAttributeError, "Missing required attribute(s): #{missing_attributes.join(", ")}") unless missing_attributes.empty?
    end

  end
end
