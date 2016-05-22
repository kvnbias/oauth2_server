defmodule Oauth2Server.OauthRefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "oauth_refresh_tokens" do
    field :token, :string
    field :expires_at, :integer
    field :is_delete, :integer

    belongs_to :user, Oauth2Server.User
    belongs_to :oauth_client, Oauth2Server.OauthClient
  end

  @required_fields ~w(token expires_at is_delete oauth_client_id)
  @optional_fields ~w(user_id)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> assoc_constraint(:user)
    |> assoc_constraint(:oauth_client)
  end
end
