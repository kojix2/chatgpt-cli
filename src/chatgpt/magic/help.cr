require "./base"

module ChatGPT
  class Magic
    class Help < Base
      def initialize(sender)
        @sender = sender
        @name = "help"
        @description = "Show this help"
        @patterns = [/\Ahelp\E/]
      end

      def run
        puts "Magic commands:"._colorize(:warning, :bold)
        # Table.each do |value|
        #   next if value.fetch("show_help", true) == false
        #   puts "  % #{value["name"]}"._colorize(:warning, :bold)
        #   puts "    #{value["description"]}"._colorize(:warning)
        # end
        sender.commands.each do |command|
          puts "  % #{command.name}"._colorize(:warning, :bold)
          puts "    #{command.description}"._colorize(:warning)
        end
        true
      end
    end
  end
end
