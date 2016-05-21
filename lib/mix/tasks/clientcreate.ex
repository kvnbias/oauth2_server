defmodule Mix.Tasks.Oauth2Server.Clientcreate do
  use Mix.Task

  alias Oauth2Server.OauthClient
  alias Oauth2Server.Repo

  @shortdoc "Creates an oauth client."

  @moduledoc """
    The list of grant types are :
      password
      client_credentials
      refresh_token

    you can execute this command by:
    mix oauth2_server.clientcreate
  """

  def run(args) do
    args |> get_options |> create_client
  end

  # converts options to map
  defp get_options(args) do
    options = OptionParser.parse(args)
    options = Tuple.to_list(options)
    options = List.first(options)

    Enum.reduce options, %{}, fn tuple, object ->
      list = Tuple.to_list(tuple)

      key = List.first(list)
      value = List.last(list)

      Map.put(object, key, value)
    end
  end

  # create oauth client
  defp create_client(options) do

    random_id = :crypto.strong_rand_bytes(40) |> Base.url_encode64 |> binary_part(0, 40)
    secret = :crypto.strong_rand_bytes(40) |> Base.url_encode64 |> binary_part(0, 40)
    allowed_grant_types = to_string Poison.Encoder.encode(options, [])

    params = %{random_id: random_id, secret: secret, allowed_grant_types: allowed_grant_types}

    changeset = OauthClient.changeset(%OauthClient{})

    Repo.start_link
    case Repo.insert(changeset) do
      {:ok, oauth_client} ->
        Mix.shell.info "client_id : " <> random_id <> " secret: " <> secret
      {:error, changeset} ->
        Mix.shell.info "Error creating oauth client"
    end
  end
end