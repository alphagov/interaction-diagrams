
class SingleDiagramWriter
  def initialize(output_file, display_request_bodies, display_response_bodies, participant_order)
    @display_request_bodies = display_request_bodies
    @display_response_bodies = display_response_bodies
    formatter = InteractionDiagramFormatter.new
    @http_request_mapper = HttpRequestInteractionDiagramMapper.new(formatter, @display_request_bodies, @display_cookies)
    @http_response_mapper = HttpResponseInteractionDiagramMapper.new(formatter, @display_response_bodies, @display_cookies)
    @participant_order = participant_order
    @interaction_diagram = InteractionDiagram.new(@participant_order)
    @output_file = output_file
  end

  def visit_HttpRequest(http_request)
    source_name = http_request.source_name
    destination_name = http_request.destination_name

    @interaction_diagram.write_message(source_name, destination_name, @http_request_mapper.message_from(http_request), false)

    note = @http_request_mapper.note_from(http_request)
    @interaction_diagram.write_note(source_name, destination_name, note) if note.length > 0
  end

  def visit_HttpResponse(http_response)
    source_name = http_response.source_name
    destination_name = http_response.destination_name

    @interaction_diagram.write_message(source_name, destination_name, @http_response_mapper.message_from(http_response), true)

    note = @http_response_mapper.note_from(http_response)
    @interaction_diagram.write_note(source_name, destination_name, note) if note.length > 0
  end

  def finished
    interaction_diagram_canvas = HtmlInteractionDiagramCanvas.new(@output_file)
    interaction_diagram_canvas.paint(@interaction_diagram)
  end
end
