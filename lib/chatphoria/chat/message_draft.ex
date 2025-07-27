defmodule Chatphoria.Chat.MessageDraft do
  use Ecto.Schema
  import Ecto.Changeset

  schema "message_drafts" do
    field :content, :string
    # "room" or "conversation"
    field :context_type, :string
    field :scheduled_for, :utc_datetime

    belongs_to :user, Chatphoria.Accounts.User
    belongs_to :room, Chatphoria.Chat.Room
    belongs_to :conversation, Chatphoria.Chat.Conversation

    timestamps()
  end

  def changeset(draft, attrs) do
    draft
    |> cast(attrs, [:content, :context_type, :scheduled_for, :user_id, :room_id, :conversation_id])
    |> validate_required([:content, :context_type, :user_id])
    |> validate_inclusion(:context_type, ["room", "conversation"])
    |> validate_context()
    |> validate_length(:content, max: 2000)
  end

  defp validate_context(changeset) do
    context_type = get_field(changeset, :context_type)
    room_id = get_field(changeset, :room_id)
    conversation_id = get_field(changeset, :conversation_id)

    case {context_type, room_id, conversation_id} do
      {"room", nil, _} ->
        add_error(changeset, :room_id, "required for room context")

      {"conversation", _, nil} ->
        add_error(changeset, :conversation_id, "required for conversation context")

      {"room", _, nil} ->
        changeset

      {"conversation", nil, _} ->
        changeset

      _ ->
        add_error(changeset, :context_type, "invalid context configuration")
    end
  end
end
