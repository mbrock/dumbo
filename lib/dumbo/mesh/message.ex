defmodule Dumbo.Mesh.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :payload, :map
    belongs_to :node, Dumbo.Mesh.Node

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:payload, :node_id])
    |> validate_required([:payload, :node_id])
  end
end
