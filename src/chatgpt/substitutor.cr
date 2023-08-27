require "./substitutor/stdout"
require "./substitutor/stderr"
require "./substitutor/command"

{% unless env("CHATGPT_NO_URL") %}
  require "./substitutor/url"
{% end %}

require "./substitutor/file"

module ChatGPT
  class Substitutor
    def initialize(@system_command_runner : SystemCommand)
      @substitutors = [] of ChatGPT::Substitutor::Base
      @substitutors << ChatGPT::Substitutor::Stdout.new(@system_command_runner)
      @substitutors << ChatGPT::Substitutor::Stderr.new(@system_command_runner)
      @substitutors << ChatGPT::Substitutor::Command.new
      {% unless env("CHATGPT_NO_URL") %}
        @substitutors << ChatGPT::Substitutor::Url.new
      {% end %}
      @substitutors << ChatGPT::Substitutor::FilePath.new
    end

    def substitute(input_msg, config)
      @substitutors.each do |substitutor|
        input_msg = substitutor.substitute(input_msg, config)
      end
      input_msg
    end
  end
end
