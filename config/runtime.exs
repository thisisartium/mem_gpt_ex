import Config

config :mem_gpt, MemGPT, openai_api_key: System.get_env("OPENAI_API_KEY")
