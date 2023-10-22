defmodule MemGPTTest do
  use ExUnit.Case
  doctest MemGPT

  test "greets the world" do
    assert MemGPT.hello() == :world
  end
end
