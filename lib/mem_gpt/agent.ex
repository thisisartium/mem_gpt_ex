defmodule MemGPT.Agent do
  @moduledoc """
  Defines an AI agent that operates as a server. The agent is capable of processing its own thoughts and interacting with a user.
  """

  use GenServer
  use TypedStruct

  @type id :: binary()

  typedstruct do
    field(:id, id(), enforce: true)
  end

  @doc """
  Initializes a new Agent, returning its unique ID and process ID (PID).

  ## Examples

      iex> {:ok, id, pid} = MemGPT.Agent.boot()
      iex> is_binary(id)
      true
      iex> is_pid(pid)
      true

  """
  @spec boot() :: {:ok, id(), pid()}
  def boot do
    id = UUID.uuid4()
    child_spec = {__MODULE__, id}

    {:ok, pid} = DynamicSupervisor.start_child(MemGPT.DynamicSupervisor, child_spec)
    {:ok, id, pid}
  end

  @doc """
  Starts a new Agent with the provided ID.
  """
  @spec start_link(id()) :: GenServer.on_start()
  def start_link(id) do
    GenServer.start_link(__MODULE__, id)
  end

  @impl true
  @spec init(id()) :: {:ok, t()}
  def init(id) do
    {:ok, %__MODULE__{id: id}}
  end

  @doc """
  Locates the Agent with the specified ID and returns its process ID (PID).

  ## Examples

      iex> {:ok, id, pid} = MemGPT.Agent.boot()
      iex> MemGPT.Agent.find_agent_by_id(id)
      {:ok, pid}

  """
  @spec find_agent_by_id(id()) :: {:ok, pid()} | {:error, :not_found}
  def find_agent_by_id(id) do
    agent = find_agent_in_supervisor(id)

    case agent do
      nil -> {:error, :not_found}
      {_, pid, _, _} -> {:ok, pid}
    end
  end

  @spec find_agent_in_supervisor(id()) :: nil | {id(), pid(), :worker, [id()]}
  defp find_agent_in_supervisor(id) do
    DynamicSupervisor.which_children(MemGPT.DynamicSupervisor)
    |> Enum.find(fn
      {_, pid, :worker, [_]} -> agent_with_matching_id?(pid, id)
      _ -> false
    end)
  end

  @spec agent_with_matching_id?(pid(), id()) :: boolean()
  defp agent_with_matching_id?(pid, id) do
    case :sys.get_state(pid) do
      %MemGPT.Agent{id: ^id} -> true
      _ -> false
    end
  end
end
