defmodule MemGpt.BrainTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Brain
  alias MemGpt.FunctionCall
  alias MemGpt.FunctionResponse
  alias MemGpt.Thought
  alias MemGpt.UserMessage

  describe "think/1" do
    test "when the most recent memory is nil, returns :sleep" do
      brain = %Brain{}
      assert Brain.think(brain) == :sleep
    end

    test "when the most recent memory is a user message, returns {:process_data, message, state}" do
      memory = UserMessage.new("World")
      brain = %Brain{memories: [memory, %UserMessage{content: "Hello"}]}
      assert Brain.think(brain) == {:process_data, memory, brain}
    end

    test "when the most recent memory is a function call, returns {:call_function, function_call, state}" do
      function_call = FunctionCall.new("foo", %{"bar" => "baz"})
      brain = %Brain{memories: [function_call, %UserMessage{content: "Hello"}]}
      assert Brain.think(brain) == {:call_function, function_call, brain}
    end

    test "when the most recent memory is a thought, returns :sleep" do
      thought = Thought.new("Hello")
      brain = %Brain{memories: [thought, %UserMessage{content: "World"}]}
      assert Brain.think(brain) == :sleep
    end

    test "when the most recent memory is a function response, returns :sleep" do
      function_response = FunctionResponse.new("foo", "bar")
      brain = %Brain{memories: [function_response, %UserMessage{content: "World"}]}
      assert Brain.think(brain) == :sleep
    end
  end

  describe "add_memory/2" do
    test "prepends a UserMessage to the memories" do
      brain = Brain.new()
      memory = %UserMessage{content: "Hello"}
      brain = Brain.add_memory(brain, memory)
      assert brain.memories == [memory]
      memory_2 = %UserMessage{content: "World"}
      brain = Brain.add_memory(brain, memory_2)
      assert brain.memories == [memory_2, memory]
    end
  end
end
