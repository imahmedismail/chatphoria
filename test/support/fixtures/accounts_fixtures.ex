defmodule Chatphoria.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chatphoria.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        username: "testuser#{System.unique_integer([:positive])}",
        email: "test#{System.unique_integer([:positive])}@example.com",
        status: "offline"
      })
      |> Chatphoria.Accounts.create_user()

    user
  end

  @doc """
  Generate a user with online status.
  """
  def online_user_fixture(attrs \\ %{}) do
    user = user_fixture(attrs)
    {:ok, user} = Chatphoria.Accounts.update_user_status(user, "online")
    user
  end
end
