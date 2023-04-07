module ChatGPT
  class SystemCommandRunner
    getter last_stdout
    getter last_stderr
    getter last_command

    def initialize
      @last_stdout = ""
      @last_stderr = ""
      @last_command = ""
    end

    def try_run(input_message)
      return false unless input_message.starts_with? "!"

      if input_message.starts_with? "!!"
        run(input_message[2..-1].strip, record: true)
      else
        run(input_message[1..-1].strip, record: false)
      end
      true
    end

    private def run(command, record = true)
      if record
        run_with_record(command)
      else
        run_without_record(command)
      end
    end

    private def run_with_record(command)
      stdout = IO::Memory.new
      stderr = IO::Memory.new
      flag = false
      begin
        status = Process.run(command, shell: true, output: stdout, error: stderr)
      rescue ex
        STDERR.puts "Error: Command failed: #{command}"._colorize(:warning, :bold)
      end

      @last_command = command
      @last_stdout = stdout.to_s
      @last_stderr = stderr.to_s

      puts last_stdout._colorize(:stdout)
      STDERR.puts last_stderr._colorize(:stderr)
    end

    private def run_without_record(command)
      system(command)
    end
  end
end
