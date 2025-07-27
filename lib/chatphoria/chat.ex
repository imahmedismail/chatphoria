defmodule Chatphoria.Chat do
  import Ecto.Query, warn: false
  alias Chatphoria.Repo

  alias Chatphoria.Chat.{
    Room,
    Message,
    RoomMembership,
    Conversation,
    MessageReceipt,
    MessageDraft
  }

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
    result =
      %Message{}
      |> Message.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, message} ->
        # Create delivery receipts for all recipients
        create_delivery_receipts(message)
        result

      error ->
        error
    end
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

  # Conversations
  def list_conversations_for_user(user_id) do
    from(c in Conversation,
      where: c.user1_id == ^user_id or c.user2_id == ^user_id,
      order_by: [desc: c.last_message_at],
      preload: [:user1, :user2]
    )
    |> Repo.all()
  end

  def get_conversation!(id) do
    Repo.get!(Conversation, id)
    |> Repo.preload([:user1, :user2, messages: [:user]])
  end

  def get_or_create_conversation(user1_id, user2_id) do
    {lower_id, higher_id} =
      if user1_id < user2_id, do: {user1_id, user2_id}, else: {user2_id, user1_id}

    case Repo.get_by(Conversation, user1_id: lower_id, user2_id: higher_id) do
      nil ->
        create_conversation(%{user1_id: lower_id, user2_id: higher_id})

      conversation ->
        {:ok, conversation}
    end
  end

  def create_conversation(attrs \\ %{}) do
    %Conversation{}
    |> Conversation.changeset(attrs)
    |> Repo.insert()
  end

  def list_messages_for_conversation(conversation_id, limit \\ 50) do
    from(m in Message,
      where: m.conversation_id == ^conversation_id,
      order_by: [desc: m.inserted_at],
      limit: ^limit,
      preload: [:user]
    )
    |> Repo.all()
    |> Enum.reverse()
  end

  def create_conversation_message(attrs \\ %{}) do
    result =
      %Message{}
      |> Message.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, message} ->
        # Update conversation's last_message_at
        if message.conversation_id do
          update_conversation_timestamp(message.conversation_id)
        end

        # Create delivery receipts for all recipients
        create_delivery_receipts(message)

        result

      error ->
        error
    end
  end

  # Message Receipt Functions
  def create_delivery_receipts(message) do
    recipient_ids = get_message_recipients(message)
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    receipts =
      Enum.map(recipient_ids, fn user_id ->
        %{
          message_id: message.id,
          user_id: user_id,
          delivered_at: DateTime.to_naive(DateTime.utc_now() |> DateTime.truncate(:second)),
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(MessageReceipt, receipts)
  end

  def mark_message_as_read(message_id, user_id) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    case Repo.get_by(MessageReceipt, message_id: message_id, user_id: user_id) do
      nil ->
        {:error, :receipt_not_found}

      receipt ->
        receipt
        |> Ecto.Changeset.change(%{read_at: now})
        |> Repo.update()
    end
  end

  def mark_conversation_as_read(conversation_id, user_id) do
    from(mr in MessageReceipt,
      join: m in Message,
      on: mr.message_id == m.id,
      where:
        m.conversation_id == ^conversation_id and mr.user_id == ^user_id and is_nil(mr.read_at)
    )
    |> Repo.update_all(set: [read_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)])
  end

  def mark_room_as_read(room_id, user_id) do
    from(mr in MessageReceipt,
      join: m in Message,
      on: mr.message_id == m.id,
      where: m.room_id == ^room_id and mr.user_id == ^user_id and is_nil(mr.read_at)
    )
    |> Repo.update_all(set: [read_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)])
  end

  def get_message_receipt_status(message_id, _context_id) do
    message =
      Message
      |> Repo.get!(message_id)
      |> Repo.preload([:user, :room, :conversation])

    # Get all receipts for this message
    receipts =
      from(mr in MessageReceipt,
        where: mr.message_id == ^message_id,
        select: %{user_id: mr.user_id, read_at: mr.read_at}
      )
      |> Repo.all()

    # Get all users who should receive this message
    recipient_ids =
      case {message.room_id, message.conversation_id} do
        {room_id, nil} when not is_nil(room_id) ->
          # Get all room members except the sender
          from(rm in RoomMembership,
            where: rm.room_id == ^room_id and rm.user_id != ^message.user_id,
            select: rm.user_id
          )
          |> Repo.all()

        {nil, conversation_id} when not is_nil(conversation_id) ->
          # Get the other user in the conversation
          conversation = get_conversation!(conversation_id)
          [Conversation.get_other_user(conversation, message.user_id)]

        _ ->
          []
      end

    cond do
      # If there are no recipients, consider it delivered
      recipient_ids == [] ->
        :delivered

      # If all recipients have read the message
      Enum.all?(recipient_ids, fn user_id ->
        Enum.any?(receipts, &(&1.user_id == user_id && &1.read_at != nil))
      end) ->
        :read

      # If all recipients have at least received the message
      Enum.all?(recipient_ids, fn user_id ->
        Enum.any?(receipts, &(&1.user_id == user_id))
      end) ->
        :delivered

      true ->
        :delivered
    end
  end

  def count_message_reads(message_id) do
    from(mr in MessageReceipt,
      where: mr.message_id == ^message_id and not is_nil(mr.read_at),
      select: count(mr.id)
    )
    |> Repo.one()
  end

  defp update_conversation_timestamp(conversation_id) do
    from(c in Conversation, where: c.id == ^conversation_id)
    |> Repo.update_all(set: [last_message_at: DateTime.utc_now()])
  end

  defp get_message_recipients(message) do
    cond do
      message.room_id ->
        # Get all room members except the sender
        from(rm in RoomMembership,
          where: rm.room_id == ^message.room_id and rm.user_id != ^message.user_id,
          select: rm.user_id
        )
        |> Repo.all()

      message.conversation_id ->
        # Get the other user in the conversation
        conversation = get_conversation!(message.conversation_id)
        [Conversation.get_other_user(conversation, message.user_id)]

      true ->
        []
    end
  end

  # Message Draft Functions
  def create_message_draft(attrs \\ %{}) do
    %MessageDraft{}
    |> MessageDraft.changeset(attrs)
    |> Repo.insert()
  end

  def get_user_drafts(user_id) do
    from(d in MessageDraft,
      where: d.user_id == ^user_id,
      order_by: [desc: d.updated_at]
    )
    |> Repo.all()
  end

  def get_context_draft(user_id, context_type, context_id) do
    base_query = from(d in MessageDraft, where: d.user_id == ^user_id)

    query =
      case context_type do
        "room" ->
          from(d in base_query,
            where: d.context_type == "room" and d.room_id == ^context_id,
            order_by: [desc: d.updated_at],
            limit: 1
          )

        "conversation" ->
          from(d in base_query,
            where: d.context_type == "conversation" and d.conversation_id == ^context_id,
            order_by: [desc: d.updated_at],
            limit: 1
          )
      end

    case Repo.all(query) do
      [draft | _] -> draft
      [] -> nil
    end
  end

  def update_message_draft(%MessageDraft{} = draft, attrs) do
    draft
    |> MessageDraft.changeset(attrs)
    |> Repo.update()
  end

  def delete_message_draft(%MessageDraft{} = draft) do
    Repo.delete(draft)
  end
end
