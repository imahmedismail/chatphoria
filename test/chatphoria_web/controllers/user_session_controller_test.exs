defmodule ChatphoriaWeb.UserSessionControllerTest do
  use ChatphoriaWeb.ConnCase

  import Plug.Conn
  import Chatphoria.AccountsFixtures

  describe "GET /" do
    test "displays the login form", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ "Welcome to Chatphoria"
      assert response =~ "Username"
      assert response =~ "Email"
    end
  end

  describe "POST /login" do
    test "creates new user and logs them in", %{conn: conn} do
      user_params = %{
        "user" => %{
          "username" => "newuser",
          "email" => "newuser@example.com"
        }
      }

      conn = post(conn, ~p"/login", user_params)

      assert redirected_to(conn) == ~p"/chat"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome newuser!"
      assert get_session(conn, :user_id)
    end

    test "logs in existing user", %{conn: conn} do
      user = user_fixture(%{username: "existinguser", email: "existing@example.com"})

      user_params = %{
        "user" => %{
          "username" => user.username,
          "email" => "different@example.com"
        }
      }

      conn = post(conn, ~p"/login", user_params)

      assert redirected_to(conn) == ~p"/chat"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back #{user.username}!"
      assert get_session(conn, :user_id) == user.id
    end

    test "shows error for invalid user data", %{conn: conn} do
      user_params = %{
        "user" => %{
          "username" => "",
          "email" => "invalid-email"
        }
      }

      conn = post(conn, ~p"/login", user_params)

      response = html_response(conn, 200)
      assert response =~ "Invalid username or email"
    end
  end

  describe "GET /logout" do
    test "logs user out and redirects to home", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> init_test_session(%{})
        |> put_session(:user_id, user.id)
        |> get(~p"/logout")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
      assert get_session(conn, :user_id) == nil
    end
  end
end
