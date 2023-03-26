require "./post_data"

module ChatGPT
  class MagicCommandRunner
    Table =
      [
        {
          "name"        => "debug",
          "description" => "Toggle debug mode",
          "pattern"     => "debug",
          "n_args"      => 0,
          "method"      => "debug_mode_toggle",
        },
        {
          "name"        => "system",
          "description" => "Show system messages",
          "pattern"     => "system",
          "n_args"      => 0,
          "method"      => "show_system_messages",
        },
        {
          "name"        => "system <message>",
          "description" => "Set system message",
          "pattern"     => /^system\s+(.+)/,
          "n_args"      => 1,
          "method"      => "set_system_messages",
        },
        {
          "name"        => "data",
          "description" => "Show or edit data in JSON",
          "pattern"     => "data",
          "n_args"      => 0,
          "method"      => "edit_data_json",
        },
        {
          "name"        => "clear",
          "description" => "Clear messages and initialize data",
          "pattern"     => "clear",
          "n_args"      => 0,
          "method"      => "clear_messages",
        },
        {
          "name"        => "write <file_name> or w <file_name>",
          "description" => "Write last message to <file_name>",
          "pattern"     => /^[write,w]\s+(.+)/,
          "n_args"      => 1,
          "method"      => "write_to_file",
        },
        {
          "name"        => "undo",
          "description" => "Undo last message and response",
          "pattern"     => "undo",
          "n_args"      => 0,
          "method"      => "undo",
        },
        {
          "name"        => "undo <n>",
          "description" => "Undo last <n> messages and responses",
          "pattern"     => /^undo\s+(\d+)/,
          "n_args"      => 1,
          "method"      => "undo",
        },
        {
          "name"        => "resume",
          "description" => "Resume from auto-saved data",
          "pattern"     => "resume",
          "n_args"      => 0,
          "method"      => "resume",
        },
        {
          "name"        => "save",
          "description" => "Save data to chatgpt-<timestamp>.json",
          "pattern"     => "save",
          "n_args"      => 0,
          "method"      => "save_data_to_json",
        },
        {
          "name"        => "save <file_name>",
          "description" => "Save data to <file_name>",
          "pattern"     => /^save\s+(.+)/,
          "n_args"      => 1,
          "method"      => "save_data_to_json",
        },
        {
          "name"        => "load",
          "description" => "Load latest saved data from current directory",
          "pattern"     => "load",
          "n_args"      => 0,
          "method"      => "load_data_from_json",
        },
        {
          "name"        => "load <file_name>",
          "description" => "Load data from <file_name>",
          "pattern"     => /^load\s+(.+)/,
          "n_args"      => 1,
          "method"      => "load_data_from_json",
        },
        {
          "name"        => "config",
          "description" => "Edit config file",
          "pattern"     => "config",
          "n_args"      => 0,
          "method"      => "show_config",
        },
        {
          "name"        => "response",
          "description" => "Show last response in JSON",
          "pattern"     => "response",
          "n_args"      => 0,
          "method"      => "show_response_json",
        },
        {
          "name"        => "tokens",
          "description" => "Show total tokens used",
          "pattern"     => /^tokens?\s*$/,
          "n_args"      => 0,
          "method"      => "show_total_tokens",
        },
        {
          "name"        => "help",
          "description" => "Show this help",
          "pattern"     => "help",
          "n_args"      => 0,
          "method"      => "show_help",
        },
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

    def edit_data_json
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

    def clear_messages
      data.messages.clear
      puts "Cleared".colorize(:yellow)
    end

    def resume
      if File.exists?(Config::POST_DATA_FILE)
        load_data_from_json(Config::POST_DATA_FILE)
      else
        puts "No saved data".colorize(:yellow)
      end
    end

    def undo
      undo(1)
    end

    def undo(n)
      n.to_i.times do
        data.messages.pop # response
        data.messages.pop # query
      end
      puts "Undo #{n == 1 ? "last" : n} messages".colorize(:yellow)
    end

    def save_data_to_json
      timestamp = Time.local.to_s("%Y%m%d-%H%M%S")
      file_name = "chatgpt-#{timestamp}.json"
      save_data_to_json(file_name)
    end

    def save_data_to_json(file_name)
      File.write(file_name, data.to_json)
      puts "Saved to #{file_name}".colorize(:yellow)
    end

    def load_data_from_json
      file_names = Dir.glob("chatgpt-*.json")
      if file_names.empty?
        puts "Error: No saved data".colorize(:yellow).mode(:bold)
        return
      end
      load_data_from_json(file_names.sort.last)
    end

    def load_data_from_json(file_name)
      begin
        new_data = PostData.from_json(File.read(file_name))
        @data = new_data
        puts "Loaded from #{file_name}".colorize(:yellow)
      rescue
        puts "Error: Invalid JSON".colorize(:yellow).mode(:bold)
      end
    end

    def write_to_file(file_name)
      last_response = data.messages.dig?(-1, "content").to_s
      File.write(file_name, last_response)
      puts "Writed to #{file_name}".colorize(:yellow)
    end

    def show_response_json
      open_editor(ChatGPT::Config::RESPONSE_FILE)
    end

    def show_total_tokens
      total_tokens = "0"
      begin
        File.open(ChatGPT::Config::RESPONSE_FILE, "r") do |file|
          total_tokens = JSON.parse(file).dig?("usage", "total_tokens") || 0
        end
      rescue ex
      end
      puts "Total tokens used: #{total_tokens}".colorize(:yellow)
    end

    def show_config
      open_editor(ChatGPT::Config::CONFIG_FILE)
    end

    def show_help
      puts "Magic commands:".colorize(:yellow).mode(:bold)
      Table.each do |value|
        puts "  % #{value["name"]}".colorize(:yellow).mode(:bold)
        puts "    #{value["description"]}".colorize(:yellow)
      end
    end

    def unknown_command_error(command)
      STDERR.puts "Error: Unknown magic command: #{command}".colorize(:yellow).mode(:bold)
    end

    private def open_editor(file_name)
      editor = ENV.has_key?("EDITOR") ? ENV["EDITOR"] : "vim"
      system("#{editor} #{file_name}")
    end
  end
end
