require "./spec_helper"
require "../src/chatgpt/input_substitutor/file_extensions"

describe ChatGPT::InputSubstitutor::FILE_EXTENSIONS do
  it "should return the correct file extension" do
    ChatGPT::InputSubstitutor::FILE_EXTENSIONS[".cr"].should eq "crystal"
    ChatGPT::InputSubstitutor::FILE_EXTENSIONS[".rb"].should eq "ruby"
    expect_raises(KeyError) { ChatGPT::InputSubstitutor::FILE_EXTENSIONS[".unknown"] }
  end
end
