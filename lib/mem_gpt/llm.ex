defmodule MemGpt.Llm do
  @moduledoc """
  This module defines the interface for the Large Language Model (LLM).
  """

  use Knigge, otp_app: :mem_gpt, default: __MODULE__.Impl

  alias MemGpt.Agent.Context
  alias MemGpt.Agent.FunctionCall
  alias MemGpt.Agent.Thought

  alias MemGpt.Llm.OpenAi

  @callback chat_completion(context :: Context.t(), options :: Keyword.t()) ::
              {:ok, Context.t()} | {:error, term()}

  defmodule Impl do
    @moduledoc """
    This module provides the default implementation for the LLM behaviour.
    """

    @behaviour MemGpt.Llm

    alias MemGpt.Llm.OpenAi.MessageList

    @impl true
    @doc """
    Completes a chat context using the LLM.

    The function takes a context and options as arguments and returns either a
    successful result with the completed context or an error.

    ## Examples

        iex> alias MemGpt.Agent.Context
        iex> context = Context.new()
        iex> MemGpt.Llm.Impl.chat_completion(context, [])
        {:ok, context}
    """
    def chat_completion(%Context{} = context, options) do
      messages =
        MessageList.convert(context)

      options =
        Keyword.validate!(
          options,
          messages: messages,
          model: "gpt-4-0613",
          frequency_penalty: nil,
          function_call: "auto",
          functions: [],
          logit_bias: nil,
          max_tokens: nil,
          n: nil,
          presence_penalty: nil,
          stop: nil,
          stream: false,
          temperature: nil,
          top_p: nil,
          user: nil
        )
        |> Keyword.reject(fn {_k, v} -> v == nil end)

      message =
        case OpenAi.chat_completion(options) do
          {:ok, %{choices: [%{"message" => %{"function_call" => function_call}}]}} ->
            FunctionCall.Conversion.convert(function_call)

          {:ok, %{choices: [%{"message" => %{"content" => content}}]}} when is_binary(content) ->
            case Jason.decode(content) do
              {:ok, %{"type" => "ai_thought", "thought" => thought}} ->
                Thought.new(thought)

              _ ->
                Thought.new(content)
            end
        end

      context = Context.append_message(context, message)
      {:ok, context}
    end
  end
end
