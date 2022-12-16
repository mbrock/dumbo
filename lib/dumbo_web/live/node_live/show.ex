defmodule DumboWeb.NodeLive.Show do
  use DumboWeb, :live_view

  alias Dumbo.Mesh

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:node, Mesh.get_node!(id))}
  end

  defp page_title(:show), do: "Show Node"
end
