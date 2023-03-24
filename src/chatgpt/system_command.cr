module ChatGPT
  class SystemCommand
    def try_run(input_message)
      if input_message.starts_with? "!"
        extracted_command = input_message[1..-1].strip
        run(extracted_command)
        true
      else
        false
      end
    end

    def run(command)
      command_output = `#{command}`
      if $?.success?
        puts command_output.colorize(:yellow)
      else
        STDERR.puts "Error: Command failed: #{command}".colorize(:yellow).mode(:bold)
        STDERR.puts command_output.colorize(:yellow)
      end
    end
  end
end
