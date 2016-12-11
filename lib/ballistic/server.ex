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
    {:ok, %{hits: 0}}
  end

  def handle_cast({:report_hit, device_id}, state) do
    # Save somewhere? The database?
    Logger.info("Hit! (#{device_id})")

    # Winner plays the win show
    Ballistic.Target.play_show(device_id, "win")

    # Play a lose show for everyone else
    Ballistic.TargetSupervisor.target_device_ids
    |> Enum.reject(&(&1 == device_id))
    |> Enum.each(&(Ballistic.Target.play_show(&1, "lose")))

    # Report the result on slack
    channel = Application.get_env(:slack, :ballista_channel)
    Ballistic.SlackClient.send_message(":fireworks: Hit!", "##{channel}")

    {:noreply, state}
  end

  def handle_cast({:go_live}, state) do
    Logger.info("Going live!")

    Ballistic.TargetSupervisor.target_device_ids
    |> Enum.each(&(Ballistic.Target.go_live(&1)))

    channel = Application.get_env(:slack, :ballista_channel)

    Ballistic.SlackClient.send_message(":gun: Targets Live! :gun:", "##{channel}")
    {:noreply, state}
  end
end
