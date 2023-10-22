defmodule MemGPT.AgentTest do
  @moduledoc false

  use MemGPT.TestCase, async: true

  describe "boot/0" do
    test "returns the Agent ID and the pid of the running Agent" do
      {:ok, agent_id, agent_pid} = MemGPT.Agent.boot()
      assert is_pid(agent_pid)
      assert Process.alive?(agent_pid)
      assert %MemGPT.Agent{id: ^agent_id} = :sys.get_state(agent_pid)
    end
  end

  describe "find_agent_by_id/1" do
    test "returns {:ok, pid} of the Agent with the given id" do
      {:ok, agent_id, agent_pid} = MemGPT.Agent.boot()
      assert MemGPT.Agent.find_agent_by_id(agent_id) == {:ok, agent_pid}
    end

    test "returns {:error, :not_found} if no Agent with the given id exists" do
      assert MemGPT.Agent.find_agent_by_id(UUID.uuid4()) == {:error, :not_found}
    end
  end
end
