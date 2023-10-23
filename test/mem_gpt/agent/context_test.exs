defmodule MemGpt.Agent.ContextTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Agent
  alias MemGpt.Agent.Context
  alias MemGpt.Agent.FunctionCall
  alias MemGpt.Agent.Message

  describe "new/1" do
    test "returns a new Context that places the system message as the first message" do
      %Context{messages: [first_message | _]} = Context.new(Agent.system_message())
      assert first_message == Message.new(:system, Agent.system_message())
    end
  end

  describe "append_message/2" do
    test "appends the message to the end of the context window" do
      system_message = Message.new(:system, Agent.system_message())
      message_1 = Message.new(:user, Faker.Lorem.sentence())
      message_2 = Message.new(:user, Faker.Lorem.sentence())

      %Context{messages: messages} =
        Context.new(Agent.system_message())
        |> Context.append_message(message_1)
        |> Context.append_message(message_2)

      assert messages == [system_message, message_1, message_2]
    end

    test "appends the function call to the end of the context window" do
      system_message = Message.new(:system, Agent.system_message())
      message = Message.new(:user, Faker.Lorem.sentence())
      function_call = FunctionCall.new(:some_function, %{argument: "value"})

      %Context{messages: messages} =
        Context.new(Agent.system_message())
        |> Context.append_message(message)
        |> Context.append_message(function_call)

      assert messages == [system_message, message, function_call]
    end
  end

  describe "last_message/1" do
    test "returns the last message in the context window" do
      message_1 = Message.new(:user, Faker.Lorem.sentence())
      message_2 = Message.new(:user, Faker.Lorem.sentence())

      %Context{messages: messages} =
        Context.new(Agent.system_message())
        |> Context.append_message(message_1)
        |> Context.append_message(message_2)

      assert Context.last_message(%Context{messages: messages}) == message_2
    end
  end
end
