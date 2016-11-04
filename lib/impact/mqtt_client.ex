defmodule Impact.MqttClient do
  use Hulaaki.Client
  alias Hulaaki.Message.Publish

  alias Impact.Server

  # TODO - Remove this, as this is something for a Supervisor to handle
  def start_and_connect do
    start_link
    connect([client_id: "srv-1234", host: "localhost", port: 1883])
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def connect(opts) do
    {:ok, conn_pid} = GenServer.whereis(__MODULE__)
    |> Hulaaki.Connection.start_link
    GenServer.call(__MODULE__, {:connect, opts, conn_pid})
  end

  # Public API
  def set_target_winner do
    publish(topic: "darter-rpc", message: "u r a winner!", qos: 0, dup: 0, retain: 0)
  end

  def set_target_idle do
    publish(topic: "darter-rpc", message: "go idle", qos: 0, dup: 0, retain: 0)
  end

  def subscribe_to_hits do
    subscribe(id: 1, topics: ["hits"], qoses: [1])
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