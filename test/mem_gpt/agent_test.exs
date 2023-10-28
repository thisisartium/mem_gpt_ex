defmodule MemGpt.AgentTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Agent
  alias MemGpt.Agent.Context
  alias MemGpt.Agent.FunctionCall
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

    test "the agent context is initialized with the agent's system message" do
      {:ok, _agent_id, agent_pid} = Agent.boot()

      assert Agent.Context.last_message(:sys.get_state(agent_pid).context) ==
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

      assert %Message{role: :user, content: content} = Agent.Context.last_message(context)

      assert %{"type" => "user_message", "message" => ^message_text, "time" => time} =
               Jason.decode!(content)

      assert {:ok, _, 0} = DateTime.from_iso8601(time)
    end

    test "it processes the user message with the LLM" do
      message_text = Faker.Lorem.sentence()

      expect(MemGpt.Llm.Mock, :chat_completion, fn received_context, _options ->
        assert %Message{role: :user, content: content} = Context.last_message(received_context)

        assert %{"type" => "user_message", "message" => ^message_text, "time" => time} =
                 Jason.decode!(content)

        assert {:ok, _, 0} = DateTime.from_iso8601(time)
        {:ok, received_context}
      end)

      Agent.new(UUID.uuid4())
      |> Agent.handle_process_user_message(message_text)
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

    test "if the llm response is a function call, it executes the function" do
      function_call = FunctionCall.new(:some_function, %{"foo" => "bar"})

      expect(MemGpt.Llm.Mock, :chat_completion, fn context, _options ->
        {:ok, Context.append_message(context, function_call)}
      end)

      expect(FunctionCall.Mock, :execute, fn received_function_call ->
        assert received_function_call == function_call
        {:ok, "some response"}
      end)

      Agent.new(UUID.uuid4())
      |> Agent.handle_process_user_message(Faker.Lorem.sentence())
    end
  end
end
