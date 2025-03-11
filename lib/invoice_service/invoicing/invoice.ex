defmodule InvoiceService.Invoicing.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "invoices" do
    field :sender_id, :integer
    field :file_type, :string
    field :receiver_id, :integer
    field :is_payable, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:sender_id, :file_type, :receiver_id])
    |> validate_required([:sender_id, :file_type, :receiver_id])
    |> validate_number(:sender_id, greater_than: 0)
    |> validate_number(:receiver_id, greater_than: 0)
    |> validate_inclusion(:file_type, ["application/pdf", "image/png"])
  end

  @doc false
  def mark_as_paid_changeset(%__MODULE__{is_payable: true} = invoice) do
    invoice |> cast(%{is_payable: false}, [:is_payable])
  end
end
