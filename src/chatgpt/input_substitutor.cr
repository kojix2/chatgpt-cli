require "./webpage_compressor"

module ChatGPT
  class InputSubstitutor
    def self.file_substitution(file_match)
      file_pattern = file_match[2..-2].strip
      file_paths = Dir.glob(file_pattern)

      if file_paths.empty?
        STDERR.puts "Warning: No files found matching: #{file_pattern} leave it as it is".colorize(:yellow).mode(:bold)
        return file_match
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
        format_name = ChatGPT::FILE_EXTENSIONS.fetch(extname, "")

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

    def self.url_substitution(url_match)
      url = url_match[3..-2].strip
      url = "https://" + url unless url.starts_with?("http")
      compressed_text = words(Lexbor::Parser.new(HTTP::Client.get(url).body.to_s)).join("|")

      <<-CODE_BLOCK
      ### #{url}

      ```
      #{compressed_text}
      ```

      That's all for the #{url}
      CODE_BLOCK
    end

    def self.stdout_substitution(stdout_match, system_command, stdout)
      <<-CODE_BLOCK

      ```
      #{stdout}
      ```

      CODE_BLOCK
    end

    def self.stderr_substitution(stderr_match, system_command, stderr)
      <<-CODE_BLOCK

      command: `#{system_command}`
  
      ```error
       #{stderr}
      ```

      CODE_BLOCK
    end
  end
end
