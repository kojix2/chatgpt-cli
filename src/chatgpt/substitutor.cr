require "./substitutor/stdout"
require "./substitutor/stderr"
require "./substitutor/command"

require "./substitutor/file"

module ChatGPT
  class Substitutor
    def initialize(@system_command_runner : SystemCommand)
      @substitutors = [] of ChatGPT::Substitutor::Base
      @substitutors << ChatGPT::Substitutor::Stdout.new(@system_command_runner)
      @substitutors << ChatGPT::Substitutor::Stderr.new(@system_command_runner)
      @substitutors << ChatGPT::Substitutor::Command.new
      @substitutors << ChatGPT::Substitutor::FilePath.new
    end

    def substitute(input_msg)
      @substitutors.each do |substitutor|
        input_msg = substitutor.substitute(input_msg)
      end
      input_msg
    end
  end
end
