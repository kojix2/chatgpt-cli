module ChatGPT
  class SystemCommand
    getter latest_stdout
    getter latest_stderr

    def initialize
      @latest_stdout = ""
      @latest_stderr = ""
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
        run_record(command)
      else
        run_no_record(command)
      end
    end

    private def run_record(command)
      stdout = IO::Memory.new
      stderr = IO::Memory.new
      flag = false
      begin
        status = Process.run(command, shell: true, output: stdout, error: stderr)
      rescue ex
        STDERR.puts "Error: Command failed: #{command}".colorize(:yellow).mode(:bold)
      end

      @latest_stdout = stdout.to_s
      @latest_stderr = stderr.to_s

      puts latest_stdout.colorize(:yellow)
      STDERR.puts latest_stderr.colorize(:yellow)
    end

    private def run_no_record(command)
      system(command)
    end
  end
end
