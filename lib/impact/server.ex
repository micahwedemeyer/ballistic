defmodule Impact.Server do
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def add_team(id, name, color) do
    GenServer.call(__MODULE__, {:add_team, id, name, color})
  end

  def report_hit(device_id) do
    GenServer.cast(__MODULE__, {:report_hit, device_id})
  end

  def get_teams() do
    GenServer.call(__MODULE__, {:get_teams})
  end

  ## GenServer Callbacks

  def init(:ok) do
    Logger.debug "Impact server started"
    {:ok, %{hits: 0}}
  end

  def handle_call({:add_team, id, name, color}, _from, state) do
    # Add the team to the 
    {:reply}
  end

  def handle_call({:get_teams}, _from, state) do
    # Extract the teams from the state?
    #{:reply, teams, state}
  end

  def handle_cast({:report_hit, device_id}, state) do
    # Save somewhere? The database?
    Logger.info("Hit! (#{device_id})")

    # Winner plays the win show
    Impact.Target.play_show(device_id, "win")

    # Play a lose show for everyone else
    other_targets = Impact.TargetSupervisor.target_device_ids
    |> Enum.reject(&(&1 == device_id))
    |> Enum.each(&(Impact.Target.play_show(&1, "lose")))

    # Report the result on slack
    #Impact.SlackClient.send_message("It's a hit!", "#bs-boardgames")
    {:noreply, state}
  end
end
