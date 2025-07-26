# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias Chatphoria.{Repo, Accounts, Chat}
import Ecto.Query

# Create sample users
users = [
  %{username: "alice", email: "alice@example.com"},
  %{username: "bob", email: "bob@example.com"},
  %{username: "charlie", email: "charlie@example.com"}
]

created_users =
  Enum.map(users, fn user_attrs ->
    case Accounts.create_user(user_attrs) do
      {:ok, user} ->
        user

      {:error, _} ->
        # User might already exist
        Accounts.get_user_by_username(user_attrs.username)
    end
  end)

# Create sample rooms
alice = List.first(created_users)

rooms = [
  %{name: "General", description: "General discussion", created_by_id: alice.id},
  %{name: "Random", description: "Random thoughts and fun", created_by_id: alice.id},
  %{name: "Tech Talk", description: "Technology discussions", created_by_id: alice.id}
]

created_rooms =
  Enum.map(rooms, fn room_attrs ->
    case Chat.create_room(room_attrs) do
      {:ok, room} ->
        room

      {:error, _} ->
        # Room might already exist
        from(r in Chat.Room, where: r.name == ^room_attrs.name) |> Repo.one()
    end
  end)

# Add users to rooms
for room <- created_rooms, user <- created_users do
  Chat.join_room(user.id, room.id, if(user.id == alice.id, do: "owner", else: "member"))
end

# Create sample messages
general_room = Enum.find(created_rooms, &(&1.name == "General"))

sample_messages = [
  %{content: "Welcome to Chatphoria! 🎉", user_id: alice.id, room_id: general_room.id},
  %{
    content: "This is a real-time chat application built with Phoenix LiveView",
    user_id: alice.id,
    room_id: general_room.id
  },
  %{
    content: "Thanks Alice! Looks great 👍",
    user_id: Enum.at(created_users, 1).id,
    room_id: general_room.id
  }
]

Enum.each(sample_messages, fn message_attrs ->
  Chat.create_message(message_attrs)
end)

IO.puts("Database seeded successfully!")
