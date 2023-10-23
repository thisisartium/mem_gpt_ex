import Config

config :mem_gpt, MemGpt, openai_api_key: System.get_env("OPENAI_API_KEY")
config :openai, :api_key, System.get_env("OPENAI_API_KEY")

receive_timeout = System.get_env("OPENAI_RECEIVE_TIMEOUT", "60000") |> String.to_integer()
config :openai, :http_options, recv_timeout: receive_timeout
