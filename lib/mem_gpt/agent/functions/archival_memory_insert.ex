defmodule MemGpt.Agent.Functions.ArchivalMemoryInsert do
  @moduledoc """
  A module that provides a function to insert content into the archival memory.
  """
  @function_name :archival_memory_insert

  @doc """
  Returns the schema for the archival memory insert function.

  ## Examples

      iex> MemGpt.Agent.Functions.ArchivalMemoryInsert.schema()
      %{
        name: "archival_memory_insert",
        description: "Add to archival memory. Make sure to phrase the memory contents such that it can be easily queried later.",
        parameters: %{
          type: "object",
          properties: %{
            content: %{
              type: "string",
              description: "Content to write to the memory. All unicode (including emojis) are supported."
            },
            request_heartbeat: %{
              type: "boolean",
              description: "Request an immediate heartbeat after function execution. Set to 'true' if you want to send a follow-up message or run a follow-up function."
            }
          },
          required: ["content", "request_heartbeat"]
        }
      }
  """
  @spec schema() :: map()
  def schema do
    %{
      name: to_string(@function_name),
      description:
        "Add to archival memory. Make sure to phrase the memory contents such that it can be easily queried later.",
      parameters: %{
        type: "object",
        properties: %{
          content: %{
            type: "string",
            description:
              "Content to write to the memory. All unicode (including emojis) are supported."
          },
          request_heartbeat: %{
            type: "boolean",
            description:
              "Request an immediate heartbeat after function execution. Set to 'true' if you want to send a follow-up message or run a follow-up function."
          }
        },
        required: ["content", "request_heartbeat"]
      }
    }
  end

  @doc """
  Executes the archival memory insert function with the given parameters.

  ## Examples

      iex> MemGpt.Agent.Functions.ArchivalMemoryInsert.execute(%{"content" => "Hello, world!", "request_heartbeat" => true})
      {:cont, nil}

      iex> MemGpt.Agent.Functions.ArchivalMemoryInsert.execute(%{"content" => "Hello, world!", "request_heartbeat" => false})
      {:ok, nil}
  """
  @spec execute(map()) :: {:cont | :ok, nil}
  def execute(%{"content" => _content, "request_heartbeat" => request_heartbeat}) do
    {if(request_heartbeat, do: :cont, else: :ok), nil}
  end
end
