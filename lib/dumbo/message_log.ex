defmodule Dumbo.MessageLog do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get_reverse_chronologically do
    Agent.get(__MODULE__, & &1)
  end

  def get_chronologically do
    Agent.get(__MODULE__, &Enum.reverse(&1))
  end

  def put(message) do
    Agent.update(__MODULE__, &[message | &1])
  end
end
