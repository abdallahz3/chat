defmodule Chat.Repo.Migrations.CreateGroupMember do
  use Ecto.Migration

  def change do
    create table(:groups_members) do
      add :member_id, :string
      add :group_name, references("groups")

      timestamps()
    end
  end
end
