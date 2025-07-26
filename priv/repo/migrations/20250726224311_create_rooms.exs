defmodule Chatphoria.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string, null: false
      add :description, :text
      add :is_private, :boolean, default: false
      add :created_by_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:rooms, [:created_by_id])
    create unique_index(:rooms, [:name])
  end
end
