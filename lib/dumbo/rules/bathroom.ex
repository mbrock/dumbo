defmodule Dumbo.Rules.Bathroom do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{name: __MODULE__})
  end

  def init(_arg) do
    :ok = Phoenix.PubSub.subscribe(Dumbo.PubSub, "fact-changes")
    {:ok, %{}}
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
end
