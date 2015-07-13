require 'set'
require_relative 'util/system_command_executor'
require_relative 'pcap_tools/tshark_pcap_parser'
require_relative 'pcap_tools/pcap_tools_http_message_row_mapper'
require_relative 'interactive_tcpdump_network_traffic_writer'

require 'active_support'
require 'active_support/core_ext'

class TcpdumpHttpMessageListener

  def initialize(participants, ports_to_monitor, capture_traffic, verbose, file_manager)
    @participants = participants
    @tcpdump_network_traffic_writer = InteractiveTcpdumpNetworkTrafficWriter.new(ports_to_monitor)
    @capture_traffic = capture_traffic
    @file_manager = file_manager
    @verbose = verbose
  end

  def process_http_messages(message_processor)

    if (@capture_traffic)
      @file_manager.clear_pcap_output_file
      @tcpdump_network_traffic_writer.write_network_traffic_to(@file_manager.pcap_output_file, @verbose)
    end

    all_user_agents = Set.new()

    mapper = PcapToolsHttpMessageRowMapper.new(@participants)

    TsharkPcapParser.run(@file_manager.pcap_output_file, @verbose) do |event|
      puts event if @verbose
      all_user_agents << event[:user_agent] if event[:user_agent].present?
      mapper.map_from(event).accept(message_processor)
    end

    message_processor.finished

    puts "Unrecognised ports: #{mapper.participants_by_port.reject {|k, v| v.present? }}" if @verbose
  end

end
