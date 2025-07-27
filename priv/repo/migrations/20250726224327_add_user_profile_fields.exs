defmodule Chatphoria.Repo.Migrations.AddUserProfileFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :status_message, :string
      add :custom_status_emoji, :string
      add :bio, :text
      add :theme_preference, :string, default: "light", null: false
    end
  end
end
