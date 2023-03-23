require "./spec_helper"
require "../src/chatgpt/post_data"



module ChatGPT
  data = PostData.new(messages: [{"role" => "system", "content" => "Set some context"}])

  describe PostData do
    it "should have system message" do
      data.messages.should contain({"role" => "system", "content" => "Set some context"})
    end

    it "adds user message correctly" do
      data.messages << {"role" => "user", "content" => "What's the capital of France?"}
      data.messages.should contain({"role" => "user", "content" => "What's the capital of France?"})
    end

    it "generates correct number of edits" do
      data.n = 2
      data.n.should eq(2)
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
