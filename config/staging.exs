use Mix.Config

config :digital_public_works, DigitalPublicWorksWeb.Endpoint,
  url: [scheme: "https", host: "staging.digitalpublicworks.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info


database_url = System.fetch_env!("DATABASE_URL") 

config :digital_public_works, DigitalPublicWorks.Repo,
  ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

config :digital_public_works, DigitalPublicWorksWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

config :digital_public_works, DigitalPublicWorksWeb.Mailer,
  adapter: Bamboo.SendGridAdapter,
  sandbox: true,
  api_key: System.fetch_env!("SENDGRID_API_KEY"),
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ]
