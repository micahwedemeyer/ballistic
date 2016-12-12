defmodule Ballistic.Server do
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def go_live() do
    GenServer.cast(__MODULE__, {:go_live})
  end

  def report_hit(device_id) do
    GenServer.cast(__MODULE__, {:report_hit, device_id})
  end

  ## GenServer Callbacks

  def init(:ok) do
    Logger.debug "Ballistic server started"
    {:ok, %{hits: 0, status: :idle}}
  end

  def handle_cast({:report_hit, device_id}, state) do
    # Save somewhere? The database?
    Logger.info("Hit! (#{device_id})")

    channel = Application.get_env(:slack, :ballista_channel)

    case state[:status] do
      :live ->
        # Winner plays the win show
        Ballistic.Target.play_show(device_id, "win")

        # Play a lose show for everyone else
        Ballistic.TargetSupervisor.target_device_ids
        |> Enum.reject(&(&1 == device_id))
        |> Enum.each(&(Ballistic.Target.play_show(&1, "lose")))

        # Report the result on slack
        Ballistic.SlackClient.send_message(":fireworks: Winner!", "##{channel}")
      _ ->
        # Shooting a dead target, eh?
        Ballistic.Target.play_show(device_id, "lose")
        Ballistic.SlackClient.send_message(":no_entry_sign: It's not live, idiot! :no_entry_sign:", "##{channel}")
    end

    new_state = state |> Map.put(:status, :idle)
    {:noreply, new_state}
  end

  def handle_cast({:go_live}, state) do
    Logger.info("Going live!")

    Ballistic.TargetSupervisor.target_device_ids
    |> Enum.each(&(Ballistic.Target.go_live(&1)))

    channel = Application.get_env(:slack, :ballista_channel)

    Ballistic.SlackClient.send_message(":gun: Targets Live! :gun:", "##{channel}")

    new_state = state |> Map.put(:status, :live)
    {:noreply, new_state}
  end
end
