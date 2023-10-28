defmodule MemGpt.Agent.FunctionCall do
  @moduledoc """
  A FunctionCall represents a function call with a name and arguments.
  """

  use Knigge, otp_app: :mem_gpt, default: __MODULE__.Impl
  use TypedStruct

  typedstruct do
    field(:name, atom(), enforce: true)
    field(:arguments, map(), enforce: true)
  end

  @callback execute(t()) :: {:ok, term()} | {:error, term()}

  @doc """
  Creates a new FunctionCall struct with the given name and args.

  Args must be a map or keyword list.

  ## Examples

      iex> MemGpt.Agent.FunctionCall.new(:send_user_message, %{"message" => "Hello, world!"})
      %MemGpt.Agent.FunctionCall{name: :send_user_message, args: %{"message" => "Hello, world!"}}
  """
  @spec new(String.t(), map() | keyword()) :: t()
  def new(name, args) when is_map(args) do
    name = to_string(name)
    args = for {k, v} <- args, into: %{}, do: {Kernel.to_string(k), v}
    %__MODULE__{name: name, arguments: args}
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

  defmodule Impl do
    @moduledoc false

    @behaviour MemGpt.Agent.FunctionCall

    alias MemGpt.Agent.Functions.ArchivalMemoryInsert
    alias MemGpt.Agent.Functions.ArchivalMemorySearch
    alias MemGpt.Agent.Functions.ConversationSearch
    alias MemGpt.Agent.Functions.CoreMemoryAppend
    alias MemGpt.Agent.Functions.CoreMemoryReplace
    alias MemGpt.Agent.Functions.SendUserMessage

    @impl true
    def execute(%MemGpt.Agent.FunctionCall{name: function_name, arguments: arguments}) do
      module =
        case function_name do
          "archival_memory_insert" -> ArchivalMemoryInsert
          "archival_memory_search" -> ArchivalMemorySearch
          "conversation_search" -> ConversationSearch
          "core_memory_append" -> CoreMemoryAppend
          "core_memory_replace" -> CoreMemoryReplace
          "send_user_message" -> SendUserMessage
        end

      module.execute(arguments)
    end
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

defimpl Jason.Encoder, for: MemGpt.Agent.FunctionCall do
  alias MemGpt.Agent.FunctionCall

  @doc """
  Serializes the FunctionCall struct into the JSON format expected by OpenAI.
  """
  def encode(%FunctionCall{name: name, arguments: args}, opts) do
    Jason.Encoder.encode(
      %{
        role: "assistant",
        function_call: %{
          name: name,
          arguments: Jason.encode!(args)
        },
        content: nil
      },
      opts
    )
  end
end
