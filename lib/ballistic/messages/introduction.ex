defmodule Ballistic.Messages.Introduction do
  @derive [Poison.Encoder]
  defstruct [:deviceId]
end
