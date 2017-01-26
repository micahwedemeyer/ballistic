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
    {:ok, %{status: :idle}}
  end

  def handle_cast({:report_hit, device_id}, state) do
    # Save somewhere? The database?
    Logger.info("Hit! (#{device_id})")

    channel = Application.get_env(:slack, :ballista_channel)

    target = Ballistic.Target.whereis(device_id)

    case state[:status] do
      :live ->
        winner = target
        losers = Ballistic.TargetSupervisor.target_pids |> Enum.reject(&(&1 == winner))

        # Winner plays the win show
        Ballistic.Target.play_show(winner, "win")
        Ballistic.Target.increment_score(winner)

        # Losers play the lose show
        Enum.each(losers, &(Ballistic.Target.play_show(&1, "lose")))

        team = Ballistic.Target.get_team(target)

        message = "<!here> :fireworks: Winner! #{team.name}\n#{team.slack_win_link}"

        # Report the result on slack
        Ballistic.SlackClient.send_message(message, "##{channel}")
      _ ->
        # Shooting a dead target, eh?
        Ballistic.Target.play_show(target, "lose")
    end

    new_state = state |> Map.put(:status, :idle)
    {:noreply, new_state}
  end

  def handle_cast({:go_live}, state) do
    Logger.info("Going live!")

    Ballistic.TargetSupervisor.target_pids
    |> Enum.each(&(Ballistic.Target.go_live(&1)))

    channel = Application.get_env(:slack, :ballista_channel)

    Ballistic.SlackClient.send_message("<!here> :gun: Targets Live! :gun:", "##{channel}")

    new_state = state |> Map.put(:status, :live)
    {:noreply, new_state}
  end
end
