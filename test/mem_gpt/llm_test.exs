defmodule MemGpt.LlmTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Agent.Context
  alias MemGpt.Agent.FunctionCall
  alias MemGpt.Agent.Functions.SendUserMessage
  alias MemGpt.Agent.Thought
  alias MemGpt.Agent.UserMessage
  alias MemGpt.Llm.Impl, as: Llm
  alias MemGpt.Llm.OpenAi
  alias MemGpt.Llm.OpenAi.MessageList

  describe "chat_completion/2" do
    test "returns {:ok, context} if the chat completion is successful" do
      user_message = UserMessage.new(Faker.Lorem.sentence())
      assistant_message = Thought.new(Faker.Lorem.sentence())

      context =
        Context.new("system message")
        |> Context.append_message(user_message)

      expected_context = Context.append_message(context, assistant_message)

      options = [
        function_call: "auto",
        functions: [SendUserMessage.schema()]
      ]

      expect(OpenAi.Mock, :chat_completion, fn params ->
        assert Keyword.get(params, :messages) == MessageList.convert(context)
        assert Keyword.get(params, :model) == "gpt-4-0613"
        assert Keyword.get(params, :function_call) == "auto"
        assert Keyword.get(params, :functions) == [SendUserMessage.schema()]

        {:ok,
         %{
           choices: [
             %{
               "finish_reason" => "stop",
               "index" => 0,
               "message" => %{
                 "content" =>
                   %{
                     type: "ai_thought",
                     thought: assistant_message.thought,
                     time: DateTime.to_iso8601(assistant_message.time)
                   }
                   |> Jason.encode!(),
                 "role" => "assistant"
               }
             }
           ],
           created: 1_677_773_799,
           id: "chatcmpl-6pftfA4NO9pOQIdxao6Z4McDlx90l",
           model: "gpt-4-0613",
           object: "chat.completion",
           usage: %{
             "completion_tokens" => 26,
             "prompt_tokens" => 56,
             "total_tokens" => 82
           }
         }}
      end)

      assert Llm.chat_completion(context, options) == {:ok, expected_context}
    end

    test "handles function call responses from the LLM" do
      user_message = UserMessage.new(Faker.Lorem.sentence())

      assistant_message =
        FunctionCall.new(:send_user_message, message: Faker.Lorem.sentence())

      context =
        Context.new("system message")
        |> Context.append_message(user_message)

      expected_context = Context.append_message(context, assistant_message)

      options = [
        function_call: "auto",
        functions: [SendUserMessage.schema()]
      ]

      expect(OpenAi.Mock, :chat_completion, fn params ->
        assert Keyword.get(params, :messages) == MessageList.convert(context)
        assert Keyword.get(params, :model) == "gpt-4-0613"
        assert Keyword.get(params, :function_call) == "auto"
        assert Keyword.get(params, :functions) == [SendUserMessage.schema()]

        {:ok,
         %{
           choices: [
             %{
               "finish_reason" => "stop",
               "index" => 0,
               "message" => %{
                 "content" => nil,
                 "function_call" => %{
                   "name" => "send_user_message",
                   "arguments" => %{"message" => assistant_message.arguments["message"]}
                 },
                 "role" => "assistant"
               }
             }
           ],
           created: 1_677_773_799,
           id: "chatcmpl-6pftfA4NO9pOQIdxao6Z4McDlx90l",
           model: "gpt-4-0613",
           object: "chat.completion",
           usage: %{
             "completion_tokens" => 26,
             "prompt_tokens" => 56,
             "total_tokens" => 82
           }
         }}
      end)

      assert Llm.chat_completion(context, options) == {:ok, expected_context}
    end
  end
end
