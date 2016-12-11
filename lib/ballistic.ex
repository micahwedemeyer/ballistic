defmodule Ballistic do
  use Application

  def start(_type, _args) do
    Ballistic.Supervisor.start_link
  end

  def setup do
    # Where does this go?
    Ballistic.TargetMqttClient.subscribe_to_hits
    Ballistic.TargetMqttClient.subscribe_to_introductions
    Ballistic.TargetMqttClient.request_introductions
  end
end
