defmodule MemGpt.Agent.FunctionResponse do
  @moduledoc """
  This module defines the structure of a function response in the MemGpt.Agent.

  A function response is a struct with two fields: `status` and `content`.
  `status` is either `:ok` or `:error`, and `content` is a string.

  ## Examples

      iex> MemGpt.Agent.FunctionResponse.new(:ok, "Hello, world!")
      %MemGpt.Agent.FunctionResponse{status: :ok, content: "Hello, world!"}
  """

  use TypedStruct

  typedstruct do
    field(:name, String.t(), enforce: true)
    field(:status, :ok | :cont | :error, enforce: true)
    field(:content, Jason.Encoder.t(), enforce: true)
  end

  @doc """
  Creates a new function response.

  ## Examples

      iex> MemGpt.Agent.FunctionResponse.new(:ok, "Hello, world!")
      %MemGpt.Agent.FunctionResponse{status: :ok, content: "Hello, world!"}
  """
  @spec new(:ok | :cont | :error, String.t(), Jason.Encoder.t()) :: %__MODULE__{}
  def new(status, name, content) do
    %__MODULE__{status: status, name: name, content: content}
  end
end

defimpl Jason.Encoder, for: MemGpt.Agent.FunctionResponse do
  def encode(%MemGpt.Agent.FunctionResponse{status: status, name: name, content: content}, opts) do
    %{role: "function", name: name, content: Jason.encode!(%{status: status, content: content})}
    |> Jason.Encoder.encode(opts)
  end
end
