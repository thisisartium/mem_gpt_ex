defprotocol MemGpt.MemoryType do
  @moduledoc """
  This protocol defines the MemoryType behaviour that all memory types must implement.
  """

  @type memory() ::
          MemGpt.FunctionCall.t()
          | MemGpt.Thought.t()
          | MemGpt.UserMessage.t()
          | MemGpt.FunctionResponse.t()

  @doc """
  Converts the given term into a `memory()` type.

  ## Params

  - `term`: The term to convert into a memory type.

  ## Returns

  - A `memory()` type.
  """
  @spec to_memory(term) :: memory()
  def to_memory(term)
end

defimpl MemGpt.MemoryType, for: Map do
  @moduledoc """
  This implementation of the MemoryType protocol handles maps.

  Specifically, we handle maps with a structure matching responses from the
  OpenAI chat completions API.
  """

  alias MemGpt.FunctionCall

  @spec to_memory(map()) :: MemGpt.MemoryType.memory()
  def to_memory(map)

  def to_memory(%{
        "finish_reason" => "function_call",
        "message" => %{
          "function_call" => %{
            "name" => name,
            "arguments" => arguments
          }
        }
      }) do
    FunctionCall.new(name, arguments)
  end
end
