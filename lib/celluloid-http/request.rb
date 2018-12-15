require 'active_support/core_ext/object/to_query'

class Celluloid::Http::Request
  extend Forwardable
  DEFAULT_METHOD = :get
  DEFAULT_HTTP_VERSION = '1.1'

  attr_accessor :method, :body, :form_data

  def_delegators :@uri, :scheme, :host, :path, :port, :query
  def_delegators :@uri, :scheme=, :host=, :path=, :port=

  def initialize(url, options = {})
    @uri = URI.parse url
    @ssl = @uri.scheme == 'https'
    @method = options[:method] || DEFAULT_METHOD
    @raw_body = options[:raw_body]
    @form_data = options[:form_data]

    merge_query_params(options[:query_params]) if options[:query_params]
  end

  def ssl?
    !!@ssl
  end

  def query_params
    Rack::Utils.parse_nested_query @uri.query
  end

  def to_s
    "#{method.to_s.upcase} #{uri} HTTP/#{DEFAULT_HTTP_VERSION}\nHost: #{host}\n\n#{body}"
  end

  def url
    @uri.to_s
  end

  def uri
    "#{ "/" if path.length.zero? }#{path}#{ "?" if query }#{query}"
  end

  def query=(val)
    @uri.query = val.is_a?(Hash) ? val.to_query : val
  end

  def merge_query_params(params)
    params = query_params.merge params
    self.query = params
  end

  def body
    @body = @raw_body if @raw_body
    @body = @form_data.to_query  if @form_data
    @body
  end

end