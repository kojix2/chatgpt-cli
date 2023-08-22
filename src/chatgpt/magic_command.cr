require "./post_data"
require "./response_data"
require "./html_generator"

require "./magic_command/table"

require "./magic_command/debug"
require "./magic_command/model"
require "./magic_command/system"
require "./magic_command/edit"
require "./magic_command/html"
require "./magic_command/clear"
require "./magic_command/undo"
require "./magic_command/write"
require "./magic_command/shift"
require "./magic_command/resume"
require "./magic_command/save"
require "./magic_command/load"
require "./magic_command/config"
require "./magic_command/response"
require "./magic_command/tokens"
require "./magic_command/history"
require "./magic_command/webapp"
require "./magic_command/chdir"
require "./magic_command/help"

module ChatGPT
  class MagicCommand
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
