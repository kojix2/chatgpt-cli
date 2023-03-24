require "./post_data"

module ChatGPT
  class MagicCommand
    Table =
      [
        {"command"     => "debug",
         "description" => "Toggle debug mode",
         "pattern"     => "debug",
         "n_args"      => 0,
         "method"      => "debug_mode_toggle"},
        {"command"     => "system",
         "description" => "Show system messages",
         "pattern"     => "system",
         "n_args"      => 0,
         "method"      => "show_system_messages"},
        {"command"     => "system <message>",
         "description" => "Set system message",
         "pattern"     => /system\s+(.+)/,
         "n_args"      => 1,
         "method"      => "set_system_messages"},
        {"command"     => "clear",
         "description" => "Clear messages",
         "pattern"     => "clear",
         "n_args"      => 0,
         "method"      => "clear_messages"},
        {"command"     => "data",
         "description" => "Show data in JSON",
         "pattern"     => "data",
         "n_args"      => 0,
         "method"      => "show_data_json"},
        {"command"     => "save <file_name>",
         "description" => "Save last message to <file_name>",
         "pattern"     => /save\s+(.+)/,
         "n_args"      => 1,
         "method"      => "save_to_file"},
        {"command"     => "saveall",
         "description" => "Save all messages to chatgpt.json",
         "pattern"     => "saveall",
         "n_args"      => 0,
         "method"      => "save_all_to_json"},
        {"command"     => "config",
         "description" => "Edit config file",
         "pattern"     => "config",
         "n_args"      => 0,
         "method"      => "show_config"},
        {"command"     => "help",
         "description" => "Show this help",
         "pattern"     => "help",
         "n_args"      => 0,
         "method"      => "show_help"},
      ]

    getter key : String
    property data : PostData

    def initialize(@data, @key = "%")
    end

    def try_run(msg, data)
      if /^%(?!\{|#{key})/.match msg
        cmd = msg[1..-1].strip
        run(cmd, data)
        @data
      else
        false
      end
    end

    def run(command : String, data : PostData)
      @data = data
      {% begin %}
      case command
      {% for value in Table %}
        when {{value["pattern"]}}
        {% if value["n_args"] == 0 %}
          {{value["method"].id}}
        {% else %}
          {{value["method"].id}}($1)
        {% end %}
      {% end %}
      else
        unknown_command_error(command)
      end
      {% end %}
    end

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
      new_data = data
      File.tempfile("chatgpt-cli", ".json") do |file|
        File.write(file.path, data.to_pretty_json)
        open_editor(file.path)
        begin
          new_data = PostData.from_json(File.read(file.path))
          puts "Saved".colorize(:yellow)
        rescue
          puts "Error: Invalid JSON".colorize(:yellow).mode(:bold)
        end
      end
      @data = new_data
    end

    def save_all_to_json
      File.write("chatgpt.json", data.to_json)
      puts "Saved to chatgpt.json".colorize(:yellow)
    end

    def save_to_file(file_name)
      File.write(file_name, data.messages[-1]["content"])
      puts "Saved to #{file_name}".colorize(:yellow)
    end

    def show_config
      open_editor(ChatGPT::Config::CONFIG_FILE)
    end

    def show_help
      puts "Magic commands:".colorize(:yellow).mode(:bold)
      Table.each do |value|
        puts "  #{value["command"]}".colorize(:yellow).mode(:bold)
        puts "    #{value["description"]}".colorize(:yellow)
      end
    end

    def unknown_command_error(command)
      STDERR.puts "Error: Unknown magic command: #{command}".colorize(:yellow).mode(:bold)
    end

    def open_editor(file_name)
      editor = ENV.has_key?("EDITOR") ? ENV["EDITOR"] : "vim"
      system("#{editor} #{file_name}")
    end
  end
end
