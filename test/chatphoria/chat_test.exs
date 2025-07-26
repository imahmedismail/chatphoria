defmodule Chatphoria.ChatTest do
  use Chatphoria.DataCase

  alias Chatphoria.Chat

  describe "rooms" do
    alias Chatphoria.Chat.Room

    import Chatphoria.AccountsFixtures
    import Chatphoria.ChatFixtures

    @invalid_attrs %{name: nil, created_by_id: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      rooms = Chat.list_rooms()
      assert length(rooms) == 1
      assert List.first(rooms).name == room.name
    end

    test "list_public_rooms/0 returns only public rooms" do
      public_room = room_fixture()
      _private_room = room_fixture(%{name: "private", is_private: true})

      public_rooms = Chat.list_public_rooms()
      assert length(public_rooms) == 1
      assert List.first(public_rooms).name == public_room.name
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      fetched_room = Chat.get_room!(room.id)
      assert fetched_room.id == room.id
    end

    test "create_room/1 with valid data creates a room" do
      user = user_fixture()
      valid_attrs = %{name: "test room", description: "test description", created_by_id: user.id}

      assert {:ok, %Room{} = room} = Chat.create_room(valid_attrs)
      assert room.name == "test room"
      assert room.description == "test description"
      assert room.created_by_id == user.id
      assert room.is_private == false
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_room(@invalid_attrs)
    end

    test "create_room/1 with duplicate name returns error changeset" do
      room = room_fixture()
      user = user_fixture(%{username: "user2", email: "user2@example.com"})
      attrs = %{name: room.name, created_by_id: user.id}
      assert {:error, %Ecto.Changeset{}} = Chat.create_room(attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{name: "updated room", description: "updated description"}

      assert {:ok, %Room{} = room} = Chat.update_room(room, update_attrs)
      assert room.name == "updated room"
      assert room.description == "updated description"
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Chat.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_room!(room.id) end
    end
  end

  describe "messages" do
    alias Chatphoria.Chat.Message

    import Chatphoria.AccountsFixtures
    import Chatphoria.ChatFixtures

    @invalid_attrs %{content: nil, user_id: nil, room_id: nil}

    test "list_messages_for_room/1 returns messages for given room" do
      user = user_fixture()
      room = room_fixture()
      message = message_fixture(%{user_id: user.id, room_id: room.id})

      messages = Chat.list_messages_for_room(room.id)
      assert length(messages) == 1
      assert List.first(messages).id == message.id
    end

    test "list_messages_for_room/2 respects limit parameter" do
      user = user_fixture()
      room = room_fixture()
      
      # Create 5 messages
      Enum.each(1..5, fn i ->
        message_fixture(%{content: "Message #{i}", user_id: user.id, room_id: room.id})
      end)

      messages = Chat.list_messages_for_room(room.id, 3)
      assert length(messages) == 3
    end

    test "create_message/1 with valid data creates a message" do
      user = user_fixture()
      room = room_fixture()
      valid_attrs = %{content: "Hello world", user_id: user.id, room_id: room.id}

      assert {:ok, %Message{} = message} = Chat.create_message(valid_attrs)
      assert message.content == "Hello world"
      assert message.user_id == user.id
      assert message.room_id == room.id
      assert message.message_type == "text"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(@invalid_attrs)
    end

    test "create_message/1 with empty content returns error changeset" do
      user = user_fixture()
      room = room_fixture()
      attrs = %{content: "", user_id: user.id, room_id: room.id}
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(attrs)
    end
  end

  describe "room memberships" do
    alias Chatphoria.Chat.RoomMembership

    import Chatphoria.AccountsFixtures
    import Chatphoria.ChatFixtures

    test "join_room/2 creates a membership with default role" do
      user = user_fixture()
      room = room_fixture()

      assert {:ok, %RoomMembership{} = membership} = Chat.join_room(user.id, room.id)
      assert membership.user_id == user.id
      assert membership.room_id == room.id
      assert membership.role == "member"
    end

    test "join_room/3 creates a membership with specified role" do
      user = user_fixture()
      room = room_fixture()

      assert {:ok, %RoomMembership{} = membership} = Chat.join_room(user.id, room.id, "admin")
      assert membership.role == "admin"
    end

    test "join_room/2 prevents duplicate memberships" do
      user = user_fixture()
      room = room_fixture()

      assert {:ok, _membership} = Chat.join_room(user.id, room.id)
      assert {:error, %Ecto.Changeset{}} = Chat.join_room(user.id, room.id)
    end

    test "leave_room/2 removes membership" do
      user = user_fixture()
      room = room_fixture()
      {:ok, _membership} = Chat.join_room(user.id, room.id)

      assert {:ok, %RoomMembership{}} = Chat.leave_room(user.id, room.id)
      assert Chat.get_room_membership(user.id, room.id) == nil
    end

    test "leave_room/2 returns error if not a member" do
      user = user_fixture()
      room = room_fixture()

      assert {:error, :not_member} = Chat.leave_room(user.id, room.id)
    end

    test "is_member?/2 returns true for members" do
      user = user_fixture()
      room = room_fixture()
      {:ok, _membership} = Chat.join_room(user.id, room.id)

      assert Chat.is_member?(user.id, room.id) == true
    end

    test "is_member?/2 returns false for non-members" do
      user = user_fixture()
      room = room_fixture()

      assert Chat.is_member?(user.id, room.id) == false
    end

    test "get_user_rooms/1 returns rooms user is member of" do
      user = user_fixture()
      room1 = room_fixture(%{name: "room1"})
      room2 = room_fixture(%{name: "room2"})
      _room3 = room_fixture(%{name: "room3"})

      {:ok, _} = Chat.join_room(user.id, room1.id)
      {:ok, _} = Chat.join_room(user.id, room2.id)

      user_rooms = Chat.get_user_rooms(user.id)
      assert length(user_rooms) == 2
      room_names = Enum.map(user_rooms, & &1.name)
      assert "room1" in room_names
      assert "room2" in room_names
      assert "room3" not in room_names
    end
  end
end