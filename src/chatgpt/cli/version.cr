module ChatGPT
  class CLI
    VERSION    = {{ `shards version #{__DIR__}`.chomp.stringify }}
    SOURCE_URL = "https://github.com/kojix2/chatgpt-cli"
  end
end
