module ChatGPT
  class InputSubstitutor
    def url(input_msg, url_pattern)
      input_msg.gsub(url_pattern) do |url_match|
        url_pattern = $1.strip
        fetch_and_compress_url_contents(url_match, url_pattern)
      end
    end

    private def fetch_and_compress_url_contents(url_match, url)
      url = "https://" + url unless url.starts_with?("http")
      begin
        wpc = WebPageCompressor.new(url)
      rescue ex
        STDERR.puts "Warning: Failed to fetch url: #{url} leave it as it is"._colorize(:warning, :bold)
        STDERR.puts ex.message._colorize(:warning)
        return url_match
      end
      compressed_text = wpc.compress

      <<-CODE_BLOCK
      
      ### #{url}

      ```
      #{compressed_text}
      ```

      That's all for the #{url}
      CODE_BLOCK
    end
  end
end
