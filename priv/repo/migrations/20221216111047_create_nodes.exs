defmodule Dumbo.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :friendly_name, :string
      add :ieee_address, :string
      add :definition, :map

      timestamps()
    end

    create unique_index(:nodes, [:ieee_address])
    create unique_index(:nodes, [:friendly_name])
  end
end
