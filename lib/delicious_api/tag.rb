require File.dirname(__FILE__) + '/base'

module DeliciousApi
  class Tag < Base

    attr_accessor :name, :original_name, :count

    def initialize(name, params = {})
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
      wrapper.delete_tag(@name)
    end

    # Updates a tag name at Delicious (if necessary)
    def save
      validate_presence_of :name
      unless @original_name == @name
        wrapper.rename_tag(@original_name, @name)
        @original_name = @name
      end
    end
  end
end