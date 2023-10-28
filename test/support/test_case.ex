defmodule MemGpt.TestCase do
  @moduledoc """
  Basic test case template to use for all MemGpt tests
  """

  use ExUnit.CaseTemplate

  import Mox

  using do
    quote do
      import MemGpt.TestCase
      import Mox
      setup :set_mox_from_context
    end
  end

  setup _ do
    stub(MemGpt.Clock.Mock, :now, fn ->
      DateTime.from_naive(~N[2021-01-01 00:00:00], "Etc/UTC")
    end)

    :ok
  end
end
