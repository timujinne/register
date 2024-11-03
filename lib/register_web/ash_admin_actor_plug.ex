defmodule RegisterWeb.AshAdminActorPlug do
  @moduledoc false
  @behaviour AshAdmin.ActorPlug

  @doc false
  @impl true
  def actor_assigns(socket, _session) do
    dispatcher = socket.assigns[:current_user]

    [actor: dispatcher]
  end

  @doc false
  @impl true
  def set_actor_session(conn), do: conn
end
