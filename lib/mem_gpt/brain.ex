defmodule MemGpt.Brain do
  @moduledoc """
  The brain controls the flow of thoughts and memories
  """

  use TypedStruct

  alias MemGpt.UserMessage

  @type memory() :: UserMessage.t()

  typedstruct do
    field(:memories, list(memory()), default: [])
  end

  def new do
    %__MODULE__{}
  end

  def think(%__MODULE__{memories: []}) do
    :sleep
  end

  def think(%__MODULE__{memories: [memory | _]} = brain) when is_struct(memory, UserMessage) do
    {:process_data, brain}
  end

  def add_memory(brain, memory) do
    %{brain | memories: [memory | brain.memories]}
  end
end
