module ChatGPT
  class InputSubstitutor
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
