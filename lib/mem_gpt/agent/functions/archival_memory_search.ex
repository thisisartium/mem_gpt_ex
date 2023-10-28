defmodule MemGpt.Agent.Functions.ArchivalMemorySearch do
  @moduledoc """
  A module that provides a function to search archival memory using semantic (embedding-based) search.
  """
  @function_name :archival_memory_search

  @doc """
  Returns the schema for the archival memory search function.

  ## Examples

      iex> MemGpt.Agent.Functions.ArchivalMemorySearch.schema()
      %{
        name: "archival_memory_search",
        description: "Search archival memory using semantic (embedding-based) search.",
        parameters: %{
          type: "object",
          properties: %{
            query: %{
              type: "string",
              description: "String to search for."
            },
            page: %{
              type: "integer",
              description: "Allows you to page through results. Only use on a follow-up query. Defaults to 0 (first page)."
            },
            request_heartbeat: %{
              type: "boolean",
              description: "Request an immediate heartbeat after function execution. Set to 'true' if you want to send a follow-up message or run a follow-up function."
            }
          },
          required: ["query", "request_heartbeat"]
        }
      }
  """
  @spec schema() :: map()
  def schema do
    %{
      name: to_string(@function_name),
      description: "Search archival memory using semantic (embedding-based) search.",
      parameters: %{
        type: "object",
        properties: %{
          query: %{
            type: "string",
            description: "String to search for."
          },
          page: %{
            type: "integer",
            description:
              "Allows you to page through results. Only use on a follow-up query. Defaults to 0 (first page)."
          },
          request_heartbeat: %{
            type: "boolean",
            description:
              "Request an immediate heartbeat after function execution. Set to 'true' if you want to send a follow-up message or run a follow-up function."
          }
        },
        required: ["query", "request_heartbeat"]
      }
    }
  end

  @doc """
  Executes the archival memory search function.

  ## Parameters

  - `params`: A map containing the parameters for the function. It must include:
    - `"query"`: The string to search for.
    - `"request_heartbeat"`: A boolean indicating whether to request an immediate heartbeat after function execution.

  ## Examples

      iex> MemGpt.Agent.Functions.ArchivalMemorySearch.execute(%{"query" => "test", "request_heartbeat" => true})
      {:cont, []}

  """
  @spec execute(map()) :: {:cont | :ok, list()}
  def execute(%{"query" => _query, "request_heartbeat" => request_heartbeat}) do
    {if(request_heartbeat, do: :cont, else: :ok), []}
  end
end
