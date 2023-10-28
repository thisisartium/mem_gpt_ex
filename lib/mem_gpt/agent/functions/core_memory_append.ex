defmodule MemGpt.Agent.Functions.CoreMemoryAppend do
  @moduledoc """
  A module that provides a function to append to the contents of core memory.
  """
  @function_name :core_memory_append

  @doc """
  Returns the schema for the core_memory_append function.

  ## Examples

      iex> MemGpt.Agent.Functions.CoreMemoryAppend.schema()
      %{
        name: "core_memory_append",
        description: "Append to the contents of core memory.",
        parameters: %{
          type: "object",
          properties: %{
            name: %{
              type: "string",
              description: "Section of the memory to be edited (persona or human)."
            },
            content: %{
              type: "string",
              description: "Content to write to the memory. All unicode (including emojis) are supported."
            },
            request_heartbeat: %{
              type: "boolean",
              description: "Request an immediate heartbeat after function execution. Set to 'true' if you want to send a follow-up message or run a follow-up function."
            }
          },
          required: ["name", "content", "request_heartbeat"]
        }
      }
  """
  @spec schema() :: map()
  def schema do
    %{
      name: to_string(@function_name),
      description: "Append to the contents of core memory.",
      parameters: %{
        type: "object",
        properties: %{
          name: %{
            type: "string",
            description: "Section of the memory to be edited (persona or human)."
          },
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
        required: ["name", "content", "request_heartbeat"]
      }
    }
  end

  @doc """
  Executes the core_memory_append function with the given parameters.

  ## Examples

      iex> MemGpt.Agent.Functions.CoreMemoryAppend.execute(%{"name" => "persona", "content" => "Hello, world!", "request_heartbeat" => true})
      {:cont, nil}
  """
  @spec execute(map()) :: {:cont, nil} | {:ok, nil}
  def execute(%{"name" => _name, "content" => _content, "request_heartbeat" => request_heartbeat}) do
    {if(request_heartbeat, do: :cont, else: :ok), nil}
  end
end
