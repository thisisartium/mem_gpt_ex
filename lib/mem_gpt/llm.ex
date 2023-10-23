defmodule MemGpt.Llm do
  @moduledoc """
  This module defines the interface for the Large Language Model (LLM).
  """

  use Knigge, otp_app: :mem_gpt, default: __MODULE__.Impl

  alias MemGpt.Agent.Context
  alias MemGpt.Agent.Message
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
    def chat_completion(%Context{} = context, _options) do
      {:ok, %{choices: [%{"message" => %{"content" => content}}]}} =
        OpenAi.chat_completion(messages: MessageList.convert(context), model: "gpt-4-0613")

      message = Message.new(:assistant, content)
      context = Context.append_message(context, message)
      {:ok, context}
    end
  end
end
