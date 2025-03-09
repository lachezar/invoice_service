defmodule InvoiceService.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :sender_id, :integer, null: false
      add :file_type, :string, null: false
      add :receiver_id, :integer, null: false
      add :is_payable, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
