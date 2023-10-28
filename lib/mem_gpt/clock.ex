defmodule MemGpt.Clock do
  @moduledoc """
  A Clock module that provides the current time.

  This module is used to abstract the system clock, allowing for easier testing and time manipulation.
  """

  use Knigge, otp_app: :mem_gpt, default: MemGpt.Clock.Impl

  @callback now() :: DateTime.t()
  @doc """
  Returns the current DateTime in UTC.

  ## Examples

      iex> MemGpt.Clock.now()
      ~U[2022-01-01T00:00:00Z]
  """

  defmodule Impl do
    @moduledoc """
    This is the implementation module for the Clock. It provides the current DateTime in UTC.
    """
    @behaviour MemGpt.Clock

    @doc """
    Returns the current DateTime in UTC.

    This is the default implementation of the `now/0` function.

    ## Examples

        iex> MemGpt.Clock.Impl.now()
        ~U[2022-01-01T00:00:00Z]
    """
    @spec now() :: DateTime.t()
    def now do
      DateTime.utc_now()
    end
  end
end
