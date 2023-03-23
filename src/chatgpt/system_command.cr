module ChatGPT
  class SystemCommand
    def try_run(message)
      if message.starts_with? "!"
        cmd = message[1..-1].strip
        run(cmd)
        true
      else
        false
      end
    end

    def run(command)
      output = `#{command}`
      if $?.success?
        puts output.colorize(:yellow)
      else
        STDERR.puts "Error: Command failed: #{command}".colorize(:yellow).mode(:bold)
        STDERR.puts output.colorize(:yellow)
      end
    end
  end
end
