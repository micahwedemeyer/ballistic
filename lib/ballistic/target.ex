defmodule Ballistic.Target do
  use GenServer
  require Logger

  @enforce_keys [:device_id]
  defstruct [:device_id, :name, :color]

  def start_link(device_id) do
    args = %__MODULE__{device_id: device_id}
    GenServer.start_link(__MODULE__, args, name: via_tuple(device_id))
  end

  def whereis(device_id) do
    GenServer.whereis(via_tuple(device_id))
  end

  def get_team(pid), do: GenServer.call(pid, {:get_team})
  def get_device_id(pid), do: GenServer.call(pid, :get_device_id)
  def hit(pid, timestamp), do: GenServer.cast(pid, {:hit, timestamp})
  def play_show(pid, show_id), do: GenServer.cast(pid, {:play_show, show_id})
  def go_live(pid), do: play_show(pid, "live")
  def increment_score(pid), do: GenServer.cast(pid, {:increment_score})

  # Private?
  defp via_tuple(device_id) do
    {:via, :gproc, {:n, :l, {:device_id, device_id}}}
  end

  # GenServer Callbacks
  def init(%__MODULE__{} = target) do
    Logger.debug "Target #{target.device_id} started"

    color = {0, 0, 0}
    target = target
    |> Map.put(:color, color)

    {:ok, target}
  end

  def handle_call({:get_team}, _from, state) do
    {:reply, target_model(state).team, state}
  end

  def handle_call(:get_device_id, _from, state) do
    {:reply, state.device_id, state}
  end

  def handle_cast({:hit, _timestamp}, state) do
    Logger.debug "Target #{state.device_id} hit!"
    Ballistic.Server.report_hit(state.device_id)
    {:noreply, state}
  end

  def handle_cast({:play_show, show_id}, state) do
    Logger.debug("Target #{state.device_id} plays show #{show_id}")
    Ballistic.TargetMqttClient.play_show(state.device_id, show_id)
    {:noreply, state}
  end

  def handle_cast({:increment_score}, state) do
    t = target_model(state)

    t.team
    |> Ballistic.Models.Team.changeset(%{score: t.team.score + 1})
    |> Ballistic.Repo.update!
    {:noreply, state}
  end

  defp target_model(state) do
    Ballistic.Repo.get_by(Ballistic.Models.Target, [device_id: state.device_id])
    |> Ballistic.Repo.preload(:team)
  end

  defp changeset(target, params) do
    Ballistic.Models.Target.changeset(target, params)
  end
end