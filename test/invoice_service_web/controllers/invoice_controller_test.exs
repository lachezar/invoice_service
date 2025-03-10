defmodule InvoiceServiceWeb.InvoiceControllerTest do
  use InvoiceServiceWeb.ConnCase

  @create_attrs %{
    file_type: "application/pdf",
    receiver_id: 43,
    content: "aGVsbG8="
  }

  @invalid_attrs %{file_type: "bad", receiver_id: -5, content: ""}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "invoice operations" do
    test "renders invoice when data is valid", %{conn: original_conn} do
      conn = put_req_header(original_conn, "authorization", "sender 42")
      conn = post(conn, ~p"/api/sender/invoices", invoice: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/sender/invoices/#{id}")

      assert %{
               "id" => ^id,
               "file_type" => "application/pdf",
               "is_payable" => true,
               "receiver_id" => 43,
               "sender_id" => 42
             } = json_response(conn, 200)["data"]

      conn = put_req_header(original_conn, "authorization", "consumer 43")
      conn = get(conn, ~p"/api/consumer/invoices/#{id}/file")

      assert "hello" = response(conn, 200)

      conn = put_req_header(original_conn, "authorization", "consumer 43")
      conn = post(conn, ~p"/api/consumer/invoices/#{id}/pay")

      assert %{
               "id" => ^id,
               "file_type" => "application/pdf",
               "is_payable" => false,
               "receiver_id" => 43,
               "sender_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "can not pay missing invoice", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "consumer 43")
      id = Ecto.UUID.generate()
      conn = post(conn, ~p"/api/consumer/invoices/#{id}/pay")

      assert json_response(conn, 404)["errors"] != %{}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "sender 42")
      conn = post(conn, ~p"/api/sender/invoices", invoice: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when content is missing", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "sender 42")
      conn = post(conn, ~p"/api/sender/invoices", invoice: Map.delete(@invalid_attrs, :content))
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "http 401 when no valid authorization is supplied", %{conn: conn} do
      conn = post(conn, ~p"/api/sender/invoices", invoice: @create_attrs)
      assert json_response(conn, 401)["error"] == "Not authorized as sender"
    end
  end
end
