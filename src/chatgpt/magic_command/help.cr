module ChatGPT
  class MagicCommand
    def show_help
      puts "Magic commands:"._colorize(:warning, :bold)
      Table.each do |value|
        next if value.fetch("show_help", true) == false
        puts "  % #{value["name"]}"._colorize(:warning, :bold)
        puts "    #{value["description"]}"._colorize(:warning)
      end
      true
    end
  end
end
