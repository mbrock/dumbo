defmodule Dumbo.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :payload, :map
      add :node_id, references(:nodes, on_delete: :nothing)

      timestamps()
    end

    create index(:messages, [:node_id])
  end
end
