defmodule MemGpt.Agent.Context do
  @moduledoc """
  This module defines the context for the MemGpt Agent.

  The context is a list of messages.

  ## Examples

      iex> alias MemGpt.Agent.Message
      iex> message = Message.new(:user, "Hello, world!")
      iex> context = MemGpt.Agent.Context.new()
      iex> context = MemGpt.Agent.Context.append_message(context, message)
      iex> MemGpt.Agent.Context.last_message(context)
      %Message{role: :user, content: "Hello, world!"}

  """
  use TypedStruct

  alias MemGpt.Agent.FunctionCall
  alias MemGpt.Agent.Message
  alias MemGpt.Llm.OpenAi.MessageList

  @derive Jason.Encoder
  typedstruct do
    field(:messages, list(Message.t()), default: [])
  end

  @doc """
  Creates a new context.

  ## Examples

      iex> MemGpt.Agent.Context.new()
      %MemGpt.Agent.Context{messages: []}

  """
  @spec new(system_message :: binary()) :: t()
  def new(system_message) when is_binary(system_message) do
    system_message = Message.new(:system, system_message)
    %__MODULE__{messages: [system_message]}
  end

  @doc """
  Appends a message to the context.

  ## Examples

      iex> alias MemGpt.Agent.Message
      iex> message = Message.new(:user, "Hello, world!")
      iex> context = MemGpt.Agent.Context.new()
      iex> context = MemGpt.Agent.Context.append_message(context, message)
      iex> MemGpt.Agent.Context.last_message(context)
      %Message{role: :user, content: "Hello, world!"}

  """
  @spec append_message(t(), Message.t() | FunctionCall.t()) :: t()
  def append_message(%__MODULE__{} = context, %Message{} = message) do
    %{context | messages: context.messages ++ [message]}
  end

  def append_message(%__MODULE__{} = context, %FunctionCall{} = message) do
    %{context | messages: context.messages ++ [message]}
  end

  @doc """
  Returns the last message in the context.

  ## Examples

      iex> alias MemGpt.Agent.Message
      iex> message = Message.new(:user, "Hello, world!")
      iex> context = MemGpt.Agent.Context.new()
      iex> context = MemGpt.Agent.Context.append_message(context, message)
      iex> MemGpt.Agent.Context.last_message(context)
      %Message{role: :user, content: "Hello, world!"}

  """
  @spec last_message(t()) :: Message.t()
  def last_message(%__MODULE__{messages: messages}) do
    List.last(messages)
  end

  defimpl MessageList do
    def convert(context) do
      context.messages
    end
  end
end
