module DeliciousApi
  class Base
    
    # del.icio.us account username
    attr_reader :user
    
    # del.icio.us account password
    attr_reader :password

    # request user agent
    attr_reader :user_agent

    def initialize(user, password, user_agent = 'DeliciousApi')
      raise ArgumentError if (user.nil? || password.nil?)
      @user, @password, @user_agent = user, password, user_agent
    end
  end
end