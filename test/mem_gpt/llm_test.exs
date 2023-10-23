defmodule MemGpt.LlmTest do
  @moduledoc false

  use MemGpt.TestCase, async: true

  alias MemGpt.Agent.Context
  alias MemGpt.Agent.Message
  alias MemGpt.Llm.Impl, as: Llm
  alias MemGpt.Llm.OpenAi
  alias MemGpt.Llm.OpenAi.MessageList

  describe "chat_completion/2" do
    test "returns {:ok, context} if the chat completion is successful" do
      user_message = Message.new(:user, Faker.Lorem.sentence())
      assistant_message = Message.new(:assistant, Faker.Lorem.sentence())

      context =
        Context.new()
        |> Context.append_message(user_message)

      expected_context = Context.append_message(context, assistant_message)

      expect(OpenAi.Mock, :chat_completion, fn params ->
        assert Keyword.get(params, :messages) == MessageList.convert(context)
        assert Keyword.get(params, :model) == "gpt-4-0613"

        {:ok,
         %{
           choices: [
             %{
               "finish_reason" => "stop",
               "index" => 0,
               "message" => %{
                 "content" => assistant_message.content,
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

      assert Llm.chat_completion(context, []) == {:ok, expected_context}
    end
  end
end