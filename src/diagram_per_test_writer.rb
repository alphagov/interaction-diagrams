require 'erb'

class DiagramPerTestWriter

  def initialize(file_manager, display_request_bodies, display_response_bodies, title, participant_order, strict_participants)
    @file_manager = file_manager
    @display_request_bodies = display_request_bodies
    @display_response_bodies = display_response_bodies
    formatter = InteractionDiagramFormatter.new
    @http_request_mapper = HttpRequestInteractionDiagramMapper.new(formatter, @display_request_bodies, @display_cookies)
    @http_response_mapper = HttpResponseInteractionDiagramMapper.new(formatter, @display_response_bodies, @display_cookies)
    @title = title
    @tests = []
    @participant_order = participant_order
    @strict_participants = strict_participants
  end

  def write_index
    tests = @tests.group_by { |test| test.testClassName }
    index_renderer = ERB.new(File.read('src/views/index.html.erb'))
    index = index_renderer.result(binding)
    File.write(@file_manager.index_file, index)
    FileUtils.symlink(@file_manager.session_name_file, @file_manager.current_file_symlink, force: true)
  end

  def visit_StartTest(event)
    @tests << event
    file = @file_manager.new_output_file(event.testName, ".html")
    @interaction_diagram_canvas = HtmlInteractionDiagramCanvas.new(file)
    @interaction_diagram = InteractionDiagram.new(@participant_order, @strict_participants)
  end

  def visit_HttpRequest(http_request)
    return if @interaction_diagram.nil?

    source_name = http_request.source_name
    destination_name = http_request.destination_name

    @interaction_diagram.write_message(source_name, destination_name, @http_request_mapper.message_from(http_request), false)

    note = @http_request_mapper.note_from(http_request)
    @interaction_diagram.write_note(source_name, destination_name, note) if note.length > 0
  end


  def visit_HttpResponse(http_response)
    return if @interaction_diagram.nil?

    source_name = http_response.source_name
    destination_name = http_response.destination_name

    @interaction_diagram.write_message(source_name, destination_name, @http_response_mapper.message_from(http_response), true)

    note = @http_response_mapper.note_from(http_response)
    @interaction_diagram.write_note(source_name, destination_name, note) if note.length > 0
  end


  def visit_FinishTest(event)
    @interaction_diagram_canvas.paint(@interaction_diagram)
    @interaction_diagram_canvas = nil
    @interaction_diagram = nil
  end
end
