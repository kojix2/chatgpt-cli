require "./spec_helper"
require "../src/chatgpt/response_data"

module ChatGPT
  sample_response_data =
    <<-JSON
    {
      "id": "chatcmpl-72etpAlXCj1x8Cf5uvHeYZMjgjGAA",
      "object": "chat.completion",
      "created": 1680868229,
      "model": "gpt-3.5-turbo-0301",
      "usage": {
        "prompt_tokens": 33,
        "completion_tokens": 30,
        "total_tokens": 63
      },
      "choices": [
        {
        "message": {
          "role": "assistant",
          "content": "The capital of Argentina is Buenos Aires."
        },
        "finish_reason": "stop",
        "index": 0
        }
      ]
    }
    JSON

  describe ResponseData do
    response = ResponseData.new(sample_response_data)

    it "parses tokens correctly" do
      expected_tokens = %({\n  "prompt_tokens": 33,\n  "completion_tokens": 30,\n  "total_tokens": 63\n})
      response.tokens.should eq(expected_tokens)
    end

    it "gets total tokens correctly" do
      expected_total_tokens = 63
      response.total_tokens.should eq(expected_total_tokens)
    end

    it "parses pretty json correctly" do
      pretty_json = response.to_pretty_json
      JSON.parse(pretty_json).should eq(JSON.parse(sample_response_data))
    end

    it "extracts assistant message correctly" do
      expected_message = "The capital of Argentina is Buenos Aires."
      response.assistant_message.should eq(expected_message)
    end
  end
end
