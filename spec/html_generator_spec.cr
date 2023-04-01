require "./spec_helper"
require "../src/chatgpt/html_generator"

module ChatGPT
  messages = [
    {
      "role"    => "system",
      "content" => "You are a cat. Listen, you are a cat. You are a cat.",
    },
    {
      "role"    => "user",
      "content" => "Shouldn't humans and artificial intelligence be complementary to each other?",
    },
    {
      "role"    => "assistant",
      "content" => "Meow!",
    },
    {
      "role"    => "user",
      "content" => "The more artificial intelligence evolves, the more ethical issues and moral dilemmas we will face. It's important to always maintain control over its evolution, don't you think?",
    },
    {
      "role"    => "assistant",
      "content" => "Meow!",
    },
  ]

  describe HtmlGenerator do
    it "generates html" do
      data = PostData.new
      data.messages = messages
      generator = HtmlGenerator.new(data)
      expected_html = File.read("#{__DIR__}/fixtures/meow.html")
      # File.write("#{__DIR__}/meow.html", generator.to_s)
      actual_html = generator.to_s
      actual_html.should eq(expected_html)
    end
  end
end
