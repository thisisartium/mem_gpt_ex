defmodule MemGpt.Agent.FunctionCall do
  @moduledoc """
  A FunctionCall represents a function call with a name and arguments.
  """

  use TypedStruct

  typedstruct do
    field(:name, atom(), enforce: true)
    field(:args, map(), enforce: true)
  end

  @doc """
  Creates a new FunctionCall struct with the given name and args.

  Args must be a map or keyword list.

  ## Examples

      iex> MemGpt.Agent.FunctionCall.new(:send_user_message, %{"message" => "Hello, world!"})
      %MemGpt.Agent.FunctionCall{name: :send_user_message, args: %{"message" => "Hello, world!"}}
  """
  @spec new(atom(), map() | keyword()) :: t()
  def new(name, args) when is_atom(name) and is_map(args) do
    args = for {k, v} <- args, into: %{}, do: {Kernel.to_string(k), v}
    %__MODULE__{name: name, args: args}
  end

  def new(name, args) when is_list(args) do
    new(name, Enum.into(args, %{}))
  end

  defprotocol Conversion do
    @moduledoc """
    The Conversion protocol is used to convert different data types into a FunctionCall struct.
    """
    alias MemGpt.Agent.FunctionCall

    @doc """
    Converts the given data into a FunctionCall struct.
    """
    @spec convert(data :: term()) :: FunctionCall.t()
    def convert(data)
  end
end

defimpl MemGpt.Agent.FunctionCall.Conversion, for: Map do
  alias MemGpt.Agent.FunctionCall

  @doc """
  Converts a map with a JSON string of arguments into a FunctionCall struct.
  """
  @spec convert(map()) :: FunctionCall.t()
  def convert(%{"arguments" => args} = data) when is_binary(args) do
    convert(Map.put(data, "arguments", Jason.decode!(args)))
  end

  def convert(%{"name" => name, "arguments" => args}) when is_binary(name) and is_map(args) do
    FunctionCall.new(String.to_existing_atom(name), args)
  end
end