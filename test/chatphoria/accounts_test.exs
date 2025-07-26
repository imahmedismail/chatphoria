defmodule Chatphoria.AccountsTest do
  use Chatphoria.DataCase

  alias Chatphoria.Accounts

  describe "users" do
    alias Chatphoria.Accounts.User

    import Chatphoria.AccountsFixtures

    @invalid_attrs %{username: nil, email: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_username/1 returns the user with given username" do
      user = user_fixture()
      assert Accounts.get_user_by_username(user.username) == user
    end

    test "get_user_by_username/1 returns nil for non-existent username" do
      assert Accounts.get_user_by_username("nonexistent") == nil
    end

    test "get_user_by_email/1 returns the user with given email" do
      user = user_fixture()
      assert Accounts.get_user_by_email(user.email) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{username: "testuser", email: "test@example.com"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.username == "testuser"
      assert user.email == "test@example.com"
      assert user.status == "offline"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with duplicate username returns error changeset" do
      user = user_fixture()
      attrs = %{username: user.username, email: "different@example.com"}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
    end

    test "create_user/1 with duplicate email returns error changeset" do
      user = user_fixture()
      attrs = %{username: "different", email: user.email}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{username: "updated", email: "updated@example.com"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.username == "updated"
      assert user.email == "updated@example.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user_status/2 updates user status and last_seen_at" do
      user = user_fixture()
      assert {:ok, %User{} = updated_user} = Accounts.update_user_status(user, "online")
      assert updated_user.status == "online"
      assert updated_user.last_seen_at != nil
    end

    test "get_online_users/0 returns only online users" do
      _offline_user = user_fixture()
      online_user = user_fixture(%{username: "online", email: "online@example.com"})
      Accounts.update_user_status(online_user, "online")

      online_users = Accounts.get_online_users()
      assert length(online_users) == 1
      assert List.first(online_users).status == "online"
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end