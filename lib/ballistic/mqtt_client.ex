defmodule Ballistic.MqttClient do
  alias Hulaaki.Message.Publish
  use Hulaaki.Client

  # Define like this to override/overrule the start_link in Hulaaki.Client
  def start_link({:first}, name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: name)
    {:ok, connect(pid)}
  end

  def connect(pid) do
    opts = [
      client_id: Application.get_env(:ballistic, :mqtt_client_id),
      host: Application.get_env(:ballistic, :mqtt_host),
      port: Application.get_env(:ballistic, :mqtt_port)
    ]

    # Call Hulaaki.Client.connect
    connect(pid, opts)
    pid
  end

  # Public API
  def go_live(deviceId, {red, green, blue}) do
    message = Poison.encode!(%Ballistic.Messages.GoLive{red: red, green: green, blue: blue})
    publish(topic: "darter/#{deviceId}/goLive", message: message, qos: 0, dup: 0, retain: 0)
  end

  def subscribe_to_hits do
    subscribe(id: 1, topics: ["hits"], qoses: [0])
  end

  # Private'ish API
  def subscribe(options) do
    GenServer.whereis(__MODULE__)
    |> subscribe(options)
  end

  def publish(options) do
    GenServer.whereis(__MODULE__)
    |> publish(options)
  end

  # Override callbacks from Hulaaki.Client
  def on_subscribed_publish(message: %Publish{topic: "hits"} = message, state: _) do
    hit = Poison.decode!(message.message, as: %Ballistic.Messages.Hit{})
    Ballistic.Target.hit(hit[:deviceId], hit[:timestamp])
  end

  def on_subscribed_publish(message: %Publish{topic: "introduction"} = message, state: _) do
    intro = Poison.decode!(message.message, as: %Ballistic.Messages.Introduction{})
    Ballistic.TargetSupervisor.init_target(intro[:deviceId])
  end
end