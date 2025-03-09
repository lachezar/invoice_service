defmodule InvoiceService.Invoicing do
  @moduledoc """
  The Invoicing context.
  """

  import Ecto.Query, warn: false
  alias InvoiceService.Repo

  alias InvoiceService.Invoicing.Invoice

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Repo.all(Invoice)
  end

  def list_invoices_by_sender_id(consumer_id, sender_id) do
    Invoice |> where(sender_id: ^sender_id, receiver_id: ^consumer_id) |> Repo.all()
  end

  def trigger_payment(consumer_id, invoice_id) do
    invoice =
      Invoice |> where(id: ^invoice_id, receiver_id: ^consumer_id, is_payable: true) |> Repo.one()

    if invoice == nil do
      {:error, :no_invoice_to_pay}
    else
      IO.inspect(invoice)
      IO.puts("About to trigger payment...")
      IO.puts("Triggering payment...")
      IO.puts("Payment completed...")
      invoice |> Invoice.mark_as_paid_changeset() |> Repo.update()
    end
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id), do: Repo.get!(Invoice, id)

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(%{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(sender_id, %{} = attr) do
    id = Ecto.UUID.generate()
    # store the file here
    %Invoice{id: id, sender_id: sender_id}
    |> Invoice.create_changeset(attr)
    |> Repo.insert()
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Invoice{} = _invoice, _attrs) do
    :not_implemented
    # invoice
    # |> Invoice.changeset(attrs)
    # |> Repo.update()
  end

  @doc """
  Deletes a invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{data: %Invoice{}}

  """
  def change_invoice(%Invoice{} = _invoice, _attrs \\ %{}) do
    # Invoice.changeset(invoice, attrs)
    :not_implemented
  end
end
