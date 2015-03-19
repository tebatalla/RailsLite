require_relative '../phase6/controller_base'
require_relative './flash'
require 'byebug'

module Phase7
  class ControllerBase < Phase6::ControllerBase

    def flash
      @flash ||= Flash.new(req)
    end

    def redirect_to(url)
      flash.store_flash(res)
      super
    end

    def render_content(content, content_type)
      flash.store_flash(res)
      super
    end
  end
end
