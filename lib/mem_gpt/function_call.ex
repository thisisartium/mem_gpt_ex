defmodule MemGpt.FunctionCall do
  @moduledoc """
  A memory representing a function call.

  ## Examples

      iex> MemGpt.FunctionCall.new("send_user_message", %{message: "Hello, world!"})
      %MemGpt.FunctionCall{name: "send_user_message", arguments: %{message: "Hello, world!"}}

  """
  use TypedStruct

  typedstruct do
    field :name, String.t(), enforce: true
    field :arguments, map(), default: %{}
  end

  @doc """
  Creates a new FunctionCall struct.
  """
  @spec new(String.t(), map()) :: t()
  def new(name, arguments) do
    %__MODULE__{name: name, arguments: arguments}
  end
end
