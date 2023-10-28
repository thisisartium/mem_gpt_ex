defmodule MemGpt.Agent.Thought do
  @moduledoc """
  A module representing the thoughts of an agent.
  """

  use TypedStruct

  alias MemGpt.Clock

  typedstruct do
    field(:thought, String.t())
    field(:time, DateTime.t())
  end

  @doc """
  Creates a new thought.

  ## Examples

      iex> thought = MemGpt.Agent.Thought.new("I am thinking")
      iex> thought.thought
      "I am thinking"
  """
  @spec new(String.t()) :: t()
  def new(content) when is_binary(content) do
    %__MODULE__{thought: content, time: Clock.now()}
  end
end

defimpl Jason.Encoder, for: MemGpt.Agent.Thought do
  alias MemGpt.Agent.Thought

  @doc """
  Encodes a Thought struct into JSON.

  ## Examples

      iex> thought = MemGpt.Agent.Thought.new("I am thinking")
      iex> Jason.encode!(thought)
      "{\"role\":\"assistant\",\"content\":\"{\\\"type\\\":\\\"ai_thought\\\",\\\"thought\\\":\\\"I am thinking\\\",\\\"time\\\":\\\"2022-01-01T00:00:00Z\\\"}\"}"
  """
  def encode(%Thought{thought: thought, time: time}, options) do
    Jason.Encoder.encode(
      %{
        role: "assistant",
        content:
          %{
            "type" => "ai_thought",
            "thought" => thought,
            "time" => DateTime.to_iso8601(time)
          }
          |> Jason.encode!()
      },
      options
    )
  end
end
