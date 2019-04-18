defmodule Chat.CustomerMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers_messages" do
    field :group_name, :string
    field :company_id, :string
    field :message, :string
    field :sent_by, :string

    timestamps()
  end

  @doc false
  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [:chat_id, :company_id, :sent_by, :message])
    |> validate_required([:chat_id, :company_id, :sent_by, :message])
  end
end
