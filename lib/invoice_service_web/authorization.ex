defmodule InvoiceServiceWeb.Authorization do
  import Plug.Conn

  def auth(%Plug.Conn{req_headers: headers} = conn, type) do
    with {:ok, auth_value} <-
           headers
           |> Enum.find(fn
             {"authorization", _} -> true
             _ -> false
           end)
           |> then(fn
             {"authorization", value} -> {:ok, value}
             _ -> {:error, :authorization_header}
           end),
         [^type, raw_user_id] <- String.split(auth_value, " "),
         {:ok, user_id} <-
           (case Integer.parse(raw_user_id) do
              {num, ""} -> {:ok, num}
              {_, _rest} -> {:error, :int_parsing}
              :error -> {:error, :int_parsing}
            end),
         {:ok, :user_id} <- if(user_id < 1, do: {:error, :user_id}, else: {:ok, :user_id}) do
      assign(conn, String.to_atom("#{type}_id"), user_id)
    else
      _err ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "Not authorized as #{type}"}))
        |> halt()
    end
  end
end
