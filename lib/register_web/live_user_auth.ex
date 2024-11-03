defmodule RegisterWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  import Phoenix.Component
  use RegisterWeb, :verified_routes

  # Параметр для проверки, что пользователь является администратором
  def on_mount(:admins_only, _params, _session, socket) do
    cond do
      socket.assigns[:current_user]
      && socket.assigns[:current_user].id == "0ecf9e6d-7b14-4721-add4-be00c0b7f813" ->
      {:cont, socket}
     socket.assigns[:current_user]  ->
      # Назначаем flash-сообщение, что доступ только для администраторов
      socket = Phoenix.LiveView.put_flash(socket, :error, "only admins has access")
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
      true  ->
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
