import Config

config :mem_gpt, MemGpt, openai_api_key: System.get_env("OPENAI_API_KEY")
