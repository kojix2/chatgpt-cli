require "./spec_helper"
require "../src/chatgpt/substitutor/webpage_compressor"

describe ChatGPT::Substitutor::WebPageCompressor do
  it "compresses text from webpage correctly" do
    compressor = ChatGPT::Substitutor::WebPageCompressor.new("https://example.com")
    compressed_text = compressor.compress
    expected_text = "Example Domain|This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.|More information..."
    compressed_text.should eq(expected_text)
  end

  it "handles empty or invalid URLs correctly" do
    expect_raises(Exception) do
      compressor = ChatGPT::Substitutor::WebPageCompressor.new("https://cahwim9eizulz.com")
    end
  end
end
