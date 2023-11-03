defmodule MemGpt.FunctionResponse do
  @moduledoc """
  A memory representing a response from a function call.

  ## Examples

      iex> MemGpt.FunctionResponse.new("send_user_message", "OK")
      %MemGpt.FunctionResponse{function: "send_user_message", response: "OK"}

  """
  use TypedStruct

  typedstruct do
    field :function, String.t(), enforce: true
    field :response, String.t(), enforce: true
  end

  @doc """
  Creates a new FunctionResponse struct.
  """
  @spec new(String.t(), String.t()) :: t()
  def new(function, response) do
    %__MODULE__{function: function, response: response}
  end
end
