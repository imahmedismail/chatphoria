defmodule Chatphoria.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :message_type, :string, default: "text"

    belongs_to :user, Chatphoria.Accounts.User
    belongs_to :room, Chatphoria.Chat.Room
    belongs_to :conversation, Chatphoria.Chat.Conversation

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :message_type, :user_id, :room_id, :conversation_id])
    |> validate_required([:content, :user_id])
    |> validate_room_or_conversation()
    |> validate_length(:content, min: 1, max: 2000)
    |> validate_inclusion(:message_type, ["text", "image", "file"])
  end

  defp validate_room_or_conversation(changeset) do
    room_id = get_field(changeset, :room_id)
    conversation_id = get_field(changeset, :conversation_id)

    cond do
      room_id && conversation_id ->
        add_error(changeset, :base, "message cannot belong to both room and conversation")

      !room_id && !conversation_id ->
        add_error(changeset, :base, "message must belong to either a room or conversation")

      true ->
        changeset
    end
  end
end
