require "json"

module ChatGPT
  module CLI
    class Config
      CONFIG_BASE =
        if ENV.has_key?("CHATGPT_CLI_CONFIG")
          ENV["CHATGPT_CLI_CONFIG"]
        else
          "#{ENV["HOME"]}/.config/chatgpt-cli"
        end
      CONFIG_FILE  = "#{CONFIG_BASE}/config.json"
      HISTORY_FILE = "#{CONFIG_BASE}/history.json"

      alias ConfigData = Hash(String, Hash(String, Hash(String, String)))

      getter config_data : ConfigData

      def initialize
        @config_data = ConfigData.new
        @config_data["system_messages"] = Hash(String, Hash(String, String)).new
        load_config
      end

      def load_config
        if File.exists?(CONFIG_FILE)
          File.open(CONFIG_FILE) do |f|
            @config_data = ConfigData.from_json(f)
          end
        else
          create_default_config
          save
        end
      end

      def create_default_config
        add_system_message("translator", "I want you to act as an translator, spelling corrector and improver.")
        add_system_message("code", "I want you to act as a programmer, writing code.")
        add_system_message("poet", "I want you to act as a poet, writing poetry.")
        save
      end

      def select_id(id)
        @config_data.dig("system_messages", id).as(Hash(String, String))
      end

      def add_message(id, role, content)
        config_data["system_messages"][id] = {
          "role"    => role.to_s,
          "content" => content.to_s,
        }
      end

      def add_system_message(id, content)
        add_message(id, "system", content)
      end

      def save
        overwrite = File.exists?(CONFIG_FILE)
        File.write(CONFIG_FILE, config_data.to_json)
        STDERR.puts("#{overwrite ? "Overwrote" : "Created"} config at #{CONFIG_FILE}")
      end
    end
  end
end
