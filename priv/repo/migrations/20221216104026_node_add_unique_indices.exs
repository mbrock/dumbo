defmodule Dumbo.Repo.Migrations.NodeAddUniqueIndices do
  use Ecto.Migration

  def change do
    create unique_index(:nodes, :friendly_name)
    create unique_index(:nodes, :ieee_address)
  end
end
