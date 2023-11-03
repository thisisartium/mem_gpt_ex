defmodule MemGpt.Thought do
  @moduledoc """
  A memory representing a thought that the system has generated.

  ## Examples

      iex> thought = MemGpt.Thought.new("I am thinking")
      %MemGpt.Thought{content: "I am thinking"}

  """
  use TypedStruct

  typedstruct do
    field :content, String.t(), enforce: true
  end

  @doc """
  Creates a new Thought struct with the given content.
  """
  @spec new(String.t()) :: t()
  def new(content) do
    %__MODULE__{content: content}
  end
end
