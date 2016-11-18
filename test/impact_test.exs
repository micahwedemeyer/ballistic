defmodule ImpactTest do
  use ExUnit.Case
  doctest Impact

  setup_all do
    Application.stop(:impact)
  end

  setup do
    pid = Impact.MqttClient.start_link({:first}, Impact.MqttClient)

    Impact.TargetSupervisor.start_link()
    Impact.TargetSupervisor.init_target("1234")
    Impact.TargetSupervisor.init_target("abcd")
    Impact.TargetSupervisor.init_target("xyz")

    Impact.TargetMqttClient.start_link({:first}, Impact.TargetMqttClient)
    Impact.TargetMqttClient.subscribe_to_hits
    Impact.TargetMqttClient.subscribe_to_introductions

    Impact.Server.start_link(Impact.Server)

    {:ok, mqtt_client: pid}
  end

  test "receiving a hit" do
    Impact.MqttClient.publish(topic: "darter/1234/hits", message: "{\"deviceId\":\"1234\", \"timestamp\":1234}", qos: 0, dup: 0, retain: 0)
    :timer.sleep(100)
  end

  test "receiving an intro" do
    assert (Impact.TargetSupervisor.target_device_ids() |> Enum.sort) == ["1234", "abcd", "xyz"]

    Impact.MqttClient.publish(topic: "darter/newtarget/introduction", message: "{\"deviceId\":\"newtarget\"}", qos: 0, dup: 0, retain: 0)
    :timer.sleep(100)

    assert (Impact.TargetSupervisor.target_device_ids() |> Enum.sort) == ["1234", "abcd", "newtarget", "xyz"]
  end

  test "going live" do
    Impact.Server.go_live()
    :timer.sleep(100)
  end
end
