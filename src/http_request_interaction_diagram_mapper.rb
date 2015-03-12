class HttpRequestInteractionDiagramMapper
  def initialize(formatter, write_request_body)
    @formatter = formatter
    @write_request_body = write_request_body
  end

  def note_from(http_request)
    body_lines = []
    body_lines << "Cookie: #{http_request.cookie_header}" if http_request.cookie_header

    if @write_request_body && http_request.body

      if http_request.content_type_header
        body_lines << ' \n'
        body_lines << http_request.content_type_header
      end

      body_lines << ' \n'
      body_lines << http_request.body
    end

    @formatter.multiline_text_from(body_lines).strip
  end

  def message_from(http_request)
    "#{http_request.method} #{http_request.path}"
  end

end