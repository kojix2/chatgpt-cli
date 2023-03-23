require "json"

module ChatGPT
  module CLI
    class Config
      CONFIG_FILE =
        if ENV.has_key?("CHATGPT_CLI_CONFIG_FILE")
          ENV["CHATGPT_CLI_CONFIG_FILE"]
        else
          "#{ENV["HOME"]}/.chatgpt-cli/config.yml"
        end
      
      getter config_data : Hash(String, Hash(String, String))

      def initialize
        @config_data = Hash(String, Hash(String, String)).new
        validate_config_data
        save unless File.exists?(CONFIG_FILE)
        File.open(CONFIG_FILE) do |file|
          @config_data = @config_data.class.from_json(file)
        end
      end

      def select_id(id)
        if config_data.nil?
          return nil
        else
          message = config_data.dig("system_messages", id)
          if message
            {
              "role"    => message["role"].to_s,
              "content" => message["content"].to_s,
            }
          end
        end
      end

      def save
        validate_config_data
        overwrite = File.exists?(CONFIG_FILE)
        File.write(CONFIG_FILE, config_data.to_json)
        if overwrite
          STDERR.puts "Overwrote config to #{CONFIG_FILE}"
        else
          STDERR.puts "Created config at #{CONFIG_FILE}"
        end
      end

      def add_system_message(id, content)
        add_message(id, "system", content)
      end

      def add_message(id, role, content)
        
        config_data["system_messages"][id] = {
          "role"    => role,
          "content" => content,
        }
      end

      def validate_config_data
        unless config_data.has_key?("system_messages")
          config_data["system_messages"] = Hash(String, String).new
        end
      end
    end
  end
end
