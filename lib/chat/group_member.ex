defmodule Chat.GroupMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups_members" do
    # field :group_id, :string
    field :member_id, :string

    belongs_to :group, Chat.Group,
      foreign_key: :group_name,
      type: :string,
      references: :group_name

    timestamps()
  end

  @doc false
  def changeset(group_members, attrs) do
    group_members
    |> cast(attrs, [:member_id, :group_id])
    |> validate_required([:member_id, :group_id])
  end
end
