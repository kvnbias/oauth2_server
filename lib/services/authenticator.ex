defmodule Oauth2Server.Authenticator do

  alias Oauth2Server.Repo
  alias Oauth2Server.OauthClient
  alias Oauth2Server.OauthAccessToken
  alias Oauth2Server.OauthRefreshToken
  alias Oauth2Server.User

  # validates request
  def validate(params) do
    Repo.start_link

    if validate_oauth_params(params) === true do
      oauth_client = Repo.get_by(OauthClient, random_id: params["client_id"], secret: params["secret"])
      
      if oauth_client != nil do
        allowed_grant_types = Poison.Parser.parse!(oauth_client.allowed_grant_types)
        if Map.has_key?(allowed_grant_types, params["grant_type"]) do
          case params["grant_type"] do
            "password" ->
              process_password_grant(params, oauth_client)
            "refresh_token" ->
              process_refresh_token_grant(params["refresh_token"], oauth_client)
            nil ->
              %{message: "Invalid oauth credentials", code: 400}
          end
        end
      else
        %{message: "Invalid oauth credentials", code: 400}
      end
    else
      %{message: "Invalid oauth credentials", code: 400}
    end
  end

  defp process_refresh_token_grant(refresh_token, oauth_client) do
    if refresh_token != nil do
      case generate_refresh_token_grant(refresh_token, oauth_client) do
        {:ok, resp} ->
          resp
        :error ->
          %{message: "An error has occured. Please try again later", code: 400}
      end
    else
      %{message: "Invalid oauth credentials", code: 400}
    end
  end

  defp process_password_grant(params, oauth_client) do
    if validate_login_params(params) == true do
      case generate_password_grant(params, oauth_client) do
        {:ok, resp} ->
          resp
        :error ->
          %{message: "Invalid login credentials", code: 400}
      end
    else
      %{message: "Invalid login credentials", code: 400}
    end
  end

  def generate_refresh_token_grant(token, oauth_client) do
    Repo.transaction(fn ->
      refresh_token = Repo.get_oauth_refresh_token(token, oauth_client.id, :os.system_time(:seconds))
      if refresh_token !== nil do
        changeset = OauthRefreshToken.changeset(refresh_token, %{is_delete: 1})
        case Repo.update(changeset) do
          {:ok, changeset} ->
            user = changeset.user
            case generate_access_token(oauth_client, user) do
              {:ok, oauth_access_token} ->
                case generate_refresh_token(oauth_client, oauth_access_token, user) do
                  {:ok, oauth_refresh_token} ->
                    %{code: 200, access_token: oauth_access_token.token, refresh_token: oauth_refresh_token.token, expires_at: oauth_access_token.expires_at}
                  :error -> 
                    %{message: "An error has occured. Please try again later", code: 400}
                end
              :error -> 
                %{message: "An error has occured. Please try again later", code: 400}
            end
          :error ->
            %{message: "An error has occured. Please try again later", code: 400}
        end
      else
        %{message: "Invalid oauth credentials", code: 400}
      end
    end)
  end

  def generate_password_grant(params, oauth_client) do
    case validate_user(params["email"], params["password"]) do
      {:ok, user} ->
        Repo.transaction(fn ->
          case generate_access_token(oauth_client, user) do
            {:ok, oauth_access_token} ->
              case generate_refresh_token(oauth_client, oauth_access_token, user) do
                {:ok, oauth_refresh_token} ->
                  %{code: 200, access_token: oauth_access_token.token, refresh_token: oauth_refresh_token.token, expires_at: oauth_access_token.expires_at}
                :error -> 
                  %{message: "An error has occured. Please try again later", code: 400}
              end
            :error -> 
              %{message: "An error has occured. Please try again later", code: 400}
          end
        end)
      _ -> :error
    end
  end

  def generate_access_token(oauth_client, user) do
    Repo.start_link
    settings = Application.get_env(:oauth2_server, Oauth2Server.Settings)
    access_token_expiration = :os.system_time(:seconds) + settings[:access_token_expiration]
    token = :crypto.strong_rand_bytes(40) |> Base.url_encode64 |> binary_part(0, 40)

    params = %{oauth_client_id: oauth_client.id, user_id: user.id, token: token, expires_at: access_token_expiration}
    changeset = OauthAccessToken.changeset(%OauthAccessToken{}, params)

    case Repo.insert(changeset) do
      {:ok, oauth_access_token} ->
        {:ok, oauth_access_token}
      _  -> :error
    end
  end

  def generate_refresh_token(oauth_client, access_token, user) do
    Repo.start_link
    settings = Application.get_env(:oauth2_server, Oauth2Server.Settings)
    refresh_token_expiration = access_token.expires_at + settings[:refresh_token_expiration]
    token = :crypto.strong_rand_bytes(40) |> Base.url_encode64 |> binary_part(0, 40)

    params = %{oauth_client_id: oauth_client.id, user_id: user.id, token: token, expires_at: refresh_token_expiration, is_delete: 0}
    changeset = OauthRefreshToken.changeset(%OauthRefreshToken{}, params)

    case Repo.insert(changeset) do
      {:ok, oauth_refresh_token} ->
        {:ok, oauth_refresh_token}
      _ -> :error
    end
  end

  # check if account is valid
  def validate_user(email, password) do
    Repo.start_link
    user = Repo.get_by(User, email: email)
    case authenticate(user, password) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  # validate oauth fields
  defp validate_oauth_params(params) do
    if params["client_id"] != nil and params["secret"] != nil and params["grant_type"] != nil do
      true
    else
      false
    end
  end

  # validate login fields
  defp validate_login_params(params) do
    if params["email"] != nil and params["password"] != nil do
      true
    else
      false
    end
  end

  # validate user credentials
  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.password)
    end
  end
end