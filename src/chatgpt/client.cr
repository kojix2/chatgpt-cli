require "http/client"

module ChatGPT
  class ApiKeyError < Exception; end

  class Client
    API_ENDPOINT = "https://api.openai.com/v1/chat/completions"

    def initialize
      @http_headers = HTTP::Headers{
        "Authorization" => "Bearer #{fetch_api_key}",
        "Content-Type"  => "application/json",
      }
    end

    def fetch_api_key
      if ENV.has_key?("OPENAI_API_KEY")
        ENV["OPENAI_API_KEY"]
      else
        ApiKeyError.new("OPENAI_API_KEY is not set")
        exit 1
      end
    end

    def send_chat_request(request_data)
      if DEBUG_FLAG[0]
        STDERR.puts
        STDERR.puts "Sending request to #{API_ENDPOINT}".colorize(:cyan).mode(:bold)
        STDERR.puts request_data.pretty_inspect.colorize(:cyan)
        STDERR.puts
      end

      spinner_text = "ChatGPT".colorize(:green)
      spinner = Spin.new(0.2, Spinner::Charset[:pulsate2], spinner_text, output: STDERR)
      spinner.start
      begin
        chat_response = HTTP::Client.post(API_ENDPOINT, body: request_data.to_json, headers: @http_headers)
      rescue error
        STDERR.puts "Error: #{error} #{error.message}".colorize(:red)
        exit 1
      end
      spinner.stop

      if DEBUG_FLAG[0]
        STDERR.puts "Received response from #{API_ENDPOINT}".colorize(:cyan).mode(:bold)
        STDERR.puts "Response status: #{chat_response.status}".colorize(:cyan)
        STDERR.puts "Response body: #{chat_response.body}".colorize(:cyan)
        STDERR.puts
      end
      chat_response
    end
  end
end