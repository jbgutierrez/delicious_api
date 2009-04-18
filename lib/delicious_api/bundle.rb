require File.dirname(__FILE__) + '/base'

module DeliciousApi
  class Bundle < Base

    attr_accessor :name, :tags

    def initialize(name, tags=[])
      @name = name
      @tags = tags
    end

    # Retrieves a list of tag bundles from Delicious
    def self.all(limit = 10)
      self.wrapper.get_all_bundles(limit)
    end

    # Updates a tag bundle at Delicious
    def save
      validate_presence_of :name, :tags
      wrapper.set_bundle @name, @tags.join(' ')
    end

    # Deletes a tag bundle from Delicious
    def delete
      validate_presence_of :name
      wrapper.delete_bundle(@name)
    end
  end
end