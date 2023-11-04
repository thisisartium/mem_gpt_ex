defmodule MemGpt.MemoryTypeTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.FunctionCall
  alias MemGpt.Thought
  alias MemGpt.MemoryType

  describe "to_memory/1 for Map" do
    test "converts an OpenAI function call to a FunctionCall memory" do
      data = %{
        "message" => %{
          "role" => "assistant",
          "function_call" => %{
            "name" => "send_user_message",
            "arguments" => %{
              "message" => "Hello, world!"
            }
          }
        }
      }

      expected = FunctionCall.new("send_user_message", %{"message" => "Hello, world!"})

      assert MemoryType.to_memory(data) == expected
    end

    test "converts an OpenAI assistant response to a Thought memory" do
      data = %{
        "message" => %{
          "role" => "assistant",
          "content" => "Hello, world!"
        }
      }

      expected = Thought.new("Hello, world!")

      assert MemoryType.to_memory(data) == expected
    end
  end
end
