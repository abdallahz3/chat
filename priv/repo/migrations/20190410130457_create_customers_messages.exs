defmodule Chat.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:customers_messages) do
      add :group_name, :string
      add :company_id, :string
      add :sent_by, :string
      add :message, :string

      timestamps()
    end
  end
end
