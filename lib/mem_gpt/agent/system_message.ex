defmodule MemGpt.Agent.SystemMessage do
  @moduledoc """
  This module defines the structure of a message in the MemGpt Agent.
  """

  use TypedStruct

  typedstruct do
    field(:message, String.t())
  end

  @doc """
  Creates a new message.
  """
  @spec new(String.t()) :: t()
  def new(content) when is_binary(content) do
    %__MODULE__{message: content}
  end

  defimpl Jason.Encoder do
    alias MemGpt.Agent.SystemMessage

    def encode(%SystemMessage{message: message}, options) do
      %{role: "system", content: message}
      |> Jason.Encoder.encode(options)
    end
  end
end
