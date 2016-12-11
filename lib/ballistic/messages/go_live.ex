defmodule Ballistic.Messages.GoLive do
  @derive [Poison.Encoder]
  defstruct [:red, :green, :blue]
end
