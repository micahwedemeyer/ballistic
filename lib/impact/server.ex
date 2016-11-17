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

  def report_introduction(%Impact.Messages.Introduction{} = intro) do
    GenServer.cast(__MODULE__, {:report_introduction, intro})
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
    Logger.debug("Server receives hit report for #{device_id}")

    Impact.Target.play_show(device_id, "win")

    # TODO: For all other devices, play a loss show
    #Impact.SlackClient.send_message("It's a hit!", "#bs-boardgames")
    {:noreply, state}
  end

  def handle_cast({:report_introduction, intro}, state) do
    
  end
end
