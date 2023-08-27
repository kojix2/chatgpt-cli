module ChatGPT
  class Substitutor
    def command(input_msg, command_pattern)
      input_msg.gsub(command_pattern) do |command_match|
        command_pattern = $1.strip
        command_output = `#{command_pattern}`
      end
    end
  end
end
