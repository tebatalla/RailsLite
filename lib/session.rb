require 'json'
require 'webrick'
require 'byebug'

class Session
  def initialize(req)
    @session = {}
    req.cookies.each do |cookie|
      @session = @session.merge(JSON.parse(cookie.value)) if cookie.name == '_rails_lite_app'
    end
    @session
  end

  def [](key)
    @session[key]
  end


  def []=(key, val)
    @session[key] = val
  end

  def store_session(res)
    cookie = WEBrick::Cookie.new('_rails_lite_app', @session.to_json)
    res.cookies << cookie
  end
end
