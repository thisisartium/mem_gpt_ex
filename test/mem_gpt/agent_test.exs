defmodule MemGpt.AgentTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Agent
  alias MemGpt.Agent.Functions.SendUserMessage
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

    test "the agent context is initialized with the agent's system message and id" do
      {:ok, agent_id, agent_pid} = Agent.boot()

      agent_context = :sys.get_state(agent_pid).context

      assert agent_context.agent_id == agent_id

      assert Agent.Context.last_message(agent_context) ==
               Message.new(:system, Agent.system_message())
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
    setup _ do
      stub(MemGpt.Llm.Mock, :chat_completion, fn context, _options ->
        {:ok, context}
      end)

      :ok
    end

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

    test "it processes the user message with the LLM" do
      user_message = Message.new(:user, Faker.Lorem.sentence())

      agent_id = UUID.uuid4()

      context =
        Agent.Context.new(agent_id, Agent.system_message())
        |> Agent.Context.append_message(user_message)

      expect(MemGpt.Llm.Mock, :chat_completion, fn received_context, _options ->
        assert received_context == context
        {:ok, context}
      end)

      Agent.new(agent_id)
      |> Agent.handle_process_user_message(user_message.content)
    end

    test "it sends the send_user_message function description to the LLM" do
      expect(MemGpt.Llm.Mock, :chat_completion, fn received_context, options ->
        assert Keyword.get(options, :function_call) == "auto"
        functions = Keyword.get(options, :functions, [])
        assert SendUserMessage.schema() in functions
        {:ok, received_context}
      end)

      Agent.new(UUID.uuid4())
      |> Agent.handle_process_user_message(Faker.Lorem.sentence())
    end
  end
end
