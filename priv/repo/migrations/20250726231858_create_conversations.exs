defmodule Chatphoria.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :user1_id, references(:users, on_delete: :delete_all), null: false
      add :user2_id, references(:users, on_delete: :delete_all), null: false
      add :last_message_at, :utc_datetime

      timestamps()
    end

    create unique_index(:conversations, [:user1_id, :user2_id])
    create index(:conversations, [:user1_id])
    create index(:conversations, [:user2_id])
    create index(:conversations, [:last_message_at])

    # Ensure user1_id < user2_id to avoid duplicate conversations
    create constraint(:conversations, :user_order, check: "user1_id < user2_id")
  end
end
