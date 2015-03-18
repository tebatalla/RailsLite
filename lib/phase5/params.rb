require 'uri'
require 'byebug'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = parse_www_encoded_form(req.query_string)
        .merge(parse_www_encoded_form(req.body))
        .merge(route_params)
    end

    def [](key)
      @params[key.to_s]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
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

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
