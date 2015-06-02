class SystemCommandExecutor
  def self.invoke_and_kill_on_enter_key_press(command, prompt_text)
    rd, wr = IO.pipe
    pid = Kernel.spawn(command, :out => wr)
    puts prompt_text
    gets
    Process.kill('TERM', pid)
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
