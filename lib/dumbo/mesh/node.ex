defmodule Dumbo.Mesh.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :definition, :map
    field :friendly_name, :string
    field :ieee_address, :string

    timestamps()
  end

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:friendly_name, :ieee_address, :definition])
    |> validate_required([:friendly_name, :ieee_address, :definition])
    |> unique_constraint(:friendly_name)
    |> unique_constraint(:ieee_address)
  end
end
