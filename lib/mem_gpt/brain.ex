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
  @type think_result() ::
          :sleep | {:process_data, user_message(), t()} | {:call_function, function_call(), t()}

  typedstruct do
    field :memories, list(memory()), default: []
    field :last_processed_memory, memory(), default: nil
  end

  @doc """
  Creates a new brain with no memories.
  """
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
  Determines if the brain should wake up based on its current state.

  The brain should wake up if there are memories to process or if the last processed memory
  requires a response. If there are no memories or the last processed memory does not require
  a response, the brain should not wake up.
  """
  @spec should_wake_up?(t()) :: boolean()
  def should_wake_up?(%__MODULE__{memories: []}) do
    false
  end

  def should_wake_up?(%__MODULE__{last_processed_memory: memory, memories: [memory | _]}) do
    false
  end

  def should_wake_up?(%__MODULE__{memories: [%FunctionCall{} = function_call | _]}) do
    function_call.request_heartbeat?
  end

  def should_wake_up?(%__MODULE__{}) do
    true
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
