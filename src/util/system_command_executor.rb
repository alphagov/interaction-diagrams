class SystemCommandExecutor
  def self.run_tcpdump_and_wait_for_key_press(loopback_device, tcpdump_output_file_path, ports, prompt_text)
    rd, wr = IO.pipe
    pid = Kernel.spawn("tcpdump",  "-q", "-n", "-s0", "-i", loopback_device, "-w", tcpdump_output_file_path, "udp or (tcp and (port #{ports.join(' or port ')}))", :out => wr)
    puts prompt_text
    STDIN.gets
    Process.kill('TERM', pid)
    Process.wait(pid)
    wr.close
    rd.read
    end

  def self.invoke(command)
    IO.popen(command) do |out|
      out.each do |line|
        yield line
      end
    end
  end
end
