defmodule InvoiceService.InvoicingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceService.Invoicing` context.
  """

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(attrs \\ %{}) do
    {:ok, invoice} =
      InvoiceService.Invoicing.create_invoice(
        42,
        Enum.into(attrs, %{
          file_type: "application/pdf",
          is_payable: true,
          receiver_id: 43
        })
      )

    invoice
  end
end
