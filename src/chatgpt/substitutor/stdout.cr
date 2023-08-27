require "./base"

module ChatGPT
  class Substitutor
    class Stdout < Base
      def initialize(@system_command_runner : SystemCommand)
      end

      def substitute(input_msg, config)
        stdout(input_msg, config.stdout_regex)
      end

      def stdout(input_msg, stdout_pattern)
        input_msg.gsub(stdout_pattern) do |stdout_match|
          <<-CODE_BLOCK

        ```
        #{last_stdout}
        ```

        CODE_BLOCK
        end
      end

      private def last_stdout
        @system_command_runner.last_stdout
      end
    end
  end
end
