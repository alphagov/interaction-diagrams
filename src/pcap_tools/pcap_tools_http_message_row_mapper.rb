require_relative '../http_request'
require_relative '../http_response'

class PcapToolsHttpMessageRowMapper
  BROWSER_USER_AGENT_PATTERN = /mozilla/i
  BREAK_LINES_PATTERN = /.{0,100}/

  def initialize(events, participants)
    @messages_in_time = events
    @participants = participants
  end

  def map_from(event)
    source_name = source_name_from(event)
    destination_name = destination_name_from(event)
    body = event.body.length == 0 ? nil : event.body
    content_type_header = event.content_type

    if is_response?(event)
      HttpResponse.new(source_name, destination_name, event.code, event['set-cookie'], event['location'], content_type_header, body)
    else
      HttpRequest.new(source_name, destination_name, event.method, event.path, body, event['cookie'], content_type_header)
    end
  end

  private

  def components_by_port
    initialize_components_by_port if @components_by_port.nil?
    @components_by_port
  end

  def is_response?(event)
    event.is_a? Net::HTTPResponse
  end

  def destination_name_from(row)
    components_by_port[row['pcap-dst-port']] || row['pcap-dst-port']
  end

  def source_name_from(row)
    components_by_port[row['pcap-src-port']] || row['pcap-src-port']
  end

  def user_agent_from(event)
    raw_user_agent = event['user-agent'].chop
    (raw_user_agent.match BROWSER_USER_AGENT_PATTERN) ? 'User' : raw_user_agent
  end

  def initialize_components_by_port
    @components_by_port = Hash[@participants.select { |participant| participant[:port] }.map { |participant| [participant[:port].to_s, participant[:name]] }]
    participants_by_user_agent = Hash[@participants.map { |participant| [(participant[:user_agent] || participant[:name]), participant[:name]] }]

    @messages_in_time.each do |event|
      source_port = event['pcap-src-port']
      @components_by_port[source_port] = participants_by_user_agent[user_agent_from(event)] unless @components_by_port.has_key? source_port
    end
  end

end