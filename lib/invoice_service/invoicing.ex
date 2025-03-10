defmodule InvoiceService.Invoicing do
  @moduledoc """
  The Invoicing context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias InvoiceService.Repo

  alias InvoiceService.Invoicing.Invoice
  alias InvoiceService.Invoicing.FileRepository

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
      Invoice |> where(id: ^invoice_id, receiver_id: ^consumer_id) |> Repo.one()

    case invoice do
      nil ->
        {:error, :not_found}

      %Invoice{is_payable: false} ->
        {:error, :invoice_not_payable}

      invoice ->
        Logger.debug("About to trigger payment for #{inspect(invoice)}")
        Logger.debug("Triggering payment...")
        Logger.debug("Payment completed...")
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

  def create_invoice(sender_id, %{"content" => content} = attr) when is_binary(content) do
    id = Ecto.UUID.generate()

    with :ok <- FileRepository.store(id, content),
         {:ok, invoice} <-
           %Invoice{id: id, sender_id: sender_id}
           |> Invoice.create_changeset(attr)
           |> Repo.insert() do
      {:ok, invoice}
    else
      {:error, %Ecto.Changeset{}} = err -> err
      err -> err
    end
  end

  def create_invoice(_, _) do
    {:error, :client}
  end

  def download_file(consumer_id, invoice_id) do
    invoice = Invoice |> where(id: ^invoice_id, receiver_id: ^consumer_id) |> Repo.one()

    if invoice != nil do
      case FileRepository.retrieve(invoice_id) do
        {:ok, content} -> {:ok, {content, invoice.file_type}}
        _err -> {:error, :not_found}
      end
    else
      {:error, :not_found}
    end
  end
end
