require "ecr"
require "./html_generator/message"

module ChatGPT
  class HtmlGenerator

    @messages : Array(Message)

    def initialize(data)
      @messages = data.messages.map do |message|
        Message.new(message)
      end
    end

    ECR.def_to_s "#{__DIR__}/html_generator/output.html.ecr"
  end
end
