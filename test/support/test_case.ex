defmodule MemGpt.TestCase do
  @moduledoc """
  Basic test case template to use for all MemGpt tests
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import MemGpt.TestCase
      import Mox
      setup :set_mox_from_context
    end
  end
end
