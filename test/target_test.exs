defmodule Ballistic.TargetTest do
  use ExUnit.Case
  import Ballistic.Factory

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ballistic.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Ballistic.Repo, {:shared, self()})

    insert(:target, [device_id: "1234"])
    {:ok, target} = Ballistic.TargetSupervisor.init_target("1234")

    {:ok, target: target}
  end

  test "receiving a live hit", %{target: target} do
    target_model = Ballistic.Repo.get_by(Ballistic.Models.Target, [device_id: "1234"]) |> Ballistic.Repo.preload(:team)
    assert 0 = target_model.team.score

    Ballistic.Server.go_live()
    :timer.sleep(100)

    Ballistic.Target.hit(target, "timestamp")
    :timer.sleep(100)

    target_model = Ballistic.Repo.get_by(Ballistic.Models.Target, [device_id: "1234"]) |> Ballistic.Repo.preload(:team)

    assert 1 = target_model.team.score
  end
end
