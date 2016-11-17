defmodule ImpactTest do
  use ExUnit.Case
  doctest Impact

  setup do
    Application.stop(:impact)
  end

  setup do
    pid = Impact.MqttClient.start_link({:first}, Impact.MqttClient)
    Impact.Target.start_link("1234")

    Impact.TargetMqttClient.start_link({:first}, Impact.TargetMqttClient)
    Impact.TargetMqttClient.subscribe_to_hits

    Impact.Server.start_link(Impact.Server)

    {:ok, mqtt_client: pid}
  end

  test "receiving a hit" do
    Impact.MqttClient.publish(topic: "darter/1234/hits", message: "{\"deviceId\":\"1234\", \"timestamp\":1234}", qos: 0, dup: 0, retain: 0)
    :timer.sleep(1000)
  end
end
