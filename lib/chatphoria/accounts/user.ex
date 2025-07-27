defmodule Chatphoria.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :avatar_url, :string
    field :status, :string, default: "offline"
    field :status_message, :string
    field :custom_status_emoji, :string
    field :bio, :string
    field :theme_preference, :string, default: "light"
    field :last_seen_at, :utc_datetime

    has_many :messages, Chatphoria.Chat.Message
    has_many :created_rooms, Chatphoria.Chat.Room, foreign_key: :created_by_id
    has_many :room_memberships, Chatphoria.Chat.RoomMembership
    has_many :rooms, through: [:room_memberships, :room]
    has_many :conversations_as_user1, Chatphoria.Chat.Conversation, foreign_key: :user1_id
    has_many :conversations_as_user2, Chatphoria.Chat.Conversation, foreign_key: :user2_id

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :email,
      :avatar_url,
      :status,
      :status_message,
      :custom_status_emoji,
      :bio,
      :theme_preference,
      :last_seen_at
    ])
    |> validate_required([:username, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:username, min: 2, max: 20)
    |> validate_length(:status_message,
      max: 100,
      message: "status message cannot exceed 100 characters"
    )
    |> validate_length(:bio, max: 500, message: "bio cannot exceed 500 characters")
    |> validate_inclusion(:theme_preference, ["light", "dark", "system"],
      message: "theme must be light, dark, or system"
    )
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required([:username, :email])
  end
end
