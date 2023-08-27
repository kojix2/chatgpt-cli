require "./base"

module ChatGPT
  class Substitutor
    class Command < Base
      def substitute(input_msg, config)
        command(input_msg, config.command_regex)
      end

      def command(input_msg, command_pattern)
        input_msg.gsub(command_pattern) do |command_match|
          command_pattern = $1.strip
          command_output = `#{command_pattern}`
        end
      end
    end
  end
end
