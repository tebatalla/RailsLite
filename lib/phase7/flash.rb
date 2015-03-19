module Phase7
  class Flash
    attr_reader :cookie, :now
    def initialize(req)
      @value = {}
      req.cookies.each do |cookie|
        @cookie = cookie if cookie.name == '_rails_lite_app_flash'
      end
      @cookie ||= WEBrick::Cookie.new('_rails_lite_app_flash', @value.to_json)
    end

    def [](section)
      @value[section]
    end

    def []=(section, messages)
      @value[section] = messages
    end

    def store_flash(res)
      @cookie.value = @value.to_json
      @cookie.path = '/'
      @cookie.expires = Time.now - 2000000 if @value.empty? || @now
      res.cookies << @cookie
      @value
    end

    def now
      @now = true
      self
    end
  end
end
