require "./spec_helper"
require "../src/chatgpt/response_data"

module ChatGPT
  sample_response_data =
    <<-JSON
    {
      "id": "resp_123",
      "object": "response",
      "created_at": 1741290958,
      "status": "completed",
      "model": "gpt-5.1",
      "output": [
        {
          "id": "msg_123",
          "type": "message",
          "status": "completed",
          "role": "assistant",
          "content": [
            {
              "type": "output_text",
              "text": "The capital of Argentina is Buenos Aires.",
              "annotations": []
            }
          ]
        }
      ],
      "usage": {
        "input_tokens": 33,
        "output_tokens": 30,
        "total_tokens": 63
      }
    }
    JSON

  describe ResponseData do
    response = ResponseData.new(sample_response_data)

    it "parses tokens correctly" do
      # For Responses API, assert that total_tokens is exposed correctly.
      response.total_tokens.should eq(63)
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
