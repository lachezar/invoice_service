defmodule InvoiceServiceWeb.InvoiceController do
  use InvoiceServiceWeb, :controller

  alias InvoiceService.Invoicing
  alias InvoiceService.Invoicing.Invoice

  action_fallback InvoiceServiceWeb.FallbackController

  def create(%Plug.Conn{assigns: %{sender_id: sender_id}} = conn, %{"invoice" => invoice_params}) do
    with {:ok, %Invoice{} = invoice} <- Invoicing.create_invoice(sender_id, invoice_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/sender/invoices/#{invoice}")
      |> render(:show, invoice: invoice)
    end
  end

  def list_by_sender_id(
        %Plug.Conn{assigns: %{consumer_id: consumer_id}} = conn,
        %{"sender_id" => sender_id}
      ) do
    invoices = Invoicing.list_invoices_by_sender_id(consumer_id, sender_id)
    render(conn, :index, invoices: invoices)
  end

  def trigger_payment(
        %Plug.Conn{assigns: %{consumer_id: consumer_id}} = conn,
        %{"invoice_id" => invoice_id}
      ) do
    case Invoicing.trigger_payment(consumer_id, invoice_id) do
      {:ok, invoice} ->
        render(conn, :show, invoice: invoice)

      {:error, :invoice_not_payable} ->
        send_resp(conn, 409, Jason.encode!(%{error: "Invoice already paid"}))

      {:error, :not_found} ->
        {:error, :not_found}

      _ ->
        {:error, :internal_server_error}
    end
  end

  def show(conn, %{"id" => id}) do
    invoice = Invoicing.get_invoice!(id)
    render(conn, :show, invoice: invoice)
  end

  def download(
        %Plug.Conn{assigns: %{consumer_id: consumer_id}} = conn,
        %{"invoice_id" => invoice_id}
      ) do
    case Invoicing.download_file(consumer_id, invoice_id) do
      {:ok, {content, content_type}} ->
        conn |> put_resp_header("content-type", content_type) |> send_resp(200, content)

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end
end
