defmodule MemGpt.FunctionCallTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.FunctionCall

  describe "new/2" do
    test "creates a new FunctionCall struct" do
      function_call = FunctionCall.new("foo", %{"bar" => "baz"})
      assert function_call == %FunctionCall{name: "foo", arguments: %{"bar" => "baz"}}
    end
  end
end
