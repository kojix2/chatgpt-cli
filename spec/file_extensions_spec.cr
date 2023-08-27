require "./spec_helper"
require "../src/chatgpt/substitutor/file_extensions"

describe ChatGPT::Substitutor::FILE_EXTENSIONS do
  it "should return the correct file extension" do
    ChatGPT::Substitutor::FILE_EXTENSIONS[".cr"].should eq "crystal"
    ChatGPT::Substitutor::FILE_EXTENSIONS[".rb"].should eq "ruby"
    expect_raises(KeyError) { ChatGPT::Substitutor::FILE_EXTENSIONS[".unknown"] }
  end
end
