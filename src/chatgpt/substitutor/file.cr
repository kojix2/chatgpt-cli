require "./base"
require "./file_extensions"

module ChatGPT
  class Substitutor
    class FilePath < Base
      def substitute(input_msg)
        file(input_msg, Config.instance.file_regex)
      end

      def file(input_msg, file_pattern)
        input_msg.gsub(file_pattern) do |file_match|
          file_pattern = $1.strip
          formatted_file_contents = get_formatted_file_contents(file_match, file_pattern)
          if formatted_file_contents.is_a?(Array)
            formatted_file_contents.join("\n")
          else
            formatted_file_contents # It's a string (file_match)
          end
        end
      end

      private def get_formatted_file_contents(file_match, file_pattern)
        file_paths = Dir.glob(file_pattern)
        if file_paths.empty?
          STDERR.puts "Warning: No files found matching: #{file_pattern} leave it as it is"._colorize(:warning, :bold)
          return file_match
        end

        file_paths.map do |file_path|
          extname = File.extname(file_path)
          basename = File.basename(file_path)
          begin
            contents = File.read(file_path)
          rescue ex
            # This should not happen because we already checked the file exists with Dir.glob
            STDERR.puts "Error: #{ex}\nFailed to read file: #{file_path}"._colorize(:warning, :bold)
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
      end
    end
  end
end
