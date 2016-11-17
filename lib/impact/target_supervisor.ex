defmodule Impact.TargetSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init_target(device_id) do
    Supervisor.start_child(__MODULE__, [device_id])
  end

  def init(:ok) do
    children = [
      worker(Impact.Target, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end