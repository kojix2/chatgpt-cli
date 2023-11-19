require "../utils/launcher"

module ChatGPT
  class Magic
    class Base
      getter sender : Magic
      getter name : String
      getter description : String
      getter patterns : Array(Regex)

      delegate data, to: @sender
      delegate :data=, to: @sender
      delegate response_data, to: @sender
      delegate :total_tokens=, to: @sender

      def initialize(sender : Magic)
        @name = ""
        @description = ""
        @patterns = [/(?!)/] # never match
        @sender = sender
      end

      def try_run(command) : Bool
        patterns.each do |pattern|
          if pattern =~ command
            if $1?
              return run($1)
            else
              return run()
            end
          end
        end
        false
      end

      def run
        raise NotImplementedError.new("Do not call Magic::Base#run directly")
        false
      end

      def run(dummy)
        raise NotImplementedError.new("Do not call Magic::Base#run directly")
        false
      end

      include ChatGPT::Launcher

      private def get_message(n : Int32)
        msg_count = data.messages.size
        if (n >= msg_count || n < -msg_count)
          puts "Invalid index: #{n}"._colorize(:warning)
          return nil
        end
        message = data.messages[n]
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
