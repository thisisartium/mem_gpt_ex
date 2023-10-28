defmodule MemGpt.Agent.Functions.ArchivalMemoryInsert do
  @function_name :archival_memory_insert

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

  def execute(%{"content" => _content, "request_heartbeat" => request_heartbeat}) do
    {if(request_heartbeat, do: :cont, else: :ok), nil}
  end
end
