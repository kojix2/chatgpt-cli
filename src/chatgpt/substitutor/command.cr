require "./base"

module ChatGPT
  class Substitutor
    class Command < Base
      def substitute(input_msg)
        command(input_msg, Config.instance.command_pattern)
      end

      def command(input_msg, command_pattern)
        input_msg.gsub(command_pattern) do |command_match|
          command_pattern = $1.strip
          command_output = run_command(command_pattern)
        end
      end

      # Mix stderror and stdout
      # MEMO: should be move to SystemComannd class?
      private def run_command(command)
        std_oe = IO::Memory.new
        begin
          status = Process.run(command, shell: true, output: std_oe, error: std_oe)
          unless status.success?
            STDERR.puts "Warning: failed(#{status.exit_code}): #{command}"._colorize(:warning, :bold)
          end
        rescue ex
          STDERR.puts "Error: Failed to run command: #{command}"._colorize(:warning, :bold)
        end
      end
    end
  end
end
