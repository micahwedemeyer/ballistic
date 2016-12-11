defmodule Ballistic.Messages.Hit do
  @derive [Poison.Encoder]
  defstruct [:deviceId, :timestamp]
end
