defmodule Chatphoria.Chat.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    field :last_message_at, :utc_datetime

    belongs_to :user1, Chatphoria.Accounts.User
    belongs_to :user2, Chatphoria.Accounts.User
    has_many :messages, Chatphoria.Chat.Message

    timestamps()
  end

  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:user1_id, :user2_id, :last_message_at])
    |> validate_required([:user1_id, :user2_id])
    |> validate_different_users()
    |> order_user_ids()
    |> unique_constraint([:user1_id, :user2_id])
  end

  defp validate_different_users(changeset) do
    user1_id = get_field(changeset, :user1_id)
    user2_id = get_field(changeset, :user2_id)

    if user1_id && user2_id && user1_id == user2_id do
      add_error(changeset, :user2_id, "cannot create conversation with yourself")
    else
      changeset
    end
  end

  defp order_user_ids(changeset) do
    user1_id = get_field(changeset, :user1_id)
    user2_id = get_field(changeset, :user2_id)

    if user1_id && user2_id && user1_id > user2_id do
      changeset
      |> put_change(:user1_id, user2_id)
      |> put_change(:user2_id, user1_id)
    else
      changeset
    end
  end

  def get_other_user(%__MODULE__{user1_id: user1_id, user2_id: user2_id}, current_user_id) do
    if current_user_id == user1_id, do: user2_id, else: user1_id
  end
end
