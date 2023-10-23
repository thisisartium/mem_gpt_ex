defmodule MemGpt.AgentTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Agent
  alias MemGpt.Agent.Message

  import Mox

  setup :verify_on_exit!

  setup :set_mox_from_context

  describe "boot/0" do
    test "returns the Agent ID and the pid of the running Agent" do
      {:ok, agent_id, agent_pid} = Agent.boot()
      assert is_pid(agent_pid)
      assert Process.alive?(agent_pid)
      assert %Agent{id: ^agent_id} = :sys.get_state(agent_pid)
    end
  end

  describe "find_agent_by_id/1" do
    test "returns {:ok, pid} of the Agent with the given id" do
      {:ok, agent_id, agent_pid} = Agent.boot()
      assert Agent.find_agent_by_id(agent_id) == {:ok, agent_pid}
    end

    test "returns {:error, :not_found} if no Agent with the given id exists" do
      assert Agent.find_agent_by_id(UUID.uuid4()) == {:error, :not_found}
    end

    test "find_agent_by_id/1 returns {:error, :not_found} if the agent with the given ID was booted but then terminated" do
      {:ok, agent_id, agent_pid} = Agent.boot()

      # Monitor the agent process
      ref = Process.monitor(agent_pid)

      # Stop the agent process
      :ok = GenServer.stop(agent_pid, :normal, 5000)

      # Wait for a :DOWN message from the agent process
      receive do
        {:DOWN, ^ref, :process, ^agent_pid, _reason} -> :ok
      after
        5000 -> :error
      end

      assert Agent.find_agent_by_id(agent_id) == {:error, :not_found}
    end
  end

  describe "handle_process_user_message/2" do
    test "it appends the user message to the end of the context window" do
      message_text = Faker.Lorem.sentence()

      %Agent{context: context} =
        Agent.new(UUID.uuid4())
        |> Agent.handle_process_user_message(message_text)

      assert Agent.Context.last_message(context) == %Message{
               role: :user,
               content: message_text
             }
    end
  end
end
