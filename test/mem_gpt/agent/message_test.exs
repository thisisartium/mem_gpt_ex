defmodule MemGpt.Agent.UserMessageTest do
  use MemGpt.TestCase, async: true

  alias MemGpt.Agent.UserMessage

  describe "new/2" do
    test "returns a new UserMessage struct with the attributes set correctly" do
      content = Faker.Lorem.sentence()
      assert %UserMessage{message: ^content} = UserMessage.new(content)
    end
  end
end
