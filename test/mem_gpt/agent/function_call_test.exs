defmodule MemGpt.Agent.FunctionCallTest do
  use MemGpt.TestCase, async: true

  alias MemGpt.Agent.FunctionCall

  describe "new/2" do
    test "returns a new FunctionCall struct with the attributes set correctly" do
      name = :some_function
      args = %{"argument" => "value"}
      assert %FunctionCall{name: ^name, arguments: ^args} = FunctionCall.new(name, args)
    end

    test "handles setting arguments as a keyword list" do
      name = :some_function
      args = [argument: "value"]
      expected_args = %{"argument" => "value"}
      assert %FunctionCall{name: ^name, arguments: ^expected_args} = FunctionCall.new(name, args)
    end
  end

  describe "conversion" do
    test "converts a function call map with map of arguments" do
      input = %{"name" => "send_user_message", "arguments" => %{"message" => "Hello, world!"}}

      assert FunctionCall.Conversion.convert(input) ==
               FunctionCall.new(:send_user_message, %{"message" => "Hello, world!"})
    end

    test "converts a function call map with JSON string of arguments" do
      input = %{
        "name" => "send_user_message",
        "arguments" => Jason.encode!(%{"message" => "Hello, world!"})
      }

      assert FunctionCall.Conversion.convert(input) ==
               FunctionCall.new(:send_user_message, %{"message" => "Hello, world!"})
    end
  end

  describe "serialization" do
    test "serializes to the JSON format expected by OpenAI" do
      function_call = FunctionCall.new(:send_user_message, %{"message" => "Hello, world!"})

      assert Jason.encode!(function_call) ==
               Jason.encode!(%{
                 role: "assistant",
                 function_call: %{
                   name: "send_user_message",
                   arguments: Jason.encode!(%{"message" => "Hello, world!"})
                 },
                 content: nil
               })
    end
  end
end
