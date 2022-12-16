defmodule DumboWeb.MessageLive.Index do
  use DumboWeb, :live_view

  alias Dumbo.Mesh

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :messages, list_messages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Messages")
    |> assign(:message, nil)
  end

  defp list_messages do
    Mesh.list_messages()
  end
end
