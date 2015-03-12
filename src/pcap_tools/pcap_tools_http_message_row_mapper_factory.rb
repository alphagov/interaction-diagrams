require_relative 'pcap_tools_http_message_row_mapper'

class PcapToolsHttpMessageRowMapperFactory
  def initialize(participants)
    @participants = participants
  end

  def create_for(events)
    PcapToolsHttpMessageRowMapper.new(events, @participants)
  end
end