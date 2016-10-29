defmodule Impact.SampleClient do
  use Hulaaki.Client

  def on_connect_ack(options) do
    IO.inspect options
  end

  def on_subscribed_publish(options) do
    IO.inspect options
  end

  def on_subscribe_ack(options) do
    IO.inspect options
  end

  def on_pong(options) do
    IO.inspect options
  end
end