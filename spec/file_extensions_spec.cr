require "./spec_helper"
require "../src/chatgpt/file_extensions"

describe ChatGPT::FILE_EXTENSIONS do
  it "should return the correct file extension" do
    ChatGPT::FILE_EXTENSIONS[".cr"].should eq "crystal"
    ChatGPT::FILE_EXTENSIONS[".rb"].should eq "ruby"
    expect_raises(KeyError) { ChatGPT::FILE_EXTENSIONS[".unknown"] }
  end
end
