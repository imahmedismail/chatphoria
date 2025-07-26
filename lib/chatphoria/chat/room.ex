defmodule Chatphoria.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :description, :string
    field :is_private, :boolean, default: false

    belongs_to :created_by, Chatphoria.Accounts.User
    has_many :messages, Chatphoria.Chat.Message
    has_many :room_memberships, Chatphoria.Chat.RoomMembership
    has_many :users, through: [:room_memberships, :user]

    timestamps()
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :is_private, :created_by_id])
    |> validate_required([:name, :created_by_id])
    |> validate_length(:name, min: 2, max: 50)
    |> validate_length(:description, max: 500)
    |> unique_constraint(:name)
  end
end
