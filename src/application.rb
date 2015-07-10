require 'csv'

require_relative 'interaction_diagram'
require_relative 'interaction_diagram_http_message_writer'
require_relative 'html_interaction_diagram_canvas'
require_relative 'tcpdump_http_message_listener'
require_relative 'interaction_diagram_formatter'
require_relative 'http_request_interaction_diagram_mapper'
require_relative 'http_response_interaction_diagram_mapper'
require_relative 'file_manager'
require_relative 'diagram_per_test_writer'

class Application
  def self.generate_diagrams(options)
    file_manager = FileManager.new(options)

    participants = options[:participants]
    ordered_participants = participants.map { |participant| participant[:name] }

    ports_to_monitor = participants.
        select { |participant| participant[:port] && (options[:participants_to_monitor].empty? || options[:participants_to_monitor].include?(participant[:name])) }.
        map { |participant| participant[:port] }

    http_message_listener = TcpdumpHttpMessageListener.new(participants, ports_to_monitor, !options[:skip_capture], options[:verbose], file_manager)

    application = Application.new(file_manager,
        ordered_participants,
        http_message_listener, ports_to_monitor, options[:display_request_bodies], options[:display_response_bodies], options[:display_cookies])

    application.run
  end

  def initialize(file_manager, ordered_participants, http_message_listener, ports_to_monitor, display_request_bodies, display_response_bodies, display_cookies)
    @file_manager = file_manager
    @ordered_participants = ordered_participants
    @display_request_bodies = display_request_bodies
    @display_response_bodies = display_response_bodies
    @display_cookies = display_cookies
    @http_message_listener = http_message_listener
  end

  def run
    diagram_writer = DiagramPerTestWriter.new(@file_manager, @ordered_participants, @display_request_bodies, @display_response_bodies, @file_manager.session_name)
    @http_message_listener.process_http_messages(SkipUnwantedMessages.new(diagram_writer))
  end

  private
  class SkipUnwantedMessages < SimpleDelegator

    def visit_HttpRequest(http_message)
      if !http_message.path.match(/\.(png|gif|ico|js|css)(\?[^.]+)?$/)
        __getobj__.visit_HttpRequest(http_message)
      end
    end

    def visit_HttpResponse(http_message)
      if !(%w(304 404).include?(http_message.response_code) ||
          (http_message.content_type_header && http_message.content_type_header.match(/css|javascript|image/)))
          __getobj__.visit_HttpResponse(http_message)
      end
    end
  end
end
