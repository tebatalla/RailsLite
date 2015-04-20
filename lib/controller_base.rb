require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'

require_relative 'params'
require_relative 'flash'
require_relative 'router'
require_relative 'session'

class ControllerBase
  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||= false
  end

  # Set the response status code and header
  def redirect_to(url)
    flash.store_flash(res)
    unless already_built_response?
      res.status = 302
      res['location'] = url
      @already_built_response = true
    else
      raise 'already rendered'
    end
    session.store_session(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    flash.store_flash(res)
    unless already_built_response?
      res.body = content
      res.content_type = content_type
      @already_built_response = true
    else
      raise 'already rendered'
    end
    session.store_session(res)
  end
  
  def render(template_name)
    template = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    new_template = ERB.new(template)
    render_content(new_template.result(binding), 'text/html')
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end

  def flash
    @flash ||= Flash.new(req)
  end
end
