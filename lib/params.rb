require 'uri'

class Params
  def initialize(req, route_params = {})
    @params = route_params.merge(parse_www_encoded_form(req.query_string))
      .merge(parse_www_encoded_form(req.body))
  end

  def [](key)
    @params[key.to_s]
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private

  def parse_www_encoded_form(www_encoded_form)
    params = {}
    return params if www_encoded_form.nil?
    URI::decode_www_form(www_encoded_form).each do |keys, val|
      current_node = params
      keys_array = parse_key(keys)
      keys_array.each_with_index do |key, i|
        if i == keys_array.length - 1
          current_node[key] = val
        else
          current_node[key] ||= {}
          current_node = current_node[key]
        end
      end
    end
    params
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
