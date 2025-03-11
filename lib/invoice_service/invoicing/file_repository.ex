defmodule InvoiceService.Invoicing.FileRepository do
  def store(filename, base64_content) do
    folder = Application.fetch_env!(:invoice_service, :file_repository_folder)
    abs_path = Path.join(folder, filename)

    with {:ok, content} <- Base.decode64(base64_content),
         :ok <-
           (case File.exists?(abs_path) do
              true -> {:error, :file_exists}
              false -> :ok
            end),
         :ok <- File.write(abs_path, content) do
      :ok
    else
      :error -> {:error, :client}
      {:error, :file_exists} -> {:error, :internal_server_error}
      err -> err
    end
  end

  def retrieve(filename) do
    folder = Application.fetch_env!(:invoice_service, :file_repository_folder)
    abs_path = Path.join(folder, filename)

    File.read(abs_path)
  end
end
