defmodule Chat.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :admin, :string
      add :group_name, :string

      timestamps()
    end

    create unique_index(:groups, [:group_name])
  end
end
