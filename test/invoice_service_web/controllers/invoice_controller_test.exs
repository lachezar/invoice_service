defmodule InvoiceServiceWeb.InvoiceControllerTest do
  use InvoiceServiceWeb.ConnCase

  @create_attrs %{
    file_type: "application/pdf",
    receiver_id: 43
  }

  @invalid_attrs %{file_type: "bad", receiver_id: -5}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  # describe "index" do
  #   test "lists all invoices", %{conn: conn} do
  #     conn = get(conn, ~p"/api/invoices")
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  describe "create invoice" do
    test "renders invoice when data is valid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "sender 42")
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
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "sender 42")
      conn = post(conn, ~p"/api/sender/invoices", invoice: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "http 401 when no valid authorization is supplied", %{conn: conn} do
      conn = post(conn, ~p"/api/sender/invoices", invoice: @create_attrs)
      assert json_response(conn, 401)["error"] == "Not authorized as sender"
    end
  end
end
