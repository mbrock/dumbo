defmodule Dumbo.Repo do
  use Ecto.Repo,
    otp_app: :dumbo,
    adapter: Ecto.Adapters.Postgres
end
