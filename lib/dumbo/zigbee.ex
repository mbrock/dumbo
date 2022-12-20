defmodule Dumbo.Zigbee do
  require Logger

  use Tortoise.Handler

  def init(_opts) do
    {:ok, nil}
  end

  def handle_message(["zigbee2mqtt", "bridge", "logging"], _, state) do
    {:ok, state}
  end

  def handle_message(topic, msg, state) do
    payload =
      case Jason.decode(msg || "") do
        {:ok, payload} -> payload
        {:error, _} -> msg
      end

    Logger.info("#{Enum.join(topic, "/")} #{inspect(payload)}")

    Dumbo.MessageLog.put({topic, payload})

    handle(topic, payload, state)
  end

  def publish(topic, payload) do
    :ok =
      Tortoise.publish(
        Dumbo.Zigbee,
        Enum.join(["zigbee2mqtt" | topic], "/"),
        Jason.encode!(payload)
      )
  end

  def request_device_rename(name, new_name) do
    publish(
      ["bridge", "request", "device", "rename"],
      %{"from" => name, "to" => new_name}
    )
  end

  def handle(["zigbee2mqtt", "bridge", "devices"], payload, state) do
    by_friendly_name = Enum.into(payload, %{}, &{&1["friendly_name"], &1})
    Dumbo.DeviceSet.put_all(by_friendly_name)
    {:ok, state}
  end

  def handle(
        ["zigbee2mqtt", "bridge", "response", "device", "rename"],
        %{"data" => %{"from" => from, "to" => to}},
        state
      ) do
    Dumbo.DeviceSet.rename(from, to)
    {:ok, state}
  end

  def handle(["zigbee2mqtt", _device], nil, state) do
    # we get these when a device is renamed
    {:ok, state}
  end

  # handle the zigbee2mqtt/bridge/response/device/rename message
  def handle(
        ["zigbee2mqtt", "bridge", "response", "device", "rename"],
        %{"data" => %{"from" => from, "to" => to}},
        state
      ) do
    Dumbo.DeviceSet.rename(from, to)
    {:ok, state}
  end

  def handle(["zigbee2mqtt", device], payload, state) do
    Dumbo.DeviceSet.put_device_state(device, payload)

    node = Dumbo.Mesh.get_node_by_friendly_name!(device)

    latest_message = Dumbo.Mesh.get_latest_message_by_node(node)

    latest_payload =
      case latest_message do
        nil ->
          Map.new(payload, fn key -> {key, nil} end)

        %Dumbo.Mesh.Message{payload: payload} ->
          payload
      end

    Phoenix.PubSub.broadcast!(
      Dumbo.PubSub,
      "message",
      {:message, device, payload, latest_payload}
    )

    {:ok, _} =
      Dumbo.Mesh.create_message(%{
        node_id: node.id,
        payload: payload
      })

    {:ok, state}
  end

  # def handle(["zigbee2mqtt", "sensor"], %{"occupancy" => true}, state) do
  #   publish(["desk-lamp-1", "set"], %{"state" => "ON", "brightness" => 255})
  #   {:ok, state}
  # end

  # def handle(["zigbee2mqtt", "sensor"], %{"occupancy" => false}, state) do
  #   # dim desk lamp to 50%
  #   publish(["desk-lamp-1", "set"], %{"state" => "ON", "brightness" => 127})
  #   {:ok, state}
  # end

  def handle(_topic, _data, state) do
    {:ok, state}
  end

  def boolean_to_state(true), do: "ON"
  def boolean_to_state(false), do: "OFF"

  def state_to_boolean("ON"), do: true
  def state_to_boolean("OFF"), do: false

  def set_state(device, state, extra \\ %{}) do
    tell(device, Map.merge(%{"state" => boolean_to_state(state)}, extra))
  end

  def tell(device, message) do
    publish([device, "set"], message)
  end
end
