require "./post_data"
require "./response_data"
require "./html_generator"

require "./magic/debug"
require "./magic/model"
require "./magic/system"
require "./magic/edit"
require "./magic/html"
require "./magic/clear"
require "./magic/undo"
require "./magic/write"
require "./magic/shift"
require "./magic/resume"
require "./magic/save"
require "./magic/load"
require "./magic/config"
require "./magic/response"
require "./magic/tokens"
require "./magic/history"
require "./magic/webapp"
require "./magic/cd"
require "./magic/help"

module ChatGPT
  class Magic
    getter key : String
    property data : PostData
    getter response_data : ResponseData
    getter total_tokens : Int32
    getter commands : Array(ChatGPT::Magic::Base)
    getter result : Bool

    def initialize(data = nil, @key = "%")
      @data = data || PostData.new
      @response_data = ResponseData.new("{}")
      @result = false
      @total_tokens = -1
      @commands = [] of ChatGPT::Magic::Base
      {% for i in ChatGPT::Magic.constants.reject { |i| i == "Base" } %}
          @commands << {{i}}.new(self)
      {% end %}
    end

    def try_run(msg, data, response_data, total_tokens)
      @result = false
      @total_tokens = total_tokens
      if /^%(?!\{|#{key})/.match msg
        cmd = msg[1..-1].strip
        @result = run(cmd, data, response_data)
        true
      else
        false
      end
    end

    def run(command : String, @data, @response_data) : Bool
      @commands.each do |cmd|
        if cmd.patterns.any? { |pat| pat.match(command) }
          return cmd.try_run(command)
        end
      end
      unknown_command_error(command)
    end

    def unknown_command_error(command)
      STDERR.puts "Error: Unknown magic command: #{command}"._colorize(:warning, :bold)
      false
    end
  end
end
