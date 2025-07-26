defmodule Chatphoria.Accounts do
  import Ecto.Query, warn: false
  alias Chatphoria.Repo
  alias Chatphoria.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def update_user_status(user, status) do
    update_user(user, %{status: status, last_seen_at: DateTime.utc_now()})
  end

  def get_online_users do
    from(u in User, where: u.status == "online")
    |> Repo.all()
  end
end