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
    rd, wr = IO.pipe
    Kernel.spawn(command, :out => wr)
    wr.close
    rd.read
  end
end