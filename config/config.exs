# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :digital_public_works,
  ecto_repos: [DigitalPublicWorks.Repo]

# Configures the endpoint
config :digital_public_works, DigitalPublicWorksWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iig2654KSyqr8blQ+aFjVo8u4OfBsCvrMqVBaTPUcvrxgBLmM+LyRlOkmGvtla3P",
  render_errors: [view: DigitalPublicWorksWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DigitalPublicWorks.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix_bootstrap_form,
  label_col_class: "",
  control_col_class: "",
  label_align_class: "",
  form_group_class: "form-group"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
