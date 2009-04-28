require File.dirname(__FILE__) + '/base'

module DeliciousApi
  class Bundle < Base

    # Bundle name
    attr_accessor :name
    
    # Tags <tt>Array</tt>
    attr_accessor :tags

    ##
    # Bundle initialize method
    # ==== Parameters
    # * <tt>name</tt> - Bundle name
    # * <tt>tags</tt> - An optional <tt>Array</tt> of tags
    # ==== Result
    # An new instance of the current class
    def initialize(name, tags=[])
      @name = name
      @tags = tags
    end

    # Retrieves a list of tag bundles from Delicious
    # ==== Parameters
    # * <tt>limit</tt> - An integer determining the limit on the number of tag bundles that should be returned.
    def self.all(limit = 10)
      self.wrapper.get_all_bundles(limit)
    end

    # Updates a tag bundle at Delicious
    def save
      validate_presence_of :name, :tags
      wrapper.set_bundle(@name, @tags.join(' ')) || raise(OperationFailed)
    end

    # Deletes a tag bundle from Delicious
    def delete
      validate_presence_of :name
      wrapper.delete_bundle(@name) || raise(OperationFailed)
    end
  end
end