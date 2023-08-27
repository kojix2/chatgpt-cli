module ChatGPT
  class Substitutor
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
