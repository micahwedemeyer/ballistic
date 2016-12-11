defmodule BallisticTest do
  use ExUnit.Case
  doctest Ballistic

  setup_all do
    Application.stop(:ballistic)
  end

  setup do
    pid = Ballistic.MqttClient.start_link({:first}, Ballistic.MqttClient)

    Ballistic.TargetSupervisor.start_link()
    Ballistic.TargetSupervisor.init_target("1234")
    Ballistic.TargetSupervisor.init_target("abcd")
    Ballistic.TargetSupervisor.init_target("xyz")

    Ballistic.TargetMqttClient.start_link({:first}, Ballistic.TargetMqttClient)
    Ballistic.TargetMqttClient.subscribe_to_hits
    Ballistic.TargetMqttClient.subscribe_to_introductions

    Ballistic.Server.start_link(Ballistic.Server)

    {:ok, mqtt_client: pid}
  end

  test "receiving a hit" do
    Ballistic.MqttClient.publish(topic: "darter/1234/hits", message: "{\"deviceId\":\"1234\", \"timestamp\":1234}", qos: 0, dup: 0, retain: 0)
    :timer.sleep(100)
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
