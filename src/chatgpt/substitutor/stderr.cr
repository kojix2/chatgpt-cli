require "./base"

module ChatGPT
  class Substitutor
    class Stderr < Base
      def initialize(@system_command_runner : SystemCommand)
      end

      def substitute(input_msg)
        stderr(input_msg, Config.instance.stderr_pattern)
      end

      def stderr(input_msg, stderr_pattern)
        input_msg.gsub(stderr_pattern) do |stderr_match|
          <<-CODE_BLOCK

        command: `#{last_command}`

        ```
        #{last_stderr}
        ```

        CODE_BLOCK
        end
      end

      private def last_command
        @system_command_runner.last_command
      end

      private def last_stderr
        @system_command_runner.last_stderr
      end
    end
  end
end
