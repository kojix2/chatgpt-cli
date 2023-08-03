require "./utils/proxy"
require "openai"

module ChatGPT
  # Define custom exceptions for API key errors and SIGINT signals
  class ApiKeyError < Exception; end

  class SigIntError < Exception; end

  # Define the Client class that handles communication with the ChatGPT API
  class Client
    # Initialize the Client object by building the required HTTP headers
    def initialize
      @openai = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
    end

    # Send a chat request to the ChatGPT API and log the request and response data if in debug mode
    def send_chat_request(request_data)
      @openai.chat("gpt-3.5-turbo", [
        {role: "user", content: "Hi!"},
      ], {"stream" => true}) do |chunk|
        pp chunk.choices.first.delta
      end
    end

    # Check if the client is running in debug mode
    private def debug_mode?
      DEBUG_FLAG[0]
    end
  end
end
