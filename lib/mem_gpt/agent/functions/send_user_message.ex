defmodule MemGpt.Agent.Functions.SendUserMessage do
  @moduledoc """
  This module is responsible for sending a message to the human user.
  """

  @function_name :send_user_message

  @doc """
  Returns the function schema to pass to the LLM

  Although this returns an Elixir map, it is suitable for conversion to JSON and
  adheres to [the JSON Schema
  specification](https://json-schema.org/understanding-json-schema).
  """
  @spec schema() :: map()
  def schema do
    %{
      name: to_string(@function_name),
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
