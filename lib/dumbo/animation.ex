# Perform an integer-valued fade animation from one value to another,
# over a given duration, using Erlang timers.
defmodule Dumbo.Animation do
  require Logger

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init({:fade, from, to, duration}) do
    steps = abs(to - from)

    if steps == 0 do
      {:stop, :normal, :done}
    else
      step_duration = round(max(0.1, duration / steps) * 1000)
      t0 = System.system_time(:millisecond)
      t1 = t0 + duration * 1000

      Logger.info("Starting fade from #{from} to #{to} in #{duration} seconds.")

      Process.send_after(self(), :tick, step_duration)

      {:ok, {:fading, from, to, t0, t1, step_duration}}
    end
  end

  def fade(value) do
    Dumbo.Zigbee.set_state("living-room-ceiling", true, %{brightness: value})
  end

  def handle_info(:tick, {:fading, from, to, t0, t1, step_duration}) do
    t = System.system_time(:millisecond)

    if t >= t1 do
      Logger.info("Fading to #{to}; done.")
      fade(to)
      {:stop, :normal, :done}
    else
      # Linear interpolation.
      value = round(from + (to - from) * (t - t0) / (t1 - t0))

      Logger.info("Fading to #{value}.")
      fade(value)

      Process.send_after(self(), :tick, step_duration)

      {:noreply, {:fading, from, to, t0, t1, step_duration}}
    end
  end
end
