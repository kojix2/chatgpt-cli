require "./utils/proxy"

module ChatGPT
  # Define custom exceptions for API key errors and SIGINT signals
  class ApiKeyError < Exception; end

  class SigIntError < Exception; end

  # Define the Client class that handles communication with the ChatGPT API
  class Client
    # ChatGPT Web App URL
    WEB_APP_URL = "https://chat.openai.com"

    # Set the API endpoint URL
    API_ENDPOINT = "https://api.openai.com"

    # Initialize instance variable for HTTP headers
    @http_headers : HTTP::Headers

    # Initialize the Client object by building the required HTTP headers
    def initialize
      @http_headers = build_http_headers
    end

    # Build the required HTTP headers using the API key from environment variables
    def build_http_headers
      HTTP::Headers{
        "Authorization" => "Bearer #{fetch_api_key}",
        "Content-Type"  => "application/json",
      }
    end

    # Fetch the API key from the environment variables or display an error if not present
    def fetch_api_key
      if ENV.has_key?("OPENAI_API_KEY")
        ENV["OPENAI_API_KEY"]
      else
        STDERR.puts "Error: OPENAI_API_KEY is not set. "._colorize(:warning, :bold)
        STDERR.puts "Please get your API key and set it as an environment variable."._colorize(:warning)
        ""
      end
    end

    # Send a chat request to the ChatGPT API and log the request and response data if in debug mode
    def send_chat_request(request_data)
      log_request_data(request_data) if ChatGPT.debug?
      spinner = create_spinner
      spinner.start
      begin
        chat_response = post_request(request_data)
      rescue ex
        spinner.stop
        raise ex
      end
      spinner.stop
      log_response_data(chat_response) if ChatGPT.debug?
      chat_response
    end

    # Send a POST request with the provided request data to the ChatGPT API
    def post_request(request_data)
      client = HTTP::Client.new(URI.parse(API_ENDPOINT))
      {% if (flag?(:linux) || flag?(:darwin)) %}
        Signal::INT.trap { |s| client.close }
      {% end %}
      response = client.post("/v1/chat/completions", headers: @http_headers, body: request_data.to_json)
    rescue ex
      {% if (flag?(:linux) || flag?(:darwin)) %}
        Signal::INT.reset
      {% end %}
      raise ex
    end

    # Create a spinner for displaying progress while waiting for API response
    private def create_spinner
      spinner_text = "ChatGPT"._colorize(:chatgpt, :bold)
      Spin.new(0.2, Spinner::Charset[:pulsate2], spinner_text, output: STDERR)
    end

    # Log the request data sent to the API in debug mode
    private def log_request_data(request_data)
      STDERR.puts
      STDERR.puts "Sending request to #{API_ENDPOINT}"._colorize(:debug, :bold)
      STDERR.puts request_data.pretty_inspect._colorize(:debug)
      STDERR.puts
    end

    # Log the response data received from the API in debug mode
    private def log_response_data(chat_response)
      STDERR.puts "Received response from #{API_ENDPOINT}"._colorize(:debug, :bold)
      STDERR.puts "Response status: #{chat_response.status}"._colorize(:debug)
      STDERR.puts "Response body: #{JSON.parse(chat_response.body).pretty_inspect}"._colorize(:debug)
      STDERR.puts
    end
  end
end
