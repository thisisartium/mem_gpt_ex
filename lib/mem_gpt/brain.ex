defmodule MemGpt.Brain do
  @moduledoc """
  The brain controls the flow of thoughts and memories.

  ## Examples

      iex> brain = MemGpt.Brain.new()
      iex> MemGpt.Brain.think(brain)
      :sleep

      iex> message = %MemGpt.UserMessage{}
      iex> brain = MemGpt.Brain.add_memory(brain, message)
      iex> MemGpt.Brain.think(brain)
      {:process_data, brain}
  """

  use TypedStruct

  alias MemGpt.FunctionCall
  alias MemGpt.FunctionResponse
  alias MemGpt.Thought
  alias MemGpt.UserMessage

  @type function_call() :: FunctionCall.t()
  @type function_response() :: FunctionResponse.t()
  @type thought() :: Thought.t()
  @type user_message() :: UserMessage.t()
  @type memory() :: function_call() | function_response() | thought() | user_message()
  @type think_result() :: :sleep | {:process_data, t()}

  typedstruct do
    field :memories, list(memory()), default: []
  end

  @doc """
  Creates a new brain with no memories.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Makes the brain think.

  If there are no memories, the brain sleeps. If there are memories, the brain
  processes data.
  """
  @spec think(t()) :: think_result()
  def think(%__MODULE__{memories: []}) do
    :sleep
  end

  @spec think(t()) :: think_result()
  def think(%__MODULE__{memories: [memory | _]} = brain) do
    handle_memory(memory, brain)
  end

  @doc """
  Adds a memory to the brain.
  """
  @spec add_memory(t(), memory()) :: t()
  def add_memory(brain, memory) do
    %{brain | memories: [memory | brain.memories]}
  end

  defp handle_memory(%UserMessage{} = message, brain) do
    {:process_data, message, brain}
  end

  defp handle_memory(%FunctionCall{} = function_call, brain) do
    {:call_function, function_call, brain}
  end

  defp handle_memory(%Thought{}, _brain) do
    :sleep
  end

  defp handle_memory(%FunctionResponse{}, _brain) do
    :sleep
  end
end
