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
    end
  end
end
