defmodule Chatphoria.Chat.RoomMembership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "room_memberships" do
    field :role, :string, default: "member"
    field :joined_at, :utc_datetime

    belongs_to :user, Chatphoria.Accounts.User
    belongs_to :room, Chatphoria.Chat.Room

    timestamps()
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :joined_at, :user_id, :room_id])
    |> validate_required([:user_id, :room_id])
    |> validate_inclusion(:role, ["member", "admin", "owner"])
    |> unique_constraint([:user_id, :room_id])
  end
end