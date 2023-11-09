require "./chatgpt/cli"

module ChatGPT
  DEBUG_FLAG = [false]

  def self.debug?
    DEBUG_FLAG.first
  end
end

ChatGPT::CLI.new.run
