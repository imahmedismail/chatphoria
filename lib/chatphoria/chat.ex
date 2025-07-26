defmodule Chatphoria.Chat do
  import Ecto.Query, warn: false
  alias Chatphoria.Repo
  alias Chatphoria.Chat.{Room, Message, RoomMembership}

  # Rooms
  def list_rooms do
    from(r in Room, preload: [:created_by])
    |> Repo.all()
  end

  def list_public_rooms do
    from(r in Room, where: r.is_private == false, preload: [:created_by])
    |> Repo.all()
  end

  def get_room!(id) do
    Repo.get!(Room, id)
    |> Repo.preload([:created_by, :users, messages: [:user]])
  end

  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  # Messages
  def list_messages_for_room(room_id, limit \\ 50) do
    from(m in Message,
      where: m.room_id == ^room_id,
      order_by: [desc: m.inserted_at],
      limit: ^limit,
      preload: [:user]
    )
    |> Repo.all()
    |> Enum.reverse()
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  # Room Memberships
  def join_room(user_id, room_id, role \\ "member") do
    attrs = %{
      user_id: user_id,
      room_id: room_id,
      role: role,
      joined_at: DateTime.utc_now()
    }

    %RoomMembership{}
    |> RoomMembership.changeset(attrs)
    |> Repo.insert()
  end

  def leave_room(user_id, room_id) do
    case get_room_membership(user_id, room_id) do
      nil -> {:error, :not_member}
      membership -> Repo.delete(membership)
    end
  end

  def get_room_membership(user_id, room_id) do
    Repo.get_by(RoomMembership, user_id: user_id, room_id: room_id)
  end

  def is_member?(user_id, room_id) do
    get_room_membership(user_id, room_id) != nil
  end

  def get_user_rooms(user_id) do
    from(r in Room,
      join: rm in RoomMembership,
      on: r.id == rm.room_id,
      where: rm.user_id == ^user_id,
      preload: [:created_by]
    )
    |> Repo.all()
  end
end