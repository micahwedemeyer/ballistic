defmodule Ballistic.Repo.Migrations.CreateTargets do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, size: 255
      add :score, :integer, default: 0
      add :slack_win_link, :string, size: 255
    end

    create table(:targets) do
      add :device_id, :string, size: 255
      add :team_id, references(:teams)
    end

    create index(:targets, [:device_id], unique: true)
  end
end
