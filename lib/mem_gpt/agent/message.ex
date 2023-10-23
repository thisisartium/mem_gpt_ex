defmodule MemGpt.Agent.Message do
  @moduledoc """
  This module defines the structure of a message in the MemGpt Agent.

  A message has a role and content. The role can be :user, :assistant, or :system.

  ## Examples

      iex> alias MemGpt.Agent.Message
      iex> message = Message.new(:user, "Hello, world!")
      iex> message.role
      :user
      iex> message.content
      "Hello, world!"
  """

  use TypedStruct

  @type role :: :user | :assistant | :system

  @derive Jason.Encoder
  typedstruct do
    field(:role, role(), enforce: true)
    field(:content, String.t())
  end

  @doc """
  Creates a new message.

  ## Examples

      iex> alias MemGpt.Agent.Message
      iex> message = Message.new(:user, "Hello, world!")
      iex> message.role
      :user
      iex> message.content
      "Hello, world!"
  """
  @spec new(role(), String.t()) :: t()
  def new(role, content) when role in [:user, :assistant, :system] and is_binary(content) do
    %__MODULE__{role: role, content: content}
  end
end
