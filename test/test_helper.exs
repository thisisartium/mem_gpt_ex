Mox.defmock(MemGpt.Llm.Mock, for: MemGpt.Llm)
Application.put_env(:mem_gpt, MemGpt.Llm, MemGpt.Llm.Mock)

Mox.defmock(MemGpt.Llm.OpenAi.Mock, for: MemGpt.Llm.OpenAi)
Application.put_env(:mem_gpt, MemGpt.Llm.OpenAi, MemGpt.Llm.OpenAi.Mock)

Mox.defmock(MemGpt.Agent.FunctionCall.Mock, for: MemGpt.Agent.FunctionCall)
Application.put_env(:mem_gpt, MemGpt.Agent.FunctionCall, MemGpt.Agent.FunctionCall.Mock)

ExUnit.start()
