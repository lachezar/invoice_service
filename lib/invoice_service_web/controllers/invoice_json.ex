defmodule InvoiceServiceWeb.InvoiceJSON do
  alias InvoiceService.Invoicing.Invoice

  @doc """
  Renders a list of invoices.
  """
  def index(%{invoices: invoices}) do
    %{data: for(invoice <- invoices, do: data(invoice))}
  end

  @doc """
  Renders a single invoice.
  """
  def show(%{invoice: invoice}) do
    %{data: data(invoice)}
  end

  defp data(%Invoice{} = invoice) do
    %{
      id: invoice.id,
      sender_id: invoice.sender_id,
      file_type: invoice.file_type,
      receiver_id: invoice.receiver_id,
      is_payable: invoice.is_payable
    }
  end
end
