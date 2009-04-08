module DeliciousApi
  class Tag
    attr_reader :name, :count
    def initialize(params)
      @name   = params['tag']
      @count  = params['count']
    end
  end
end