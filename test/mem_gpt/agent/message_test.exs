defmodule MemGpt.Agent.MessageTest do
  use MemGpt.TestCase, async: true

  alias MemGpt.Agent.Message

  describe "new/2" do
    test "returns a new Message struct with the attributes set correctly" do
      role = :user
      content = Faker.Lorem.sentence()
      assert %Message{role: ^role, content: ^content} = Message.new(role, content)
    end
  end
end
