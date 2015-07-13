class InteractiveTcpdumpNetworkTrafficWriter
  def initialize(ports)
    @ports = ports
  end

  def write_network_traffic_to(tcpdump_output_file_path, verbose)
    tcpdump_command = "tcpdump -q -n -s0 -i lo0 -w #{tcpdump_output_file_path} 'udp or (tcp and (port #{@ports.join(' or port ')}))'"
    puts "Running: " + tcpdump_command if verbose
    SystemCommandExecutor.invoke_and_kill_on_enter_key_press(tcpdump_command, 'Recording network traffic. Press ENTER to stop...')
  end
end
