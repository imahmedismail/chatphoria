defmodule ChatphoriaWeb.UserSessionController do
  use ChatphoriaWeb, :controller

  alias Chatphoria.Accounts

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"username" => username, "email" => email} = user_params

    case Accounts.get_user_by_username(username) do
      nil ->
        case Accounts.create_user(%{username: username, email: email}) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "Welcome #{user.username}!")
            |> put_session(:user_id, user.id)
            |> redirect(to: ~p"/chat")

          {:error, %Ecto.Changeset{}} ->
            render(conn, :new, error_message: "Invalid username or email")
        end

      user ->
        conn
        |> put_flash(:info, "Welcome back #{user.username}!")
        |> put_session(:user_id, user.id)
        |> redirect(to: ~p"/chat")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> clear_session()
    |> redirect(to: ~p"/")
  end
end