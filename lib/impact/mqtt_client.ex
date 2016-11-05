defmodule Impact.MqttClient do
  alias Hulaaki.Message.Publish
  alias Impact.Server
  use Hulaaki.Client

  # Define like this to override/overrule the start_link in Hulaaki.Client
  def start_link({:first}, name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: name)
    {:ok, connect(pid)}
  end

  def connect(pid) do
    opts = [
      client_id: Application.get_env(:impact, :mqtt_client_id),
      host: Application.get_env(:impact, :mqtt_host),
      port: Application.get_env(:impact, :mqtt_port)
    ]

    # Call Hulaaki.Client.connect
    connect(pid, opts)
    pid
  end

  # Public API
  def set_target_winner do
    publish(topic: "darter-rpc", message: "u r a winner!", qos: 0, dup: 0, retain: 0)
  end

  def set_target_idle do
    publish(topic: "darter-rpc", message: "go idle", qos: 0, dup: 0, retain: 0)
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
    Server.report_hit(message)
  end
end