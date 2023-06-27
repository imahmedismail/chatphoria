defmodule Chatphoria.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChatphoriaWeb.Telemetry,
      # Start the Ecto repository
      Chatphoria.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Chatphoria.PubSub},
      # Start Finch
      {Finch, name: Chatphoria.Finch},
      # Start the Endpoint (http/https)
      ChatphoriaWeb.Endpoint
      # Start a worker by calling: Chatphoria.Worker.start_link(arg)
      # {Chatphoria.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatphoria.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatphoriaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
