defmodule Ballistic.Models.Target do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ballistic.Models.{Team}

  schema "targets" do
    field :device_id
    belongs_to :team, Team
  end

  def changeset(target, params \\ %{}) do
    target
    |> cast(params, [:device_id])
  end
end