defmodule MemGpt.Agent.UserMessage do
  @moduledoc """
  This module defines the structure of a message in the MemGpt Agent.
  """

  use TypedStruct

  alias MemGpt.Clock

  typedstruct do
    field(:message, String.t())
    field(:time, DateTime.t())
  end

  @doc """
  Creates a new message.
  """
  @spec new(String.t()) :: t()
  def new(content) when is_binary(content) do
    %__MODULE__{message: content, time: Clock.now()}
  end

  defimpl Jason.Encoder do
    alias MemGpt.Agent.UserMessage

    def encode(%UserMessage{message: message, time: time}, options) do
      Jason.Encoder.encode(
        %{
          role: "user",
          content:
            %{
              "type" => "user_message",
              "message" => message,
              "time" => DateTime.to_iso8601(time)
            }
            |> Jason.encode!()
        },
        options
      )
    end
  end
end
