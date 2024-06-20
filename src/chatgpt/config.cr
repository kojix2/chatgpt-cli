require "json"
require "csv"

# Do not use _colorize in this file.
# Because _colorize uses Config, and calling _colorize in Config causes infinite loop.

module ChatGPT
  class Config
    BASE_DIR =
      if ENV.has_key?("CHATGPT_CLI_CONFIG")
        ENV["CHATGPT_CLI_CONFIG"]
      elsif ENV.has_key?("HOME")
        "#{ENV["HOME"]}/.config/chatgpt-cli"
      else
        raise "Please set CHATGPT_CLI_CONFIG environment variable."
      end
    CONFIG_FILE    = "#{BASE_DIR}/config.json"
    PROMPTS_FILE   = "#{BASE_DIR}/prompts.csv"
    POST_DATA_FILE = "#{BASE_DIR}/post_data.json"
    HISTORY_FILE   =
      if ENV.has_key?("HOME")
        "#{ENV["HOME"]}/.chatgpt_history"
      else # especially for Windows
        "#{BASE_DIR}/chatgpt_history"
      end

    DEFAULT_CONFIG  = {{ read_file "#{__DIR__}/../../config.json" }}
    DEFAULT_PROMPTS = {{ read_file "#{__DIR__}/../../awesome-chatgpt-prompts/prompts.csv" }}

    alias ConfigData = Hash(String, Hash(String, Hash(String, String)))

    class NoPromptIdError < Exception; end

    getter config_data : ConfigData
    getter prompts : Hash(String, String)

    def self.instance
      @@instance ||= new
    end

    def initialize
      @config_data = ConfigData.new
      @config_data_default = ConfigData.from_json(DEFAULT_CONFIG)
      @prompts = Hash(String, String).new
      load_config
      load_prompts
      log_deporecation_warnings
    end

    def load_config
      create_default_config unless File.exists?(CONFIG_FILE)
      begin
        File.open(CONFIG_FILE) do |f|
          @config_data = ConfigData.from_json(f)
        end
      rescue ex
        log_load_error(ex, CONFIG_FILE)
      end
    end

    def load_prompts
      create_default_prompts unless File.exists?(PROMPTS_FILE)
      begin
        File.open(PROMPTS_FILE) do |f|
          CSV.each_row(f) do |row|
            next if row == ["act", "prompt"]
            @prompts[row[0]] = row[1]
          end
        end
      rescue ex
        log_load_error(ex, PROMPTS_FILE)
      end
    end

    private def log_load_error(ex, file)
      STDERR.puts("Error: #{ex}".colorize(:red))
      STDERR.puts("Failed to load #{file}")
    end

    private def log_deporecation_warnings
      if @config_data.has_key?("system_messages")
        STDERR.puts(
          "Warning: system_messages in config.json is deprecated. \n" +
          "Please remove them from config.json and use prompts.csv instead."
        )
      end
    end

    def create_default_config
      @config_data = ConfigData.from_json(DEFAULT_CONFIG)
      overwrite = File.exists?(CONFIG_FILE)
      File.write(CONFIG_FILE, config_data.to_pretty_json)
      STDERR.puts("#{overwrite ? "Overwrote" : "Created"} config at #{CONFIG_FILE}"._colorize(:warning))
    end

    def create_default_prompts
      overwrite = File.exists?(PROMPTS_FILE)
      File.write(PROMPTS_FILE, DEFAULT_PROMPTS)
      STDERR.puts("#{overwrite ? "Overwrote" : "Created"} prompts at #{PROMPTS_FILE}"._colorize(:warning))
    end

    def select_id(id)
      if @prompts.has_key?(id)
        prompt = @prompts[id]
      elsif id =~ /^[0-9]+$/
        prompt = @prompts.values[id.to_i]
        key = @prompts.keys[id.to_i]
        STDERR.puts key._colorize(:warning)
      else
        raise NoPromptIdError.new("No such prompt id: \"#{id}\"")
      end
      {"role" => "system", "content" => prompt}
    end

    def terminal_colors
      default = @config_data_default["terminal_colors"]
      @config_data.fetch("terminal_colors", default)
    end

    def color(id : Symbol)
      default = @config_data_default["terminal_colors"][id.to_s]
      terminal_colors.fetch(id.to_s, default)
    end

    def embedded_patterns
      default = @config_data_default["embedded_patterns"]
      @config_data.fetch("embedded_patterns", default)
    end

    def embedded_pattern(id : Symbol)
      default = @config_data_default["embedded_patterns"][id.to_s]
      embedded_patterns.fetch(id.to_s, default)
    end

    def stdout_pattern
      Regex.new(embedded_pattern(:stdout)["pattern"])
    end

    def stderr_pattern
      Regex.new(embedded_pattern(:stderr)["pattern"])
    end

    def command_pattern
      Regex.new(embedded_pattern(:command)["pattern"])
    end

    def filepath_pattern
      Regex.new(embedded_pattern(:file)["pattern"])
    end

    def extraction_patterns
      default = @config_data_default["extraction pattern"]
      @config_data.fetch("extraction pattern", default)
    end

    def extraction_pattern(id : Symbol)
      default = @config_data_default["extraction pattern"][id.to_s]
      extraction_patterns.fetch(id.to_s, default)
    end

    def code_block_pattern
      Regex.new(extraction_pattern(:code_block)["pattern"], Regex::CompileOptions::MULTILINE)
    end
  end
end
