module DeliciousApi
  class Bundle
    attr_reader :name, :tags
    def initialize(params)
      @name = params['name']
      @tags = params['tags']
    end
  end
end