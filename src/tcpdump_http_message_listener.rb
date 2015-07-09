require 'pcap_tools'
require_relative 'util/system_command_executor'
require_relative 'interactive_tcpdump_network_traffic_writer'
require_relative 'pcap_tools/pcap_tools_http_message_parser'
require_relative 'pcap_tools/pcap_tools_http_message_row_mapper_factory'

class TcpdumpHttpMessageListener
  WORKING_DIRECTORY = './tmp/'

  def initialize(participants, ports_to_monitor, capture_traffic)
    @http_message_mapper_factory = PcapToolsHttpMessageRowMapperFactory.new(participants)
    @tcpdump_network_traffic_writer = InteractiveTcpdumpNetworkTrafficWriter.new(ports_to_monitor)
    @pcap_tools_http_message_parser = PcapToolsHttpMessageParser.new
    @capture_traffic = capture_traffic
  end

  def get_http_messages

    if (@capture_traffic)
      FileUtils.rm_rf WORKING_DIRECTORY, secure:true
      FileUtils.mkdir_p WORKING_DIRECTORY
      tcpdump_output_file_path = "#{WORKING_DIRECTORY}/output.pcap"
      @tcpdump_network_traffic_writer.write_network_traffic_to(tcpdump_output_file_path)
    end

    chronological_http_messages = @pcap_tools_http_message_parser.parse_file(tcpdump_output_file_path)

    http_message_mapper = @http_message_mapper_factory.create_for(chronological_http_messages)
    chronological_http_messages.map { |event| http_message_mapper.map_from(event) }
  end

end
