defmodule InvoiceService.Invoicing.FileRepository do
  def store(filename, base64_content) do
    folder = Application.fetch_env!(:invoice_service, :file_repository_folder)
    abs_path = Path.join(folder, filename)

    with {:ok, content} <- Base.decode64(base64_content),
         :ok <- File.write(abs_path, content) do
      :ok
    else
      :error -> {:error, :client}
      err -> err
    end
  end

  def retrieve(filename) do
    folder = Application.fetch_env!(:invoice_service, :file_repository_folder)
    abs_path = Path.join(folder, filename)

    File.read(abs_path)
  end
end
