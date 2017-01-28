defmodule BallisticTest do
  use ExUnit.Case
  import Ballistic.Factory
  doctest Ballistic

  # setup_all do
  #   Application.stop(:ballistic)
  # end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ballistic.Repo)
    insert(:target, [device_id: "1234"])
    Ballistic.TargetSupervisor.init_target("1234")

    insert(:target, [device_id: "abcd"])
    Ballistic.TargetSupervisor.init_target("abcd")

    insert(:target, [device_id: "xyz"])
    Ballistic.TargetSupervisor.init_target("xyz")

    Ballistic.TargetMqttClient.subscribe_to_hits
    Ballistic.TargetMqttClient.subscribe_to_introductions


    {:ok, foo: :bar}
  end

  test "receiving a live hit" do
    Ballistic.Server.go_live()
    :timer.sleep(100)

    Ballistic.MqttClient.publish(topic: "darter/1234/hits", message: "{\"deviceId\":\"1234\", \"timestamp\":1234}", qos: 0, dup: 0, retain: 0)
    :timer.sleep(200)
  end

  test "receiving an intro" do
    assert (Ballistic.TargetSupervisor.target_device_ids() |> Enum.sort) == ["1234", "abcd", "xyz"]

    Ballistic.MqttClient.publish(topic: "darter/newtarget/introduction", message: "{\"deviceId\":\"newtarget\"}", qos: 0, dup: 0, retain: 0)
    :timer.sleep(100)

    assert (Ballistic.TargetSupervisor.target_device_ids() |> Enum.sort) == ["1234", "abcd", "newtarget", "xyz"]
  end

  test "going live" do
    Ballistic.Server.go_live()
    :timer.sleep(100)
  end
end
