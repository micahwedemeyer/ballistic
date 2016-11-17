defmodule Impact.TargetMqttClient do
  require Logger
  alias Hulaaki.Message.Publish
  use Hulaaki.Client

  # Define like this to override/overrule the start_link in Hulaaki.Client
  def start_link({:first}, name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: name)
    {:ok, connect(pid)}
  end

  def connect(pid) do
    opts = [
      client_id: "target-mqtt-client",
      host: Application.get_env(:impact, :mqtt_host),
      port: Application.get_env(:impact, :mqtt_port)
    ]

    # Call Hulaaki.Client.connect
    connect(pid, opts)
    pid
  end

  def subscribe_to_hits do
    subscribe(id: 1, topics: ["darter/+/hits"], qoses: [0])
  end

  def play_show(device_id, show_id) do
    message = Poison.encode!(%Impact.Messages.PlayShow{showId: show_id})
    publish(topic: "darter/#{device_id}/playShow", message: message, qos: 0, dup: 0, retain: 0)
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

  def on_publish(message, state) do
    Logger.debug("onpub")
  end

  def on_subscribed_publish(message: %Publish{} = message, state: state) do
    Logger.debug("TargetMqttClient received message on #{message.topic}")
    device_id = ~r/darter\/(.*)\/hits/ |> Regex.run(message.topic) |> Enum.at(1)

    if device_id do
      hit = Poison.decode!(message.message, as: %Impact.Messages.Hit{})
      Impact.Target.hit(hit.deviceId, hit.timestamp)
    end
  end
end