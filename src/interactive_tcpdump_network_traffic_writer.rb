class InteractiveTcpdumpNetworkTrafficWriter
  def initialize(ports)
    @ports = ports
  end

  def write_network_traffic_to(tcpdump_output_file_path)
    SystemCommandExecutor.invoke_and_kill_on_enter_key_press("tcpdump -q -n -s0 -i lo0 -w #{tcpdump_output_file_path} 'udp or (tcp and (port #{@ports.join(' or port ')}))'", 'Recording network traffic. Press ENTER to stop...')
  end
end
