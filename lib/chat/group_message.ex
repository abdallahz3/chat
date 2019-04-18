defmodule Chat.GroupMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups_messages" do
    field :group_name, :string
    field :member_id, :string
    field :message, :string

    timestamps()
  end

  @doc false
  def changeset(group_message, attrs) do
    group_message
    |> cast(attrs, [:group_id, :member_id, :message])
    |> validate_required([:group_id, :member_id, :message])
  end
end
