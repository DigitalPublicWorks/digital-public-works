defmodule DigitalPublicWorks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      DigitalPublicWorks.Repo,
      # Start the endpoint when the application starts
      DigitalPublicWorksWeb.Endpoint
      # Starts a worker by calling: DigitalPublicWorks.Worker.start_link(arg)
      # {DigitalPublicWorks.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DigitalPublicWorks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DigitalPublicWorksWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
