# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :invoice_service,
  ecto_repos: [InvoiceService.Repo],
  generators: [timestamp_type: :utc_datetime],
  file_repository_folder: "/tmp"

# Configures the endpoint
config :invoice_service, InvoiceServiceWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: InvoiceServiceWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: InvoiceService.PubSub,
  live_view: [signing_salt: "Yuf1+b0V"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
