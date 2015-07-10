require 'set'
require_relative 'util/system_command_executor'
require_relative 'pcap_tools/tshark_pcap_parser'
require_relative 'pcap_tools/pcap_tools_http_message_row_mapper'
require_relative 'interactive_tcpdump_network_traffic_writer'

require 'active_support'
require 'active_support/core_ext'

class TcpdumpHttpMessageListener
  WORKING_DIRECTORY = './tmp/'

  def initialize(participants, ports_to_monitor, capture_traffic)
    @participants = participants
    @tcpdump_network_traffic_writer = InteractiveTcpdumpNetworkTrafficWriter.new(ports_to_monitor)
    @capture_traffic = capture_traffic
  end

  def get_http_messages
    tcpdump_output_file_path = "#{WORKING_DIRECTORY}/output.pcap"
    if (@capture_traffic)
      FileUtils.rm_rf WORKING_DIRECTORY, secure:true
      FileUtils.mkdir_p WORKING_DIRECTORY
      @tcpdump_network_traffic_writer.write_network_traffic_to(tcpdump_output_file_path)
    end

    all_user_agents = Set.new()

    mapper = PcapToolsHttpMessageRowMapper.new(@participants)
    results = []

    TsharkPcapParser.run(tcpdump_output_file_path) do |event|
      puts event
      all_user_agents << event[:user_agent] if event[:user_agent].present?
      results << mapper.map_from(event)
    end

    puts "All user agents: #{all_user_agents.to_a}"
    puts "User agent mappings: #{mapper.participants_by_port}"
    results
  end

end
