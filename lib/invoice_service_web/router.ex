defmodule InvoiceServiceWeb.Router do
  use InvoiceServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth_consumer do
    plug InvoiceServiceWeb.ConsumerAuthorization
  end

  pipeline :auth_sender do
    plug InvoiceServiceWeb.SenderAuthorization
  end

  scope "/api/sender", InvoiceServiceWeb do
    pipe_through [:api, :auth_sender]

    resources "/invoices", InvoiceController, only: [:create, :show]
  end

  scope "/api/consumer", InvoiceServiceWeb do
    pipe_through [:api, :auth_consumer]

    resources "/invoices", InvoiceController, only: [:index, :show]
    get "/invoices/sender/:sender_id", InvoiceController, :list_by_sender_id
    post "/invoices/:invoice_id/pay", InvoiceController, :trigger_payment
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:invoice_service, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: InvoiceServiceWeb.Telemetry
    end
  end
end
