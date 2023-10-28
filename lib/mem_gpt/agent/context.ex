defmodule MemGpt.Agent.Context do
  @moduledoc """
  This module defines the context for the MemGpt Agent.

  The context is a list of messages.

  ## Examples

      iex> alias MemGpt.Agent.UserMessage
      iex> message = UserMessage.new( "Hello, world!")
      iex> context = MemGpt.Agent.Context.new()
      iex> context = MemGpt.Agent.Context.append_message(context, message)
      iex> MemGpt.Agent.Context.last_message(context)
      %UserMessage{role: :user, content: "Hello, world!"}

  """
  use TypedStruct

  alias MemGpt.Agent.FunctionCall
  alias MemGpt.Agent.SystemMessage
  alias MemGpt.Agent.Thought
  alias MemGpt.Agent.UserMessage
  alias MemGpt.Llm.OpenAi.MessageList

  @derive Jason.Encoder
  typedstruct do
    field(:system_message, SystemMessage.t(), enforce: true)

    field(:messages, list(UserMessage.t() | FunctionCall.t() | Thought.t() | SystemMessage.t()),
      default: []
    )
  end

  @doc """
  Creates a new context.

  ## Examples

      iex> MemGpt.Agent.Context.new()
      %MemGpt.Agent.Context{messages: []}

  """
  def new(system_message) when is_binary(system_message) do
    system_message = SystemMessage.new(system_message)
    %__MODULE__{system_message: system_message, messages: [system_message]}
  end

  @doc """
  Appends a message to the context.

  ## Examples

      iex> alias MemGpt.Agent.UserMessage
      iex> message = UserMessage.new( "Hello, world!")
      iex> context = MemGpt.Agent.Context.new()
      iex> context = MemGpt.Agent.Context.append_message(context, message)
      iex> MemGpt.Agent.Context.last_message(context)
      %UserMessage{role: :user, content: "Hello, world!"}

  """
  @spec append_message(t(), UserMessage.t() | FunctionCall.t() | Thought.t() | SystemMessage.t()) ::
          t()
  def append_message(%__MODULE__{} = context, message)
      when is_struct(message, UserMessage) or is_struct(message, FunctionCall) or
             is_struct(message, SystemMessage) or is_struct(message, Thought) do
    print(message)
    %{context | messages: context.messages ++ [message]}
  end

  defp print(%UserMessage{}) do
    :ok
  end

  defp print(%FunctionCall{name: name, arguments: arguments}) do
    IO.puts("☑️ - Calling function #{name} with arguments #{inspect(arguments)}")
    :ok
  end

  defp print(%SystemMessage{}) do
    :ok
  end

  defp print(%Thought{thought: thought}) do
    IO.puts("🤔 - Thinking... #{thought}")
    :ok
  end

  @doc """
  Returns the last message in the context.

  ## Examples

      iex> alias MemGpt.Agent.UserMessage
      iex> message = UserMessage.new( "Hello, world!")
      iex> context = MemGpt.Agent.Context.new()
      iex> context = MemGpt.Agent.Context.append_message(context, message)
      iex> MemGpt.Agent.Context.last_message(context)
      %UserMessage{role: :user, content: "Hello, world!"}

  """
  @spec last_message(t()) :: UserMessage.t() | FunctionCall.t() | SystemMessage.t() | Thought.t()
  def last_message(%__MODULE__{messages: messages}) do
    List.last(messages)
  end

  defimpl MessageList do
    def convert(context) do
      context.messages
    end
  end
end
