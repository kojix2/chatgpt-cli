require "./spec_helper"
require "../src/chatgpt/system_command_runner"

describe ChatGPT::SystemCommandRunner do
  describe "try_run" do
    runner = ChatGPT::SystemCommandRunner.new

    it "returns false if input does not start with '!' or '!!'" do
      input = "hello world"
      try_run_result = runner.try_run(input)
      try_run_result.should be_false
    end

    it "runs command without recording if input starts with '!'" do
      input = "!echo hello"

      runner.try_run(input).should be_true
    end

    it "runs command with recording if input starts with '!!'" do
      input = "!!echo hello"

      runner.try_run(input).should be_true
    end

    it "runs command and captures stdout" do
      input = "!!echo hello"

      runner.try_run(input).should be_true
      runner.last_command.should eq("echo hello")
      runner.last_stdout.should eq("hello\n")
      runner.last_stderr.should eq("")
    end

    it "runs command and captures stderr" do
      input = "!!echo hello 1>&2"

      runner.try_run(input).should be_true
      runner.last_command.should eq("echo hello 1>&2")
      runner.last_stdout.should eq("")
      runner.last_stderr.should eq("hello\n")
    end
  end
end
