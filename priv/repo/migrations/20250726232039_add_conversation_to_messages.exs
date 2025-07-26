defmodule Chatphoria.Repo.Migrations.AddConversationToMessages do
  use Ecto.Migration

  def change do
    # First drop the existing foreign key constraint
    drop constraint(:messages, "messages_room_id_fkey")

    alter table(:messages) do
      add :conversation_id, references(:conversations, on_delete: :delete_all)
      modify :room_id, references(:rooms, on_delete: :delete_all), null: true
    end

    create index(:messages, [:conversation_id])

    # Messages must belong to either a room or a conversation, but not both
    create constraint(:messages, :room_or_conversation,
             check:
               "(room_id IS NOT NULL AND conversation_id IS NULL) OR (room_id IS NULL AND conversation_id IS NOT NULL)"
           )
  end
end
