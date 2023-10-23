defmodule MemGpt.Agent.ContextTest do
  use MemGpt.TestCase, async: true

  alias MemGpt.Agent.Context
  alias MemGpt.Agent.Message

  describe "new/0" do
    test "returns a new Context" do
      assert %Context{} = Context.new()
    end
  end

  describe "append_message/2" do
    test "appends the message to the end of the context window" do
      message_1 = Message.new(:user, Faker.Lorem.sentence())
      message_2 = Message.new(:user, Faker.Lorem.sentence())

      %Context{messages: messages} =
        Context.new()
        |> Context.append_message(message_1)
        |> Context.append_message(message_2)

      assert messages == [message_1, message_2]
    end
  end

  describe "last_message/1" do
    test "returns the last message in the context window" do
      message_1 = Message.new(:user, Faker.Lorem.sentence())
      message_2 = Message.new(:user, Faker.Lorem.sentence())

      %Context{messages: messages} =
        Context.new()
        |> Context.append_message(message_1)
        |> Context.append_message(message_2)

      assert Context.last_message(%Context{messages: messages}) == message_2
    end
  end
end
