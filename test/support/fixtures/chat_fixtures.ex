defmodule Chatphoria.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chatphoria.Chat` context.
  """

  import Chatphoria.AccountsFixtures

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, room} =
      attrs
      |> Enum.into(%{
        name: "test_room_#{System.unique_integer([:positive])}",
        description: "A test room",
        created_by_id: user.id,
        is_private: false
      })
      |> Chatphoria.Chat.create_room()

    room
  end

  @doc """
  Generate a private room.
  """
  def private_room_fixture(attrs \\ %{}) do
    room_fixture(Map.put(attrs, :is_private, true))
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    user = user_fixture()
    room = room_fixture()

    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "Test message content",
        user_id: user.id,
        room_id: room.id,
        message_type: "text"
      })
      |> Chatphoria.Chat.create_message()

    message
  end

  @doc """
  Generate a room membership.
  """
  def room_membership_fixture(attrs \\ %{}) do
    user = user_fixture()
    room = room_fixture()

    {:ok, membership} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        room_id: room.id,
        role: "member"
      })
      |> (&Chatphoria.Chat.join_room(&1.user_id, &1.room_id, &1.role)).()

    membership
  end

  @doc """
  Generate a conversation.
  """
  def conversation_fixture(attrs \\ %{}) do
    user1 = user_fixture()
    user2 = user_fixture()

    {:ok, conversation} =
      attrs
      |> Enum.into(%{
        user1_id: user1.id,
        user2_id: user2.id
      })
      |> Chatphoria.Chat.create_conversation()

    conversation
  end

  @doc """
  Generate a conversation message.
  """
  def conversation_message_fixture(attrs \\ %{}) do
    user = user_fixture()
    conversation = conversation_fixture()
    room = room_fixture()

    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "Test conversation message",
        user_id: user.id,
        conversation_id: conversation.id,
        room_id: room.id
      })
      |> Chatphoria.Chat.create_conversation_message()

    message
  end
end
