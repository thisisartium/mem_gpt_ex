defmodule MemGpt.BrainTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Brain
  alias MemGpt.UserMessage

  describe "think/1" do
    test "when the most recent memory is nil, returns :sleep" do
      brain = Brain.new()
      assert Brain.think(brain) == :sleep
    end

    test "when the most recent memory is a UserMessage, returns {:process_data, state}" do
      brain = Brain.new()
      brain = Brain.add_memory(brain, %UserMessage{content: "Hello"})
      assert Brain.think(brain) == {:process_data, brain}
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
