defmodule Chat.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :admin, :string
    field :group_name, :string
    has_many :members, Chat.GroupMember

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:group_name])
    |> validate_required([:group_name])
  end
end
