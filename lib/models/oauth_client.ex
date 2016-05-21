defmodule Oauth2Server.OauthClient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "oauth_clients" do
    field :random_id, :string
    field :secret, :string
    field :allowed_grant_types, :string

    timestamps
  end

  @required_fields ~w(random_id secret allowed_grant_types)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
