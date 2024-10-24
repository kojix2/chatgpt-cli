require "./chatgpt/cli"

module ChatGPT
  class_property? debug : Bool = false
end

ChatGPT::CLI.new.run
