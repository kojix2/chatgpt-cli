module ChatGPT
  class MagicCommand
    class Base
      getter sender : MagicCommand
      getter name : String
      getter description : String
      getter patterns : Array(Regex)

      delegate data, to: @sender
      delegate :data=, to: @sender
      delegate response_data, to: @sender
      delegate :total_tokens=, to: @sender

      def initialize(sender : MagicCommand)
        @name = ""
        @description = ""
        @patterns = [/(?!)/] # never match
        @sender = sender
      end

      def try_run(command) : Bool
        patterns.each do |pattern|
          if pattern =~ command
            if $1?
              run($1)
            else
              run()
            end
          end
        end
        false
      end

      def run
        raise NotImplementedError.new("Do not call MagicCommand::Base#run directly")
        false
      end

      def run(dummy)
        raise NotImplementedError.new("Do not call MagicCommand::Base#run directly")
        false
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

      # FIXME: refactor
      private def load_data_from_json(file_name)
        begin
          new_data = PostData.from_json(File.read(file_name))
          data = new_data
          puts "Loaded from #{file_name}"._colorize(:warning)
        rescue
          puts "Error: Invalid JSON"._colorize(:warning, :bold)
        end
        total_tokens = -1
        true
      end
    end
  end
end
