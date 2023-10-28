defmodule MemGpt.Agent.Functions.ConversationSearch do
  @function_name :conversation_search

  @spec schema() :: map()
  def schema do
    %{
      name: to_string(@function_name),
      description: "Search prior conversation history using case-insensitive string matching.",
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
        required: ["name", "request_heartbeat"]
      }
    }
  end

  def execute(%{"query" => _query, "request_heartbeat" => request_heartbeat}) do
    {if(request_heartbeat, do: :cont, else: :ok), []}
  end
end
