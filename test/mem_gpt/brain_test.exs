defmodule MemGpt.BrainTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Brain

  describe "think/1" do
    test "when the most recent memory is nil, returns :sleep" do
      brain = Brain.new()
      assert Brain.think(brain) == :sleep
    end
  end
end
