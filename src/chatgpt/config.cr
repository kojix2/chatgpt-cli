require "json"

module ChatGPT
  class Config
    BASE_DIR =
      if ENV.has_key?("CHATGPT_CLI_CONFIG")
        ENV["CHATGPT_CLI_CONFIG"]
      else
        "#{ENV["HOME"]}/.config/chatgpt-cli"
      end
    CONFIG_FILE    = "#{BASE_DIR}/config.json"
    POST_DATA_FILE = "#{BASE_DIR}/post_data.json"
    HISTORY_FILE   = "#{ENV["HOME"]}/.chatgpt_history"

    DEFAULT_CONFIG = {{ `cat #{__DIR__}/../../config.json`.chomp.stringify }}

    alias ConfigData = Hash(String, Hash(String, Hash(String, String)))

    getter config_data : ConfigData

    def self.instance
      @@instance ||= new
    end

    def initialize
      @config_data = ConfigData.new
      @config_data["system_messages"] = Hash(String, Hash(String, String)).new
      @config_data_default = ConfigData.from_json(DEFAULT_CONFIG)
      load_config
    end

    def load_config
      if File.exists?(CONFIG_FILE)
        begin
          File.open(CONFIG_FILE) do |f|
            @config_data = ConfigData.from_json(f)
          end
        rescue ex
          STDERR.puts("Error: #{ex}".colorize(:red))
          STDERR.puts("Failed to load config at #{CONFIG_FILE}")
        end
      else
        create_default_config
      end
    end

    def create_default_config
      @config_data = ConfigData.from_json(DEFAULT_CONFIG)
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
      File.write(CONFIG_FILE, config_data.to_pretty_json)
      STDERR.puts("#{overwrite ? "Overwrote" : "Created"} config at #{CONFIG_FILE}")
    end

    def terminal_colors
      default = @config_data_default["terminal_colors"]
      @config_data.fetch("terminal_colors", default)
    end

    def color(id : Symbol)
      default = @config_data_default["terminal_colors"][id.to_s]
      terminal_colors.fetch(id.to_s, default)
    end
  end
end
