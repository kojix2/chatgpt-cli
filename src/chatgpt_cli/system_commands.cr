def run_system_command(command)
  output = `#{command}`
  if $?.success?
    puts output.colorize(:yellow)
  else
    STDERR.puts "Error: Command failed: #{command}".colorize(:yellow).mode(:bold)
    STDERR.puts output.colorize(:yellow)
  end
end
