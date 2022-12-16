defmodule DumboWeb.NodeLive.FormComponent do
  use DumboWeb, :live_component

  alias Dumbo.Mesh

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage node records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="node-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :friendly_name}} type="text" label="friendly_name" />
        <.input field={{f, :ieee_address}} type="text" label="ieee_address" />
        <.input field={{f, :definition}} type="text" label="definition" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Node</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{node: node} = assigns, socket) do
    changeset = Mesh.change_node(node)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"node" => node_params}, socket) do
    changeset =
      socket.assigns.node
      |> Mesh.change_node(node_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"node" => node_params}, socket) do
    save_node(socket, socket.assigns.action, node_params)
  end

  defp save_node(socket, :edit, node_params) do
    case Mesh.update_node(socket.assigns.node, node_params) do
      {:ok, _node} ->
        {:noreply,
         socket
         |> put_flash(:info, "Node updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_node(socket, :new, node_params) do
    case Mesh.create_node(node_params) do
      {:ok, _node} ->
        {:noreply,
         socket
         |> put_flash(:info, "Node created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
