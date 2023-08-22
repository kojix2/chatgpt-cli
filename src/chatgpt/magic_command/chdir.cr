module ChatGPT
  class MagicCommand
    def change_directory(path)
      begin
        Dir.cd(path)
        puts "#{Dir.current}"._colorize(:warning)
      rescue e
        p e
        puts "Invalid path"._colorize(:warning)
      end
      true
    end
  end
end
