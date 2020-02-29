use Mix.Config

host =
  if System.get_env("HEROKU_PR_NUMBER") do
    "#{System.get_env("HEROKU_APP_NAME")}.herokuapp.com"
  else
    "staging.digitalpublicworks.com"
  end

config :digital_public_works, DigitalPublicWorksWeb.Endpoint,
  url: [scheme: "https", host: host, port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :digital_public_works, DigitalPublicWorks.Repo,
  ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :digital_public_works, DigitalPublicWorksWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT", "4000"))],
  secret_key_base: secret_key_base

config :digital_public_works, DigitalPublicWorksWeb.Mailer,
  adapter: Bamboo.SendGridAdapter,
  sandbox: true,
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ],
  api_key:
    System.get_env("SENDGRID_API_KEY") ||
      raise("""
      environment variable SENDGRID_API_KEY is missing.
      """)
