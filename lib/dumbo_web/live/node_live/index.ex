defmodule DumboWeb.NodeLive.Index do
  use DumboWeb, :live_view

  alias Dumbo.Mesh
  alias Dumbo.Mesh.Node

  @impl true
  def mount(_params, _session, socket) do
    nodes = list_nodes()
    latest_messages = Mesh.latest_message_per_node_id()

    nodes_with_latest_messages =
      list_nodes()
      |> Enum.map(fn node ->
        Map.put(node, :latest_message, Map.get(latest_messages, node.id))
      end)
      |> Enum.filter(fn node -> node.latest_message != nil end)
      |> Enum.filter(fn node -> !String.contains?(node.friendly_name, "sensor") end)
      |> Enum.sort_by(fn node -> node.friendly_name end, :asc)

    {:ok, assign(socket, :nodes, nodes_with_latest_messages)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Nodes")
    |> assign(:node, nil)
  end

  defp list_nodes do
    Mesh.list_nodes()
  end

  def quickie_light(assigns) do
    ~H"""
    <%= Phoenix.HTML.Form.checkbox(:node, "#{@node.ieee_address}",
      value: @payload.state == "ON",
      phx_change: :change
    ) %>
    <input type="range" min="2" max="254" value={@payload.brightness} />
    <%= @node.friendly_name %>
    """
  end

  def quickie_sensor(assigns) do
    ~H"""
    <div>
      <input type="checkbox" checked={@payload.occupancy} />
      <%= @node.friendly_name %>
    </div>
    """
  end

  def quickie(assigns) do
    ~H"""
    <article class="flex gap-2">
      <.quickie_data node={@node} />
    </article>
    """
  end

  def quickie_data(assigns) do
    case assigns.node.latest_message do
      nil ->
        ~H"""
        nil
        """

      %{payload: payload_with_string_keys} ->
        payload = Map.new(payload_with_string_keys, fn {k, v} -> {String.to_atom(k), v} end)

        case payload do
          %{state: _, brightness: _} ->
            quickie_light(%{node: assigns.node, payload: payload})

          %{state: _} ->
            quickie_light(%{node: assigns.node, payload: Map.put(payload, :brightness, nil)})

          %{occupancy: _} ->
            quickie_sensor(%{node: assigns.node, payload: payload})

          _ ->
            ~H"""

            """
        end

      _ ->
        ~H"""
        unknown
        """
    end
  end
end
