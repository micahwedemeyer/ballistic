defmodule Ballistic.Models.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ballistic.Models.{Target}

  schema "teams" do
    field :name
    field :score, :integer, default: 0
    field :slack_win_link
    has_one :target, Target
  end

  def changeset(team, params \\ %{}) do
    team
    |> cast(params, [:name, :score, :slack_win_link])
  end
end