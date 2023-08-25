require "./input_substitutor/stdout"
require "./input_substitutor/stderr"
require "./input_substitutor/command"

{% unless env("CHATGPT_NO_URL") %}
  require "./input_substitutor/url"
{% end %}

require "./input_substitutor/file"

module ChatGPT
  class InputSubstitutor
    def initialize(@system_command_runner : SystemCommand)
    end
  end
end
