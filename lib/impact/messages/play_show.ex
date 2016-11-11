defmodule Impact.Messages.PlayShow do
  @derive [Poison.Encoder]
  defstruct [:showId]
end
