defmodule Oauth2Server.Repo do
  use Ecto.Repo, otp_app: :oauth2_server

  import Ecto.Query

  def get_oauth_refresh_token(token, oauth_client_id, expires_at) do
    Oauth2Server.Repo.start_link
    query = from ort in Oauth2Server.OauthRefreshToken,
            join: u in Oauth2Server.User, on: ort.user_id == u.id,
            where: ort.token == ^token and ort.expires_at > ^expires_at and ort.oauth_client_id == ^oauth_client_id and ort.is_delete == 0,
            preload: [user: u]
    
    Oauth2Server.Repo.one(query)

  end

  def get_oauth_access_token(token, expires_at) do
    Oauth2Server.Repo.start_link
    query = from oat in Oauth2Server.OauthAccessToken,
            where: oat.token == ^token and oat.expires_at > ^expires_at
    Oauth2Server.Repo.one(query)

  end
end
