defmodule Impact.Server do
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def add_team(id, name, color) do
    GenServer.call(__MODULE__, {:add_team, id, name, color})
  end

  def report_hit(%Impact.Messages.Hit{} = hit) do
    GenServer.cast(__MODULE__, {:report_hit, hit})
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

  def handle_cast({:report_hit, hit}, state) do
    # Save somewhere? The database?
    new_state = state |> Map.update!(:hits, &(&1 + 1))
    IO.puts "#{new_state[:hits]} hits reported"

    # Notify the winner
    Impact.MqttClient.play_show(hit.deviceId, "win")

    # TODO: For all other devices, play a loss show

    Impact.SlackClient.send_message("It's a hit!", "#bs-boardgames")
    {:noreply, new_state}
  end

  def handle_cast({:report_introduction, intro}, state) do
    
  end
end
