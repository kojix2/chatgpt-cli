def run_magic_command(command, data)
  case command
  when "debug"
    DEBUG_FLAG[0] = !DEBUG_FLAG[0]
    puts "Debug mode: #{DEBUG_FLAG[0]}".colorize(:yellow)
  when "system"
    data.messages.each do |msg|
      if msg["role"] == "system"
        puts msg["content"].colorize(:yellow)
      end
    end
  when /system\s+(.+)/
    if data.messages.empty?
      data.messages << {"role" => "system", "content" => $1}
    elsif data.messages[0]["role"] == "system"
      data.messages[0]["content"] = $1
    else
      data.messages.unshift({"role" => "system", "content" => $1})
    end
    puts "Set system message to #{$1}".colorize(:yellow)
  when "clear"
    data.messages.clear
    puts "Cleared".colorize(:yellow)
  when "data"
    puts data.to_json.colorize(:yellow)
  when "saveall"
    File.write("chatgpt.json", data.to_json)
    puts "Saved to chatgpt.json".colorize(:yellow)
  when /save\s+(.+)/
    File.write($1, data.messages[-1]["content"])
    puts "Saved to #{$1}".colorize(:yellow)
  else
    STDERR.puts "Error: Unknown magic command: #{command}".colorize(:yellow).mode(:bold)
  end
end
