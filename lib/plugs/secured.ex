defmodule Oauth2Server.Secured do
  import Plug.Conn

  def init(default), do: default

  def call(%Plug.Conn{params: %{"access_token" => access_token}} = conn, _default) do
    oauth_access_token = Oauth2Server.Repo.get_oauth_access_token(access_token, :os.system_time(:seconds));

    case oauth_access_token do
      nil ->
        conn
          |> put_resp_content_type("application/json")
          |> send_resp(400, Poison.encode!(%{message: "Not authorized"}))
      _ ->
        case oauth_access_token.user_id do
          nil -> 
            conn
              |> put_resp_content_type("application/json")
              |> send_resp(400, Poison.encode!(%{message: "Not authorized"}))
          _ -> 
            put_session(conn, :oauth2_server_user_id, oauth_access_token.user_id)
        end
    end
  end

  def call(conn, default) do 
      conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Poison.encode!(%{message: "Not authorized"}))
  end
end