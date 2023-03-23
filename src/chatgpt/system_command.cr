module ChatGPT
  class SystemCommand
    property :command

    def initialize(@command : String)
    end

    def run
      output = `#{command}`
      if $?.success?
        puts output.colorize(:yellow)
      else
        STDERR.puts "Error: Command failed: #{command}".colorize(:yellow).mode(:bold)
        STDERR.puts output.colorize(:yellow)
      end
    end
  end
end
