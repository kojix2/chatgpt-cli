require "./post_data"
require "./response_data"
require "./html_generator"

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
          "name"        => "model",
          "description" => "Show model name",
          "pattern"     => "model",
          "n_args"      => 0,
          "method"      => "show_model_name",
        },
        {
          "name"        => "model <model_name>",
          "description" => "Set model name",
          "pattern"     => /^model\s+(.+)/,
          "n_args"      => 1,
          "method"      => "set_model_name",
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
          "name"        => "edit",
          "description" => "Show or edit data in JSON",
          "pattern"     => "edit",
          "n_args"      => 0,
          "method"      => "edit_data_json",
        },
        {
          "name"        => "html",
          "description" => "Show data in the browser",
          "pattern"     => "html",
          "n_args"      => 0,
          "method"      => "html_data",
        },
        {
          "name"        => "html <file_name>",
          "description" => "Save data to <file_name> and open in the browser",
          "pattern"     => /^html\s+(.+)/,
          "n_args"      => 1,
          "method"      => "html_data",
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
          "name"        => "history",
          "description" => "Show history",
          "pattern"     => "history",
          "n_args"      => 0,
          "method"      => "show_history",
        },
        {
          "name"        => "webapp",
          "description" => "Open ChatGPT webapp",
          "pattern"     => "webapp",
          "n_args"      => 0,
          "method"      => "open_webapp",
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
    getter response_data : ResponseData
    getter total_tokens : Int32

    def initialize(data = nil, @key = "%")
      @data = data || PostData.new
      @next = false
      @response_data = ResponseData.new("{}")
      @total_tokens = -1
    end

    def try_run(msg, data, response_data, total_tokens)
      @total_tokens = total_tokens
      if /^%(?!\{|#{key})/.match msg
        cmd = msg[1..-1].strip
        @next = run(cmd, data, response_data)
        true
      else
        false
      end
    end

    def next?
      @next
    end

    def run(command : String, @data, @response_data) : Bool
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
      puts "Debug mode: #{DEBUG_FLAG[0]}"._colorize(:warning)
      true
    end

    def show_model_name
      puts "Model: #{data.model}"._colorize(:warning)
      true
    end

    def set_model_name(model_name)
      data.model = model_name
      puts "Set model to #{model_name}"._colorize(:warning)
      true
    end

    def show_system_messages
      data.messages.each do |msg|
        if msg["role"] == "system"
          puts msg["content"]._colorize(:warning)
        end
      end
      true
    end

    def set_system_messages(message)
      if data.messages.empty?
        data.add_message("system", message)
      elsif data.messages[0]["role"] == "system"
        data.messages[0]["content"] = message
      else
        data.messages.unshift({"role" => "system", "content" => message})
      end
      puts "Set system message to #{message}"._colorize(:warning)
      @total_tokens = -1
      true
    end

    def edit_data_json
      new_data = data
      File.tempfile("chatgpt-cli", ".json") do |file|
        File.write(file.path, data.to_pretty_json)
        open_editor(file.path)
        begin
          new_data = PostData.from_json(File.read(file.path))
          puts "Saved"._colorize(:warning)
        rescue
          puts "Error: Invalid JSON"._colorize(:warning, :bold)
        end
      end.delete
      @data = new_data
      @total_tokens = -1
      true
    end

    def html_data
      html = HtmlGenerator.new(data).to_s
      timestamp = Time.local.to_s("%Y%m%d-%H%M%S")
      file_name = "chatgpt-#{timestamp}.html"
      html_data(file_name)
    end

    def html_data(file_name)
      html = HtmlGenerator.new(data).to_s
      File.write(file_name, html)
      open_browser(file_name)
      # file.delete   # FIXME: delete file
      true
    end

    def clear_messages
      data.messages.clear
      puts "Cleared"._colorize(:warning)
      @total_tokens = -1
      true
    end

    def resume
      if File.exists?(Config::POST_DATA_FILE)
        load_data_from_json(Config::POST_DATA_FILE)
      else
        puts "No saved data"._colorize(:warning)
      end
      @total_tokens = -1
      true
    end

    def undo
      undo(1)
      @total_tokens = -1
      true
    end

    def undo(n)
      number_of_user_messages = data.count_user_messages
      n = [n.to_i, number_of_user_messages].min
      n.times do
        data.messages.pop # response
        data.messages.pop # query
      end
      puts "Undo #{n == 1 ? "last" : n} messages"._colorize(:warning)
      @total_tokens = -1
      true
    end

    def save_data_to_json
      timestamp = Time.local.to_s("%Y%m%d-%H%M%S")
      file_name = "chatgpt-#{timestamp}.json"
      save_data_to_json(file_name)
      true
    end

    def save_data_to_json(file_name)
      File.write(file_name, data.to_pretty_json)
      puts "Saved to #{file_name}"._colorize(:warning)
      true
    end

    def load_data_from_json
      file_names = Dir.glob("chatgpt-*.json")
      if file_names.empty?
        puts "Error: No saved data"._colorize(:warning, :bold)
        return true
      end
      load_data_from_json(file_names.sort.last)
      true
    end

    def load_data_from_json(file_name)
      begin
        new_data = PostData.from_json(File.read(file_name))
        @data = new_data
        puts "Loaded from #{file_name}"._colorize(:warning)
      rescue
        puts "Error: Invalid JSON"._colorize(:warning, :bold)
      end
      @total_tokens = -1
      true
    end

    def write_to_file(file_name)
      last_response = data.messages.dig?(-1, "content").to_s
      File.write(file_name, last_response)
      puts "Writed to #{file_name}"._colorize(:warning)
      true
    end

    def show_response_json
      File.tempfile("chatgpt-cli", ".json") do |file|
        File.write(file.path, response_data.to_pretty_json)
        open_editor(file.path)
      end.delete
      true
    end

    def show_total_tokens
      begin
        tokens = response_data.tokens
      rescue ex
        tokens = "Unknown"
      end
      puts "#{tokens}"._colorize(:warning)
      true
    end

    def show_history
      open_editor(Config::HISTORY_FILE)
      true
    end

    def show_config
      open_editor(Config::CONFIG_FILE)
      true
    end

    def open_webapp
      open_browser("https://chat.openai.com/")
      true
    end

    def show_help
      puts "Magic commands:"._colorize(:warning, :bold)
      Table.each do |value|
        puts "  % #{value["name"]}"._colorize(:warning, :bold)
        puts "    #{value["description"]}"._colorize(:warning)
      end
      true
    end

    def unknown_command_error(command)
      STDERR.puts "Error: Unknown magic command: #{command}"._colorize(:warning, :bold)
      true
    end

    private def open_editor(file_name)
      editor = ENV.has_key?("EDITOR") ? ENV["EDITOR"] : "vim"
      system("#{editor} #{file_name}")
    end

    private def open_browser(file_name)
      {% if flag?(:linux) %}
        system("xdg-open #{file_name}")
      {% elsif flag?(:darwin) %}
        system("open #{file_name}")
      {% elsif flag?(:win32) %}
        system("start #{file_name}")
      {% end %}
    end
  end
end
