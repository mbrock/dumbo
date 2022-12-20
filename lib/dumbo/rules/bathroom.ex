defmodule Dumbo.Rules.Bathroom do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{name: __MODULE__})
  end

  def init(_arg) do
    :ok = Phoenix.PubSub.subscribe(Dumbo.PubSub, "fact-changes")
    :ok = Phoenix.PubSub.subscribe(Dumbo.PubSub, "message")

    {:ok, :normal}
  end

  def set_mode(mode) do
    GenServer.call(__MODULE__, {:set_mode, mode})
  end

  def get_mode() do
    GenServer.call(__MODULE__, :get_mode)
  end

  def handle_call({:set_mode, mode}, _from, _state) do
    {:reply, :ok, mode}
  end

  def handle_call(:get_mode, _from, state) do
    {:reply, state, state}
  end

  def handle_info(
        {:fact_changes, %{{"bath-sensor", "occupancy"} => {_, true}}},
        state
      ) do
    {:noreply, state}
  end

  def handle_info(
        {:fact_changes, %{{"bath-sensor", "occupancy"} => {_, false}}},
        state
      ) do
    {:noreply, state}
  end

  def handle_info({:fact_changes, _changes}, state) do
    {:noreply, state}
  end

  def handle_info({:message, "remote-1", %{"action" => action}, _}, state) do
    Logger.info("Remote-1 action: #{action}")
    handle_remote("remote-1", action, state)
    {:noreply, state}
  end

  def handle_info({:message, "dimmer", %{"action" => action}, _}, state) do
    Logger.info("Jazi's remote action: #{action}")
    handle_remote("dimmer", action, state)
    {:noreply, state}
  end

  def handle_info({:message, _topic, _message, _old}, state) do
    {:noreply, state}
  end

  def remote_bulbs do
    ["kitchen-globe", "living-room-ceiling", "living-room-corner", "oak-lamp"]
  end

  def remote_bulbs("remote-1") do
    ["kitchen-globe", "living-room-ceiling", "living-room-corner", "oak-lamp"]
  end

  def remote_bulbs("dimmer") do
    ["jazi-spot-bed", "jazi-spot-desk", "jazi-spot-mid"]
  end

  def handle_remote(_remote, _action, :sleep) do
    Logger.info("Sleep mode, ignoring remote action")
  end

  # handle on
  def handle_remote(remote, "on", _) do
    for bulb <- remote_bulbs(remote) do
      Dumbo.Zigbee.set_state(bulb, true)
    end
  end

  # handle off
  def handle_remote(remote, "off", _) do
    for bulb <- remote_bulbs(remote) do
      Dumbo.Zigbee.set_state(bulb, false)
    end
  end

  # handle brightness_move_up
  def handle_remote(remote, "brightness_move_up", _) do
    for bulb <- remote_bulbs(remote) do
      Dumbo.Zigbee.tell(bulb, %{"brightness_move" => 40})
    end
  end

  # handle brightness_move_down
  def handle_remote(remote, "brightness_move_down", _) do
    for bulb <- remote_bulbs(remote) do
      Dumbo.Zigbee.tell(bulb, %{"brightness_move" => -40})
    end
  end

  # handle brightness_stop
  def handle_remote(remote, "brightness_stop", _) do
    for bulb <- remote_bulbs(remote) do
      Dumbo.Zigbee.tell(bulb, %{"brightness_move" => 0})
    end
  end

  # handle other
  def handle_remote(_remote, _action, _state) do
    Logger.info("Unhandled remote action")
  end
end
