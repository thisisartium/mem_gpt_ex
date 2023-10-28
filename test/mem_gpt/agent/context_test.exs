defmodule MemGpt.Agent.ContextTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Agent
  alias MemGpt.Agent.Context
  alias MemGpt.Agent.FunctionCall
  alias MemGpt.Agent.SystemMessage
  alias MemGpt.Agent.UserMessage

  describe "new/1" do
    test "returns a new Context that places the system message as the first message" do
      %Context{messages: [first_message | _]} = Context.new(Agent.system_message())
      assert first_message == SystemMessage.new(Agent.system_message())
    end
  end

  describe "append_message/2" do
    test "appends the message to the end of the context window" do
      system_message = SystemMessage.new(Agent.system_message())
      message_1 = UserMessage.new(Faker.Lorem.sentence())
      message_2 = UserMessage.new(Faker.Lorem.sentence())

      %Context{messages: messages} =
        Context.new(Agent.system_message())
        |> Context.append_message(message_1)
        |> Context.append_message(message_2)

      assert messages == [system_message, message_1, message_2]
    end

    test "appends the function call to the end of the context window" do
      system_message = SystemMessage.new(Agent.system_message())
      message = UserMessage.new(Faker.Lorem.sentence())
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
      message_1 = UserMessage.new(Faker.Lorem.sentence())
      message_2 = UserMessage.new(Faker.Lorem.sentence())

      context =
        Context.new(Agent.system_message())
        |> Context.append_message(message_1)
        |> Context.append_message(message_2)

      assert Context.last_message(context) == message_2
    end
  end
end
