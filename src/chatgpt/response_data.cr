require "json"

module ChatGPT
  class ResponseData
    def initialize(data)
      @data = JSON.parse(data)
    end

    def tokens
      @data["usage"].to_pretty_json
    end

    def total_tokens
      @data.dig("usage", "total_tokens").to_s.to_i
    end

    def to_pretty_json
      @data.to_pretty_json
    end

    def assistant_message
      @data.dig("choices", 0, "message", "content").to_s
    end
  end
end