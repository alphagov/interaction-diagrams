require 'csv'

require_relative 'interaction_diagram'
require_relative 'interaction_diagram_http_message_writer'
require_relative 'html_interaction_diagram_canvas'
require_relative 'tcpdump_http_message_listener'
require_relative 'interaction_diagram_formatter'
require_relative 'http_request_interaction_diagram_mapper'
require_relative 'http_response_interaction_diagram_mapper'

class Application
  def self.generate_html_file(file_name, options)
    puts "Writing to #{file_name}..."

    participants = options[:participants]
    ordered_participants = participants.map { |participant| participant[:name] }

    ports_to_monitor = participants.
        select { |participant| participant[:port] && (options[:participants_to_monitor].empty? || options[:participants_to_monitor].include?(participant[:name])) }.
        map { |participant| participant[:port] }

    http_message_listener = TcpdumpHttpMessageListener.new(participants, ports_to_monitor, !options[:skip_capture])

    application = Application.new(
        HtmlInteractionDiagramCanvas.new(file_name),
        ordered_participants,
        http_message_listener, ports_to_monitor, options[:display_request_bodies], options[:display_response_bodies], options[:display_cookies])

    application.run
  end

  def initialize(interaction_diagram_canvas, ordered_participants, http_message_listener, ports_to_monitor, display_request_bodies, display_response_bodies, display_cookies)
    @interaction_diagram_canvas = interaction_diagram_canvas
    @ordered_participants = ordered_participants
    @http_message_listener = http_message_listener
    @ports_to_monitor = ports_to_monitor
    @display_request_bodies = display_request_bodies
    @display_response_bodies = display_response_bodies
    @display_cookies = display_cookies
  end

  def run
    interaction_diagram = InteractionDiagram.new(@ordered_participants)
    formatter = InteractionDiagramFormatter.new

    http_message_writer = InteractionDiagramHttpMessageWriter.new(
        interaction_diagram,
        HttpRequestInteractionDiagramMapper.new(formatter, @display_request_bodies, @display_cookies),
        HttpResponseInteractionDiagramMapper.new(formatter, @display_response_bodies, @display_cookies)
    )

    @http_message_listener.get_http_messages.
        reject { |http_message| is_unwanted_message(http_message) }.
        each { |http_message| http_message_writer.write(http_message) }

    @interaction_diagram_canvas.paint(interaction_diagram)
  end

  private
  def is_unwanted_message http_message
    if http_message.response?
      %w(304 404).include?(http_message.response_code) ||
          (http_message.content_type_header && http_message.content_type_header.match(/css|javascript|image/))
    else
      http_message.path.match(/\.(png|gif|ico|js|css)(\?[^.]+)?$/)
    end
  end
end
