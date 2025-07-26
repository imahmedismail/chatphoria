defmodule Chatphoria.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :message_type, :string, default: "text"

    belongs_to :user, Chatphoria.Accounts.User
    belongs_to :room, Chatphoria.Chat.Room

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :message_type, :user_id, :room_id])
    |> validate_required([:content, :user_id, :room_id])
    |> validate_length(:content, min: 1, max: 2000)
    |> validate_inclusion(:message_type, ["text", "image", "file"])
  end
end