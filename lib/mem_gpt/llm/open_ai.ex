defmodule MemGpt.Llm.OpenAi do
  @moduledoc """
  This module provides an interface for interacting with the OpenAI API.
  """

  use Knigge, otp_app: :mem_gpt, default: __MODULE__.Impl

  @type index :: integer()
  @type message :: %{String.t() => String.t()}
  @type finish_reason :: String.t()
  @type usage :: %{String.t() => integer()}

  @type choice :: %{String.t() => index() | message() | finish_reason()}

  @type chat_completion_response :: %{
          choices: list(choice()),
          created: integer(),
          id: String.t(),
          model: String.t(),
          object: String.t(),
          usage: usage()
        }

  @doc """
  Sends a chat completion request to the OpenAI API.

  ## Examples

      iex> MemGpt.Llm.OpenAi.chat_completion([messages: [%{role: "system", content: "You are a helpful assistant."}], model: "gpt-4-0613"])
      {:ok, %{choices: [%{message: %{content: "I'm here to help! How can I assist you today?"}}]}}
  """
  @callback chat_completion(params :: keyword(), config :: struct()) ::
              {:ok, chat_completion_response()} | {:error, term()}

  @doc """
  Sends a chat completion request to the OpenAI API without a specific configuration.

  ## Examples

      iex> MemGpt.Llm.OpenAi.chat_completion([messages: [%{role: "system", content: "You are a helpful assistant."}], model: "gpt-4-0613"])
      {:ok, %{choices: [%{message: %{content: "I'm here to help! How can I assist you today?"}}]}}
  """
  @callback chat_completion(params :: keyword()) ::
              {:ok, chat_completion_response()} | {:error, term()}

  defprotocol MessageList do
    @moduledoc """
    This protocol defines the interface for converting a message list to a format suitable for the OpenAI API.
    """
    @spec convert(t()) :: MessageList.t()
    @doc """
    Converts a message list to a format suitable for the OpenAI API.
    """
    def convert(message_list)
  end

  defmodule Impl do
    @moduledoc """
    This module provides the default implementation for the `MemGpt.Llm.OpenAi` behaviour.
    """

    @behaviour MemGpt.Llm.OpenAi

    @doc """
    Delegates the chat completion request to the OpenAI API with a specific configuration.
    """
    defdelegate chat_completion(params, config), to: OpenAI

    @doc """
    Delegates the chat completion request to the OpenAI API without a specific configuration.
    """
    defdelegate chat_completion(params), to: OpenAI
  end
end
