require "./spec_helper"
require "../src/chatgpt/post_data"

module ChatGPT
  data = PostData.new(messages: [{"role" => "system", "content" => "Set some context"}])

  describe PostData do
    it "should have system message" do
      data.messages.should contain({"role" => "system", "content" => "Set some context"})
    end

    it "adds user message correctly" do
      data.add_message("user", "What's the capital of France?")
      data.messages.should contain({"role" => "user", "content" => "What's the capital of France?"})
    end

    it "sets max_output_tokens correctly" do
      data.max_output_tokens = 100
      data.max_output_tokens.should eq(100)
    end

    it "sets temperature correctly" do
      data.temperature = 0.8
      data.temperature.should eq(0.8)
    end

    it "sets top_p correctly" do
      data.top_p = 0.9
      data.top_p.should eq(0.9)
    end
  end
end
