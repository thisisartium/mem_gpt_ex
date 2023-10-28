defmodule MemGpt.Clock do
  use Knigge, otp_app: :mem_gpt, default: MemGpt.Clock.Impl

  @callback now() :: DateTime.t()

  defmodule Impl do
    @behaviour MemGpt.Clock

    @spec now() :: DateTime.t()
    def now() do
      DateTime.utc_now()
    end
  end
end
