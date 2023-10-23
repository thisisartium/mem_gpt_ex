defmodule MemGPT.Agent do
  @moduledoc """
  An AI agent that runs as a server and is able to process its own thoughts in
  addition to interacting with a user
  """

  use GenServer
  use TypedStruct

  typedstruct do
    field(:id, binary(), enforce: true)
  end

  @doc """
  Boots a new Agent and returns its ID and PID
  """
  def boot do
    id = UUID.uuid4()
    child_spec = {__MODULE__, id}

    {:ok, pid} = DynamicSupervisor.start_child(MemGPT.DynamicSupervisor, child_spec)
    {:ok, id, pid}
  end

  @doc """
  Starts a new Agent with the given ID
  """
  def start_link(id) do
    GenServer.start_link(__MODULE__, id)
  end

  @impl true
  def init(id) do
    {:ok, %__MODULE__{id: id}}
  end

  @doc """
  Finds the Agent with the given ID and returns its PID
  """
  def find_agent_by_id(id) do
    agent = find_agent_in_supervisor(id)

    case agent do
      nil -> {:error, :not_found}
      {_, pid, _, _} -> {:ok, pid}
    end
  end

  defp find_agent_in_supervisor(id) do
    DynamicSupervisor.which_children(MemGPT.DynamicSupervisor)
    |> Enum.find(fn
      {_, pid, :worker, [_]} -> agent_with_matching_id?(pid, id)
      _ -> false
    end)
  end

  defp agent_with_matching_id?(pid, id) do
    case :sys.get_state(pid) do
      %MemGPT.Agent{id: ^id} -> true
      _ -> false
    end
  end
end
