defmodule Dumbo.DeviceSet do
  use Agent

  require Logger

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def update_and_broadcast(f) do
    old = Agent.get(__MODULE__, & &1)
    Agent.update(__MODULE__, f)
    new = Agent.get(__MODULE__, & &1)

    if old != new do
      Phoenix.PubSub.broadcast!(Dumbo.PubSub, "devices", {:devices, get()})

      Phoenix.PubSub.broadcast!(
        Dumbo.PubSub,
        "device-change",
        {:device_change, old, new}
      )

      {old_facts, new_facts} = {get_facts(old), get_facts(new)}

      Phoenix.PubSub.broadcast!(
        Dumbo.PubSub,
        "facts",
        {:facts, old_facts, new_facts}
      )

      changes = fact_changes(old_facts, new_facts)

      if changes != %{} do
        Logger.info("Fact changes: #{inspect(changes)}")

        Phoenix.PubSub.broadcast!(
          Dumbo.PubSub,
          "fact-changes",
          {:fact_changes, changes}
        )
      end
    end
  end

  def fact_changes(old, new) do
    for {key, v1} <- new,
        v1 != Map.get(old, key) do
      v0 = Map.get(old, key)
      {key, {v0, v1}}
    end
    |> Map.new()
  end

  def get_simple do
    Agent.get(__MODULE__, &Map.to_list(&1))
    |> Enum.map(fn {key, device} ->
      {
        key,
        %{
          description: device["definition"]["description"]
        }
      }
    end)
  end

  def drop_uninteresting(devices) do
    Map.reject(devices, fn {_key, device} ->
      device["type"] == "Coordinator"
    end)
  end

  def merge(devices) do
    update_and_broadcast(&drop_uninteresting(Map.merge(&1, devices)))
  end

  def put_device_state(friendly_name, state) do
    update_and_broadcast(fn devices ->
      Map.update(devices, friendly_name, state, fn device ->
        Map.merge(device, %{"state" => state})
      end)
    end)
  end

  def put_all(devices) do
    merge(devices)
    save_all(devices)
  end

  def save_all(devices) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    entries =
      devices
      |> drop_uninteresting()
      |> Enum.map(fn {friendly_name, device} ->
        %{
          friendly_name: friendly_name,
          ieee_address: device["ieee_address"],
          definition: device["definition"],
          inserted_at: now,
          updated_at: now
        }
      end)

    {count, _} =
      Dumbo.Repo.insert_all(
        Dumbo.Mesh.Node,
        entries,
        on_conflict: {:replace_all_except, [:id, :inserted_at]},
        conflict_target: [:ieee_address]
      )

    Logger.info("Saved #{count} devices")
  end

  def put(device) do
    merge(%{device["friendly_name"] => device})
  end

  def delete(friendly_name) do
    update_and_broadcast(&Map.delete(&1, friendly_name))
  end

  def get_by_friendly_name(friendly_name) do
    Agent.get(__MODULE__, &Map.get(&1, friendly_name))
  end

  def get_datatable do
    data =
      get_simple()
      |> Enum.map(fn {friendly_name, device} ->
        %{
          name: friendly_name,
          description: device.description
        }
      end)

    Kino.DataTable.new(data, name: "Devices", keys: [:name, :description])
  end

  def get_tree do
    Kino.Tree.new(get())
  end

  def get_facts(state) do
    for {device, %{"state" => s}} <- state,
        {key, value} <- s,
        key != "linkquality",
        not is_map(value) do
      {{device, key}, value}
    end
    |> Map.new()
  end

  def get_facts() do
    get() |> get_facts()
  end

  def rename(friendly_name, new_friendly_name) do
    update_and_broadcast(
      &Map.put(
        Map.delete(&1, friendly_name),
        new_friendly_name,
        Map.get(&1, friendly_name)
      )
    )
  end
end
