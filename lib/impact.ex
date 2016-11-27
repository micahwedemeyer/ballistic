defmodule Impact do
  use Application

  def start(_type, _args) do
    Impact.Supervisor.start_link
  end

  def setup do
    # Where does this go?
    Impact.TargetMqttClient.subscribe_to_hits
    Impact.TargetMqttClient.subscribe_to_introductions
    Impact.TargetMqttClient.request_introductions
  end
end
