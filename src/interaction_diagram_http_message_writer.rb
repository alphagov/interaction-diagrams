class InteractionDiagramHttpMessageWriter
  def initialize(interaction_diagram, http_request_mapper, http_response_mapper)
    @interaction_diagram = interaction_diagram
    @http_request_mapper = http_request_mapper
    @http_response_mapper = http_response_mapper
  end

  def write(http_message)
    source_name = http_message.source_name
    destination_name = http_message.destination_name

    if http_message.response?
      write_response(destination_name, http_message, source_name)
    else
      write_request(destination_name, http_message, source_name)
    end
  end

  private

  def write_request(destination_name, http_request, source_name)
    @interaction_diagram.write_message(source_name, destination_name, @http_request_mapper.message_from(http_request), false)

    note = @http_request_mapper.note_from(http_request)
    @interaction_diagram.write_note(source_name, destination_name, note) if note.length > 0
  end

  def write_response(destination_name, http_response, source_name)
    @interaction_diagram.write_message(source_name, destination_name, @http_response_mapper.message_from(http_response), true)

    note = @http_response_mapper.note_from(http_response)
    @interaction_diagram.write_note(source_name, destination_name, note) if note.length > 0
  end

end