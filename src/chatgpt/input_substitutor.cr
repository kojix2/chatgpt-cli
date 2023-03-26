require "./webpage_compressor"

module ChatGPT
  class InputSubstitutor

    def initialize(@system_command_runner : SystemCommandRunner)
    end

    private def last_command
      @system_command_runner.last_command
    end

    private def last_stdout
      @system_command_runner.last_stdout
    end

    private def last_stderr
      @system_command_runner.last_stderr
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

    def file(input_msg, file_pattern)
      input_msg.gsub(file_pattern) do |file_match|
        file_pattern = $1.strip

        file_paths = Dir.glob(file_pattern)
        if file_paths.empty?
          STDERR.puts "Warning: No files found matching: #{file_pattern} leave it as it is".colorize(:yellow).mode(:bold)
          next file_match
        end

        content_blocks = file_paths.map do |file_path|
          extname = File.extname(file_path)
          basename = File.basename(file_path)
          begin
            contents = File.read(file_path)
          rescue ex
            # This should not happen because we already checked the file exists with Dir.glob
            STDERR.puts "Error: #{ex}\nFailed to read file: #{file_path}".colorize(:yellow).mode(:bold)
            contents = "# Error: Failed to read file: #{file_path}"
          end
          format_name = FILE_EXTENSIONS.fetch(extname, "")

          <<-CODE_BLOCK
          ### #{basename}

          ```#{format_name}
          #{contents}
          ```

          That's all for the #{basename}

          CODE_BLOCK
        end

        content_blocks.join("\n")
      end
    end

    def url(input_msg, url_pattern)
      input_msg.gsub(url_pattern) do |url_match|
        url = $1.strip
        url = "https://" + url unless url.starts_with?("http")
        begin
          response = HTTP::Client.get(url)
        rescue ex
          STDERR.puts "Warning: Failed to fetch url: #{url} leave it as it is".colorize(:yellow).mode(:bold)
          STDERR.puts ex.message.colorize(:yellow)
          next url_match
        end
        unless response.success?
          STDERR.puts "Warning: Failed to fetch url: #{url} leave it as it is".colorize(:yellow).mode(:bold)
          next url_match
        end
        compressed_text = words(Lexbor::Parser.new(HTTP::Client.get(url).body.to_s)).join("|")

        <<-CODE_BLOCK
        ### #{url}

        ```
        #{compressed_text}
        ```

        That's all for the #{url}
        CODE_BLOCK
      end
    end
  end
end
