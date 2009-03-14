module DeliciousApi
  class Bookmark
    attr_reader :href, :description, :hash, :tags, :time
    def initialize(params)
      @href = params['href']
      @hash = params['hash']
      @description = params['description']
      @tags = params['tag']
      @time = DateTime.strptime(params['time'])
    end
  end
end