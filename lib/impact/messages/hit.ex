defmodule Impact.Messages.Hit do
  @derive [Poison.Encoder]
  defstruct [:deviceId, :timestamp]
end
