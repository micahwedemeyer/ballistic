defmodule Impact.TargetSupervisor do
  use Supervisor
  require Logger

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init_target(device_id) do
    if !Enum.member?(target_device_ids, device_id) do
      Supervisor.start_child(__MODULE__, [device_id])
    else
      target_pids
      |> Enum.find(&(Target.get_device_id(&1) == device_id))
    end
  end

  def target_pids do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn({_, pid, _, _}) -> pid end)
  end

  def target_device_ids do
    target_pids
    |> Enum.map(&(Impact.Target.get_device_id(&1)))
  end

  def init(:ok) do
    children = [
      worker(Impact.Target, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end