defmodule MemGpt.UserMessage do
  @moduledoc """
  A memory representing a message that the user has sent.

  ## Examples

      iex> MemGpt.UserMessage.new("Hello, world!")
      %MemGpt.UserMessage{content: "Hello, world!"}

  """
  use TypedStruct

  typedstruct do
    field :content, String.t(), enforce: true
  end

  @doc """
  Creates a new UserMessage.
  """
  @spec new(String.t()) :: t()
  def new(content), do: %__MODULE__{content: content}
end
