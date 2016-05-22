defmodule Oauth2Server.Repo do
  use Ecto.Repo, otp_app: :oauth2_server

  import Ecto.Query

  alias Oauth2Server.Repo
  alias Oauth2Server.User
  alias Oauth2Server.OauthRefreshToken


  def get_oauth_refresh_token(token, oauth_client_id, expires_at) do

    query = from ort in OauthRefreshToken,
            join: u in User, on: ort.user_id == u.id,
            where: ort.token == ^token and ort.expires_at > ^expires_at and ort.oauth_client_id == ^oauth_client_id and ort.is_delete == 0,
            preload: [user: u]
    
    Repo.one(query)

  end
end
