defmodule DigitalPublicWorks.Repo do
  use Ecto.Repo,
    otp_app: :digital_public_works,
    adapter: Ecto.Adapters.Postgres
end
