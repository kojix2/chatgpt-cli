require "./chatgpt/cli"

module ChatGPT
  DEBUG_FLAG = [false]
end

ChatGPT::CLI.new.run