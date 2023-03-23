require "./postdata"

module ChatGPT
  class MagicCommand
    property :command
    property :data

    def initialize(@command : String, @data : PostData)
    end

    def run
      case command
      when "debug"
        debug_mode_toggle
      when "system"
        show_system_messages
      when /system\s+(.+)/
        set_system_messages($1)
      when "clear"
        clear_messages
      when "data"
        show_data_json
      when "saveall"
        save_all_to_json
      when /save\s+(.+)/
        save_to_file($1)
      else
        unknown_command_error
      end
    end

    private

    def debug_mode_toggle
      DEBUG_FLAG[0] = !DEBUG_FLAG[0]
      puts "Debug mode: #{DEBUG_FLAG[0]}".colorize(:yellow)
    end

    def show_system_messages
      data.messages.each do |msg|
        if msg["role"] == "system"
          puts msg["content"].colorize(:yellow)
        end
      end
    end

    def set_system_messages(message)
      if data.messages.empty?
        data.messages << {"role" => "system", "content" => message}
      elsif data.messages[0]["role"] == "system"
        data.messages[0]["content"] = message
      else
        data.messages.unshift({"role" => "system", "content" => message})
      end
      puts "Set system message to #{message}".colorize(:yellow)
    end

    def clear_messages
      data.messages.clear
      puts "Cleared".colorize(:yellow)
    end

    def show_data_json
      puts data.to_json.colorize(:yellow)
    end

    def save_all_to_json
      File.write("chatgpt.json", data.to_json)
      puts "Saved to chatgpt.json".colorize(:yellow)
    end

    def save_to_file(file_name)
      File.write(file_name, data.messages[-1]["content"])
      puts "Saved to #{file_name}".colorize(:yellow)
    end

    def unknown_command_error
      STDERR.puts "Error: Unknown magic command: #{command}".colorize(:yellow).mode(:bold)
    end
  end
end