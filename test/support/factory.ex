defmodule Ballistic.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Ballistic.Repo

  def target_factory do
    %Ballistic.Models.Target{
      device_id: "1234",
      team: build(:team)
    }
  end

  def team_factory do
    %Ballistic.Models.Team{
      name: "Team SDI"
    }
  end
end