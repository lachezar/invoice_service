defmodule InvoiceService.Repo do
  use Ecto.Repo,
    otp_app: :invoice_service,
    adapter: Ecto.Adapters.Postgres
end
