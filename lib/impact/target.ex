defmodule Impact.Target do
  use GenServer
  require Logger

  @enforce_keys [:device_id]
  defstruct [:device_id, :color, :hit_count]

  def start_link(device_id) do
    args = %__MODULE__{device_id: device_id}
    GenServer.start_link(__MODULE__, args, name: via_tuple(device_id))
  end

  def whereis(device_id) do
    GenServer.whereis(via_tuple(device_id))
  end

  def get_device_id(pid) do
    GenServer.call(pid, :get_device_id)
  end

  def hit(device_id, timestamp) do
    whereis(device_id)
    |> GenServer.cast({:hit, timestamp})
  end

  def play_show(device_id, show_id) do
    whereis(device_id)
    |> GenServer.cast({:play_show, show_id})
  end

  def go_live(device_id) do
    play_show(device_id, "live")
  end

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
    |> Map.put(:hit_count, 0)

    {:ok, target}
  end

  def handle_call(:get_device_id, _from, state) do
    {:reply, state.device_id, state}
  end

  def handle_cast({:hit, _timestamp}, state) do
    new_state = state
    |> Map.update!(:hit_count, &(&1 + 1))

    Impact.Server.report_hit(state.device_id)

    Logger.debug "Target #{new_state.device_id} hit! (#{new_state.hit_count} total hits)"
    {:noreply, new_state}
  end

  def handle_cast({:play_show, show_id}, state) do
    Logger.debug("Target #{state.device_id} plays show #{show_id}")
    Impact.TargetMqttClient.play_show(state.device_id, show_id)
    {:noreply, state}
  end
end