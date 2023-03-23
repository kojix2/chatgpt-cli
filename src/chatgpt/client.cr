require "http/client"

module ChatGPT
  class ApiKeyError < Exception; end

  class Client
    def initialize
      @headers = HTTP::Headers{
        "Authorization" => "Bearer #{get_api_key}",
        "Content-Type"  => "application/json",
      }
    end

    def get_api_key
      if ENV.has_key?("OPENAI_API_KEY")
        ENV["OPENAI_API_KEY"]
      else
        ApiKeyError.new("OPENAI_API_KEY is not set")
        exit 1
      end
    end

    def send_chat_request(data)
      if DEBUG_FLAG[0]
        STDERR.puts
        STDERR.puts "Sending request to #{API_ENDPOINT}".colorize(:cyan).mode(:bold)
        STDERR.puts data.pretty_inspect.colorize(:cyan)
        STDERR.puts
      end

      spinner_text = "ChatGPT".colorize(:green)
      sp = Spin.new(0.2, Spinner::Charset[:pulsate2], spinner_text, output: STDERR)
      sp.start
      response = HTTP::Client.post(API_ENDPOINT, body: data.to_json, headers: @headers)
      sp.stop

      if DEBUG_FLAG[0]
        STDERR.puts "Received response from #{API_ENDPOINT}".colorize(:cyan).mode(:bold)
        STDERR.puts "Response status: #{response.status}".colorize(:cyan)
        STDERR.puts "Response body: #{response.body}".colorize(:cyan)
        STDERR.puts
      end
      response
    end
  end
end
