defmodule MemGpt.Brain do
  @moduledoc """
  The brain controls the flow of thoughts and memories
  """

  use TypedStruct

  typedstruct do
  end

  def new do
    %__MODULE__{}
  end

  def think(_brain) do
    :sleep
  end
end
