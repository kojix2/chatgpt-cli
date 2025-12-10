require "json"

module ChatGPT
  class ResponseData
    def initialize(data)
      @data = JSON.parse(data)
    end

    def tokens
      usage = @data["usage"]?
      return usage.to_pretty_json if usage

      # Fallback for legacy chat completions shape
      @data.dig("usage").to_pretty_json
    end

    def total_tokens
      @data.dig("usage", "total_tokens").to_s.to_i
    end

    def to_pretty_json
      @data.to_pretty_json
    end

    def assistant_message
      # Prefer Responses API shape if present, otherwise fall back to
      # Chat Completions JSON.
      message_from_responses || message_from_chat_completions
    end

    private def message_from_responses
      output = @data["output"]?
      return nil unless output && output.as_a?

      first_message = output.as_a.find do |item|
        item["type"]? == "message" && item["role"]? == "assistant"
      end
      first_message ||= output.as_a.first?
      return nil unless first_message

      content = first_message["content"]?
      return nil unless content && content.as_a?

      text_part = content.as_a.find { |part| part["text"]? }
      text_part ||= content.as_a.first?
      return nil unless text_part

      text_part["text"]?.to_s
    end

    private def message_from_chat_completions
      @data.dig?("choices", 0, "message", "content").to_s
    end
  end
end
