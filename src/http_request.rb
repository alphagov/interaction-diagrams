class HttpRequest
  attr_reader :source_name, :destination_name, :method, :path, :body, :cookie_header, :content_type_header

  def initialize(source_name, destination_name, method, path, body, cookie_header, content_type_header)
    @source_name = source_name
    @destination_name = destination_name
    @method = method
    @path = path
    @body = body
    @cookie_header = cookie_header
    @content_type_header = content_type_header
  end

  def response?
    false
  end

end