defmodule MemGpt.Agent.Thought do
  use TypedStruct

  alias MemGpt.Clock

  typedstruct do
    field(:thought, String.t())
    field(:time, DateTime.t())
  end

  @doc """
  Creates a new message.
  """
  @spec new(String.t()) :: t()
  def new(content) when is_binary(content) do
    %__MODULE__{thought: content, time: Clock.now()}
  end

  defimpl Jason.Encoder do
    alias MemGpt.Agent.Thought

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
end
