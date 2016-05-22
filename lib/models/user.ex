defmodule Oauth2Server.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string

    has_many :oauth_access_token, Oauth2Server.OauthAccessToken
    has_many :oauth_refresh_token, Oauth2Server.OauthRefreshToken
    timestamps
  end

  @required_fields ~w(email password)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
