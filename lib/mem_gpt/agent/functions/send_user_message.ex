defmodule MemGpt.Agent.Functions.SendUserMessage do
  def schema() do
    %{
      name: "send_user_message",
      description: "Sends a message to the human user",
      parameters: %{
        type: "object",
        properties: %{
          message: %{
            type: "string",
            description: "Message contents. All unicode (including emojis) are supported."
          }
        },
        required: ["message"]
      }
    }
  end
end
