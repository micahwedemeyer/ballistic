defmodule Ballistic.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      supervisor(Ballistic.Repo, []),
      worker(Ballistic.Server, [Ballistic.Server]),
      worker(Ballistic.MqttClient, [{:first}, Ballistic.MqttClient]),
      worker(Ballistic.TargetSupervisor, []),
      worker(Ballistic.TargetMqttClient, [{:first}, Ballistic.TargetMqttClient]),
    ]

    children = if Mix.env == :test do
      children
    else
      children ++ [
        worker(Ballistic.SlackClient, [Ballistic.SlackClient])
      ]
    end

    supervise(children, strategy: :one_for_one)
  end
end