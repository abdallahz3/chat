defmodule Chat.Repo.Migrations.CreateGroupMember do
  use Ecto.Migration

  def change do
    create table(:groups_members) do
      add :member_id, :string
      add :group_name, references("groups", column: :group_name, type: :string)

      timestamps()
    end
  end
end
