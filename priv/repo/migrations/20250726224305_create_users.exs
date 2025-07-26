defmodule Chatphoria.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :avatar_url, :string
      add :status, :string, default: "offline"
      add :last_seen_at, :utc_datetime

      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end
end
