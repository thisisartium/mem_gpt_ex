Mox.defmock(MemGpt.Llm.Mock, for: MemGpt.Llm)
Application.put_env(:mem_gpt, MemGpt.Llm, MemGpt.Llm.Mock)
ExUnit.start()
