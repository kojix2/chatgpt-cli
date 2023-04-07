require "./spec_helper"
require "../src/chatgpt/webpage_compressor"

describe ChatGPT::WebPageCompressor do
  it "compresses text from webpage correctly" do
    compressor = ChatGPT::WebPageCompressor.new("https://example.com")
    compressed_text = compressor.compressed_text
    expected_text = "Example Domain|This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.|More information..."
    compressed_text.should eq(expected_text)
  end

  it "handles empty or invalid URLs correctly" do
    compressor = ChatGPT::WebPageCompressor.new("https://cahwim9eizulz.com")
    expect_raises(Exception) do
      compressor.compressed_text
    end
  end
end
