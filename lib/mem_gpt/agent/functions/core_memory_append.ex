defmodule MemGpt.Agent.Functions.CoreMemoryAppend do
  @function_name :core_memory_append

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
end
