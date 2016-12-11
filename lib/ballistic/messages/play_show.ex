defmodule Ballistic.Messages.PlayShow do
  @derive [Poison.Encoder]
  defstruct [:showId, :loop]
end
