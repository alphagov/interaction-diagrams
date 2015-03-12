class HttpResponse
  attr_reader :source_name, :destination_name, :response_code, :set_cookie_header, :location_header, :content_type_header, :body

  def initialize(source_name, destination_name, response_code, set_cookie_header, location_header, content_type_header, body)
    @source_name = source_name
    @destination_name = destination_name
    @response_code = response_code
    @set_cookie_header = set_cookie_header
    @location_header = location_header
    @content_type_header = content_type_header
    @body = body
  end

  def response?
    true
  end
end