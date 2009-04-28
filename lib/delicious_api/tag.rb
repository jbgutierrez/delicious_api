require File.dirname(__FILE__) + '/base'

module DeliciousApi
  class Tag < Base

    # Tag name
    attr_accessor :name

    # An alias for the tag name
    alias :tag :name

    # Number of times used
    attr_accessor :count

    ##
    # Tag initialize method
    # ==== Parameters
    # * <tt>name</tt> - Tag name
    # * <tt>params</tt> - An optional <tt>Hash</tt> containing any combination of the instance attributes
    # ==== Result
    # An new instance of the current class
    def initialize(name, params = {})
      params.symbolize_keys!.assert_valid_keys(:name, :tag, :count)
      params.merge!(:name => name, :original_name => name)
      assign params
    end

    # Retrieves a list of tags and number of times used from Delicious
    def self.all
      self.wrapper.get_all_tags
    end

    # Deletes a tag from Delicious
    def delete
      validate_presence_of :name
      wrapper.delete_tag(@name) || raise(OperationFailed)
    end

    # Updates a tag name at Delicious (if necessary)
    def save
      validate_presence_of :name
      unless @original_name == @name
        wrapper.rename_tag(@original_name, @name) || raise(OperationFailed)
        @original_name = @name
      end
    end

    protected
    attr_accessor :original_name

  end
end