defmodule Chat.Repo.Migrations.CreateGroupMessages do
  use Ecto.Migration

  def change do
    create table(:groups_messages) do
      add :group_name, :string
      add :member_id, :string
      add :message, :string

      timestamps()
    end
  end
end
