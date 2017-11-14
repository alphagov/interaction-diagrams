class InteractiveTcpdumpNetworkTrafficWriter
  def initialize(ports)
    @ports = ports
  end

  def write_network_traffic_to(tcpdump_output_file_path)
    loopback_device = 'lo0'
    loopback_device = 'lo' if !((RUBY_PLATFORM =~ /linux/).to_i).zero?
    SystemCommandExecutor.run_tcpdump_and_wait_for_key_press(loopback_device, tcpdump_output_file_path, @ports, 'Recording network traffic. Press ENTER to stop...')
  end
end
