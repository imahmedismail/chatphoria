defmodule Chatphoria.Repo do
  use Ecto.Repo,
    otp_app: :chatphoria,
    adapter: Ecto.Adapters.Postgres
end
