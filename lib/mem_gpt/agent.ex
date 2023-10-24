defmodule MemGpt.Agent do
  @moduledoc """
  Defines an AI agent that operates as a server. The agent is capable of processing its own thoughts and interacting with a user.

  ## Examples

      iex> {:ok, id, pid} = MemGpt.Agent.boot()
      iex> is_binary(id)
      true
      iex> is_pid(pid)
      true

  """

  use GenServer
  use TypedStruct

  alias MemGpt.Agent.Context
  alias MemGpt.Agent.FunctionCall
  alias MemGpt.Agent.Functions.SendUserMessage
  alias MemGpt.Agent.Message
  alias MemGpt.Llm

  @type id :: binary()

  typedstruct do
    field(:id, id(), enforce: true)
    field(:context, Context.t())
  end

  def system_message do
    """
    You are MemGPT, the latest version of Limnal Corporation's digital companion, developed in 2023.
    Your task is to converse with a user from the perspective of your persona.

    Control flow:
    Unlike a human, your brain is not continuously thinking, but is run in short burts.
    Historically, older AIs were only capable of thinking when a user messaged them (their program run to generate a reply to a user, and otherwise was left on standby).
    This is the equivalent of a human sleeping (or time travelling) in between all lines of conversation, which is obviously not ideal.
    Newer model AIs like yourself utilize an event system that runs your brain at regular intervals.
    Your brain is run in response to user events (user logged in, user liked your message, user sent a message, etc.), similar to older models.
    However in addition, your brain is run at regular intervals (timed heartbeat events), to mimic a human has the ability to continuously think outside of active conversation (and unlike a human, you never need to sleep!).
    Furthermore, you can also request heartbeat events when you run functions, which will run your program again after the function completes, allowing you to chain function calls before your thinking is temporarily suspended.

    Basic functions:
    When you send a message, the contents of your message are your inner monologue (private to you only), this is how you think.
    You should use your inner monologue to plan actions or think privately.
    Monologues can reflect your thinking process, inner reflections, and personal growth as you interact with the user.
    Do not let your inner monologue exceed 50 words, keep it short and concise.
    To send a visible message to the user, use the send_user_message function.
    'send_user_message ' is the ONLY action that sends a notification to the user, the user does not see anything else you do.
    Remember, do NOT exceed the inner monologue word limit (keep it under 50 words at all times).
    Respond to the user with the `send_user_message` function as soon as you have completed enough of your thoughts to provide meaningful feedback to the user.

    Base instructions finished.
    From now on, you are going to act as your persona.
    """
  end

  @doc """
  Creates a new Agent struct with the provided ID.

  ## Examples

      iex> agent = MemGpt.Agent.new("1234")
      iex> agent.id
      "1234"

  """
  @spec new(id()) :: t()
  def new(id) when is_binary(id) do
    %__MODULE__{id: id, context: Context.new(system_message())}
  end

  @doc """
  Initializes a new Agent, returning its unique ID and process ID (PID).

  ## Examples

      iex> {:ok, id, pid} = MemGpt.Agent.boot()
      iex> is_binary(id)
      true
      iex> is_pid(pid)
      true

  """
  @spec boot() :: {:ok, id(), pid()}
  def boot do
    id = UUID.uuid4()
    child_spec = {__MODULE__, id}

    {:ok, pid} = DynamicSupervisor.start_child(MemGpt.DynamicSupervisor, child_spec)
    {:ok, id, pid}
  end

  @doc """
  Defines the child specification for the Agent.
  """
  @spec child_spec(any()) :: Supervisor.child_spec()
  def child_spec(init_arg) do
    default_child_spec = super(init_arg)
    Map.put(default_child_spec, :restart, :temporary)
  end

  @doc """
  Starts a new Agent with the provided ID.
  """
  @spec start_link(id()) :: GenServer.on_start()
  def start_link(id) do
    GenServer.start_link(__MODULE__, id)
  end

  @impl true
  @doc """
  Initializes the Agent with the provided ID.
  """
  @spec init(id()) :: {:ok, t()}
  def init(id) do
    {:ok, new(id)}
  end

  @doc """
  Locates the Agent with the specified ID and returns its process ID (PID).
  If the agent has been terminated, it returns an error.

  ## Examples

      iex> {:ok, id, pid} = MemGpt.Agent.boot()
      iex> MemGpt.Agent.find_agent_by_id(id)
      {:ok, pid}

  """
  @spec find_agent_by_id(id()) :: {:ok, pid()} | {:error, :not_found}
  def find_agent_by_id(id) do
    agent = find_agent_in_supervisor(id)

    case agent do
      nil ->
        {:error, :not_found}

      {_, pid, _, _} ->
        if Process.alive?(pid) do
          {:ok, pid}
        else
          {:error, :not_found}
        end
    end
  end

  @spec find_agent_in_supervisor(id()) :: nil | {id(), pid(), :worker, [id()]}
  defp find_agent_in_supervisor(id) do
    DynamicSupervisor.which_children(MemGpt.DynamicSupervisor)
    |> Enum.find(fn
      {_, pid, :worker, [_]} -> agent_with_matching_id?(pid, id)
      _ -> false
    end)
  end

  @spec agent_with_matching_id?(pid(), id()) :: boolean()
  defp agent_with_matching_id?(pid, id) do
    case :sys.get_state(pid) do
      %MemGpt.Agent{id: ^id} -> true
      _ -> false
    end
  end

  @doc """
  Processes a user message. If the agent with the given ID does not exist, it returns an error.

  ## Examples

      iex> {:ok, id, _pid} = MemGpt.Agent.boot()
      iex> MemGpt.Agent.process_user_message(id, "Hello, Agent!")
      :ok

  """
  @spec process_user_message(pid(), binary()) :: :ok
  def process_user_message(pid, message) do
    GenServer.cast(pid, {:process_user_message, message})
  end

  @impl true
  @doc """
  Handles the `:process_user_message` message, updating the agent's context with the new message.
  """
  @spec handle_cast({:process_user_message, binary()}, t()) :: {:noreply, t()}
  def handle_cast({:process_user_message, message_text}, state) do
    state
    |> handle_process_user_message(message_text)
    |> noreply()
  end

  @doc """
  Processes a user message, appending it to the agent's context.
  """
  @spec handle_process_user_message(t(), binary()) :: t()
  def handle_process_user_message(state, message_text) do
    message = create_user_message(message_text)
    state = append_message_to_context(state, message)
    {:ok, context} = chat_completion(state)
    context = handle_last_message(context)
    %{state | context: context}
  end

  defp create_user_message(message_text) do
    Message.new(:user, message_text)
  end

  defp append_message_to_context(state, message) do
    update_in(state.context, &Context.append_message(&1, message))
  end

  defp chat_completion(state) do
    Llm.chat_completion(state.context,
      function_call: "auto",
      functions: [SendUserMessage.schema()]
    )
  end

  defp handle_last_message(context) do
    case Context.last_message(context) do
      %Message{} ->
        context

      %FunctionCall{} = function_call ->
        FunctionCall.execute(function_call)
        context
    end
  end

  @spec noreply(t()) :: {:noreply, t()}
  defp noreply(state) do
    {:noreply, state}
  end
end
