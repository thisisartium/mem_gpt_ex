defmodule MemGPT.Application do
  use Application

  def start(_type, _args) do
    children = [{MemGPT.DynamicSupervisor, []}]
    opts = [strategy: :one_for_one, name: MemGPT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
