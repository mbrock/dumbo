defmodule DumboWeb.NodeLive.Index do
  use DumboWeb, :live_view

  alias Dumbo.Mesh
  alias Dumbo.Mesh.Node

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :nodes, list_nodes())}
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
end
