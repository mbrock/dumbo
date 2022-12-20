# Listen to the PubSub topic "devices" and react to sensors, etc.
defmodule Dumbo.Automation do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_arg) do
    :ok = Phoenix.PubSub.subscribe(Dumbo.PubSub, "device-change")
    # Tick every 1/10 second.
    # Process.send_after(self(), :tick, 100)

    {:ok, %{}}
  end

  # def handle_info(:tick, state) do
  #   # schedule next tick
  #   Process.send_after(self(), :tick, 100)

  #   # If we have a timestamp for gradual dimming, and the bulb is on,
  #   # gradually dim it.
  #   case get_in(Dumbo.DeviceSet.get(), ["bath-left", "state", "state"]) do
  #     "ON" ->
  #       case Map.get(state, :timestamp) do
  #         nil ->
  #           {:noreply, state}

  #         timestamp ->
  #           cooldown_duration = 30
  #           elapsed_seconds = (System.system_time(:millisecond) - timestamp) / 1000.0

  #           Logger.info("Elapsed seconds: #{elapsed_seconds}")

  #           if elapsed_seconds > cooldown_duration * 1.5 do
  #             Dumbo.Zigbee.set_state("bath-left", false)
  #             Dumbo.Zigbee.set_state("bath-right", false)

  #             {:noreply, Map.delete(state, :timestamp)}
  #           else
  #             # Gradually dim the bulb.
  #             brightness = 1 + 253 * (1 - elapsed_seconds / cooldown_duration)

  #             Logger.info(
  #               "Dimming bulb to #{round(brightness)} after #{elapsed_seconds} seconds."
  #             )

  #             for bulb <- ["bath-left", "bath-right"] do
  #               Dumbo.Zigbee.set_state(
  #                 bulb,
  #                 true,
  #                 %{"brightness" => round(brightness)}
  #               )
  #             end

  #             {:noreply, state}
  #           end
  #       end

  #     _ ->
  #       {:noreply, state}
  #   end
  # end

  def handle_info({:device_change, old, new}, state) do
    s0 = Map.new(old, fn {key, value} -> {key, Map.get(value, "state", %{})} end)
    s1 = Map.new(new, fn {key, value} -> {key, Map.get(value, "state", %{})} end)

    # handle_sensor_change(s0, s1, "bath-sensor", ["bath-left", "bath-right"], 200)
    handle_sensor_change(s0, s1, "hall-sensor", ["hallway"], 50)

    {:noreply, state}
  end

  def handle_sensor_change(s0, s1, sensor, bulbs, brightness) do
    {sensor_old, sensor_new} =
      {get_in(s0, [sensor, "occupancy"]), get_in(s1, [sensor, "occupancy"])}

    if sensor_old != sensor_new do
      if sensor_new == true do
        Logger.info("#{sensor} is occupied.")

        for bulb <- bulbs do
          Dumbo.Zigbee.set_state(bulb, true, %{"brightness" => brightness})
        end
      else
        Logger.info("#{sensor} is unoccupied.")

        for bulb <- bulbs do
          Dumbo.Zigbee.set_state(bulb, false, %{"brightness" => brightness})
        end
      end
    end
  end
end
