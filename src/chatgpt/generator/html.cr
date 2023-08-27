require "ecr"
require "./message"

module ChatGPT
  class Generator::Html
    @messages : Array(Message)

    def initialize(data)
      @messages = data.messages.map do |message|
        Message.new(message)
      end
    end

    ECR.def_to_s "#{__DIR__}/template.html.ecr"
  end
end
