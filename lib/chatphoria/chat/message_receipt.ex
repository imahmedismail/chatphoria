defmodule Chatphoria.Chat.MessageReceipt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "message_receipts" do
    field :read_at, :naive_datetime
    field :delivered_at, :naive_datetime

    belongs_to :message, Chatphoria.Chat.Message
    belongs_to :user, Chatphoria.Accounts.User

    timestamps()
  end

  def changeset(receipt, attrs) do
    receipt
    |> cast(attrs, [:read_at, :delivered_at, :message_id, :user_id])
    |> validate_required([:delivered_at, :message_id, :user_id])
    |> unique_constraint([:message_id, :user_id],
      message: "Receipt already exists for this user and message"
    )
  end
end
