require "./webpage_compressor"

require "./input_substitutor/stdout"
require "./input_substitutor/stderr"
require "./input_substitutor/command"
require "./input_substitutor/url"
require "./input_substitutor/file"

module ChatGPT
  class InputSubstitutor
    def initialize(@system_command_runner : SystemCommand)
    end
  end
end
