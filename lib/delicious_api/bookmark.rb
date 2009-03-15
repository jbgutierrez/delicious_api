module DeliciousApi
  class Bookmark
    attr_reader :href, :description, :extended, :hash, :meta, :others, :tags, :time
    def initialize(params)
      @href = params['href']
      @description = params['description']
      @extended = params['extended']
      @hash = params['hash']
      @meta = params['meta']
      @others = params['others'] 
      @tags = params['tag']
      @time = DateTime.strptime(params['time'])
    end
  end
end