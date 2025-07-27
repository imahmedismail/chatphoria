defmodule Chatphoria.Repo.Migrations.CreateMessageReceipts do
  use Ecto.Migration

  def change do
    create table(:message_receipts) do
      add :read_at, :naive_datetime
      add :delivered_at, :naive_datetime, null: false
      add :message_id, references(:messages, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:message_receipts, [:message_id])
    create index(:message_receipts, [:user_id])
    create unique_index(:message_receipts, [:message_id, :user_id])
  end
end
