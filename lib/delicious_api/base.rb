module DeliciousApi

  # Raised when 'wrapper' has not been specified
  class WrapperNotInitialized < DeliciousApiError; end

  # Raised when you've trying to use the 'wrapper' with incorrect parameters.
  class MissingAttributeError < DeliciousApiError; end

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
    def assign(params)
      params.each_pair do |key, value|
        self.send("#{key}=", value) rescue next
      end
    end

    def validate_presence_of(*attributes)
      missing_attributes = []
      attributes.each do |attribute|
        value = self.send(attribute)
        missing_attributes << attribute if value.nil? || value.empty?
      end
      raise(MissingAttributeError, "Missing required attribute(s): #{missing_attributes.join(", ")}") unless missing_attributes.empty?
    end

  end
end
