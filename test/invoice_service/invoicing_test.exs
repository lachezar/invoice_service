defmodule InvoiceService.InvoicingTest do
  use InvoiceService.DataCase

  alias InvoiceService.Invoicing

  describe "invoices" do
    alias InvoiceService.Invoicing.Invoice

    import InvoiceService.InvoicingFixtures

    @invalid_attrs %{
      sender_id: nil,
      file_type: nil,
      receiver_id: nil
    }

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Invoicing.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Invoicing.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/2 with valid data creates a invoice" do
      valid_attrs = %{
        file_type: "application/pdf",
        receiver_id: 43
      }

      assert {:ok, %Invoice{} = invoice} = Invoicing.create_invoice(42, valid_attrs)
      assert String.length(invoice.id) == 36
      assert invoice.sender_id == 42
      assert invoice.file_type == "application/pdf"
      assert invoice.receiver_id == 43
      assert invoice.is_payable == true
    end

    test "create_invoice/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoicing.create_invoice(-1, @invalid_attrs)
      assert {:error, %Ecto.Changeset{}} = Invoicing.create_invoice(42, @invalid_attrs)
    end
  end
end
