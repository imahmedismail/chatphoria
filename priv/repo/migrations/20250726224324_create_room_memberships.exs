defmodule Chatphoria.Repo.Migrations.CreateRoomMemberships do
  use Ecto.Migration

  def change do
    create table(:room_memberships) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :room_id, references(:rooms, on_delete: :delete_all), null: false
      add :role, :string, default: "member"
      add :joined_at, :utc_datetime, default: fragment("now()")

      timestamps()
    end

    create unique_index(:room_memberships, [:user_id, :room_id])
    create index(:room_memberships, [:user_id])
    create index(:room_memberships, [:room_id])
  end
end
