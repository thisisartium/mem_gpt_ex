defmodule MemGpt.Agent.Functions.CoreMemoryReplace do
  @function_name :core_memory_replace

  @spec schema() :: map()
  def schema do
    %{
      name: to_string(@function_name),
      description:
        "Replace to the contents of core memory. To delete memories, use an empty string for new_content.",
      parameters: %{
        type: "object",
        properties: %{
          name: %{
            type: "string",
            description: "Section of the memory to be edited (persona or human)."
          },
          old_content: %{
            type: "string",
            description: "String to replace. Must be an exact match."
          },
          new_content: %{
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
        required: ["name", "old_content", "new_content", "request_heartbeat"]
      }
    }
  end
end
