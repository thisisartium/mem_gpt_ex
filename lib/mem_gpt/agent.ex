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
  alias MemGpt.Agent.Functions.SendUserMessage
  alias MemGpt.Agent.Message
  alias MemGpt.Llm

  @type id :: binary()

  typedstruct do
    field(:id, id(), enforce: true)
    field(:context, Context.t(), default: Context.new())
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
    %__MODULE__{id: id}
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
    {:ok, %__MODULE__{id: id}}
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
    message = Message.new(:user, message_text)

    state =
      update_in(state.context, &Context.append_message(&1, message))

    {:ok, context} =
      Llm.chat_completion(state.context,
        functions: [SendUserMessage.schema()]
      )

    %{state | context: context}
  end

  @spec noreply(t()) :: {:noreply, t()}
  defp noreply(state) do
    {:noreply, state}
  end
end
