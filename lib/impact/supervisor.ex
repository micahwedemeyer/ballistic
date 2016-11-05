defmodule Impact.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Impact.Server, [Impact.Server]),
      worker(Impact.MqttClient, [{:first}, Impact.MqttClient]),
      worker(Impact.SlackClient, [Impact.SlackClient])
    ]

    supervise(children, strategy: :one_for_one)
  end
end