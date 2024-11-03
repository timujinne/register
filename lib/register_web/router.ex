defmodule RegisterWeb.Router do
  use RegisterWeb, :router

  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RegisterWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", RegisterWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      #   on_mount: {MyAppWeb.LiveUserAuth, :live_user_required} do
      #
      # If an authenticated user *may* be present:
      # on_mount {RegisterWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {RegisterWeb.LiveUserAuth, :live_no_user}
    end
  end

  scope "/", RegisterWeb do
    pipe_through :browser

    get "/", PageController, :home
    auth_routes(AuthController, Register.Accounts.User, path: "/auth")
    sign_out_route(AuthController)

    # Remove these if you'd like to use your own authentication views
    sign_in_route(
      register_path: "/register",
      reset_path: "/reset",
      auth_routes_prefix: "/auth",
      on_mount: [{RegisterWeb.LiveUserAuth, :live_no_user}],
      overrides: [RegisterWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
    )

    # Remove this if you do not want to use the reset password feature
    reset_route(auth_routes_prefix: "/auth")
  end

  scope "/" do
    # use RegisterWeb, :live_view
    pipe_through [:browser]
    # import AshAdmin.Router
    # ash_admin "/admin"
    #  ash_admin "/admin", on_mount: [{RegisterWeb.LiveUserAuth, :admins_only}]
    # ash_admin "/csp/admin", live_session_name: :ash_admin_csp, csp_nonce_assign_key: :csp_nonce_value
    # ash_admin("/admin", reset_path: "/admin",register_path: "/admin", on_mount: [{RegisterWeb.LiveUserAuth, :live_user_required} ])
  end

  ash_authentication_live_session :admin_dashboard,
    # :admins_only<- notice this
    on_mount: [{RegisterWeb.LiveUserAuth, :admins_only}],
    session: {AshAdmin.Router, :__session__, [%{"prefix" => "/admin"}, []]},
    root_layout: {AshAdmin.Layouts, :root} do
    scope "/" do
      pipe_through :browser

      live "/admin/*route",
           AshAdmin.PageLive,
           :page,
           private: %{
             live_socket_path: "/live",
             ash_admin_csp_nonce: %{
               img: "ash_admin-Ed55GFnX",
               style: "ash_admin-Ed55GFnX",
               script: "ash_admin-Ed55GFnX"
             }
           }
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", RegisterWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:register, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RegisterWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
