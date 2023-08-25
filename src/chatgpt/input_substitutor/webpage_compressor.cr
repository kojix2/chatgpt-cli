require "lexbor"
require "../utils/proxy"

struct Lexbor::Node
  def displayble?
    visible? && !object? && !is_tag_noindex?
  end
end

module ChatGPT
  class InputSubstitutor
    class WebPageCompressor
      class FetchError < Exception; end

      def initialize(url : String)
        @uri = URI.parse(url)
        @body = ""
        fetch
      end

      def fetch
        client = HTTP::Client.new(@uri)
        res = client.get("/")
        raise FetchError.new unless res.success?
        @body = res.body.to_s
      end

      def compress
        words(Lexbor::Parser.new(@body)).join("|")
      end

      def words(parser)
        parser
          .nodes(:_text)                         # iterate through all TEXT nodes
          .select(&.parents.all?(&.displayble?)) # select only which parents are visible good tag
          .map(&.tag_text)                       # mapping node text
          .reject(&.blank?)                      # reject blanked texts
          .map(&.strip.gsub(/\s{2,}/, " "))      # remove extra spaces
      end
    end
  end
end
