defmodule InvoiceServiceWeb.ConsumerAuthorization do
  @behaviour Plug

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    InvoiceServiceWeb.Authorization.auth(conn, "consumer")
  end
end
