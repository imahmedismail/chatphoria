defmodule Chatphoria.Repo.Migrations.CreateMessageDrafts do
  use Ecto.Migration

  def change do
    create table(:message_drafts) do
      add :content, :text, null: false
      add :context_type, :string, null: false
      add :scheduled_for, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :room_id, references(:rooms, on_delete: :delete_all)
      add :conversation_id, references(:conversations, on_delete: :delete_all)

      timestamps()
    end

    create index(:message_drafts, [:user_id])
    create index(:message_drafts, [:room_id])
    create index(:message_drafts, [:conversation_id])
    create index(:message_drafts, [:user_id, :room_id])
    create index(:message_drafts, [:user_id, :conversation_id])
  end
end
