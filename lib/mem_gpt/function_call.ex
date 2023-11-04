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
    field :request_heartbeat?, boolean(), default: false
  end

  @doc """
  Creates a new FunctionCall struct.
  """
  @spec new(String.t(), map()) :: t()
  def new(name, arguments) do
    {heartbeat, arguments} = Map.pop(arguments, "heartbeat", false)
    %__MODULE__{name: name, arguments: arguments, request_heartbeat?: heartbeat}
  end
end
