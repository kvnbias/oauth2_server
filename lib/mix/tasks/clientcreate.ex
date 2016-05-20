defmodule Mix.Tasks.Oauth2Server.Clientcreate do
  use Mix.Task

  @shortdoc "Creates an oauth client."

  @moduledoc """
    The list of grant types are :
        password
        authorization_code
        client_credentials
        refresh_token

    you can execute this command by:
    mix oauth2_server.clientcreate --password --refresh-token --redirect-uri="http://sampleredirect-uri.net" 
  """

  def run(args) do
    args |> get_options |> create_client
  end

  defp get_options(args) do
    options = OptionParser.parse(args)
    options = Tuple.to_list(options)
    options = List.first(options)

    map = Enum.reduce options, %{}, fn tuple, object ->
      list = Tuple.to_list(tuple)

      key = List.first(list)
      value = List.last(list)

      Map.put(object, key, value)
    end
  end

  defp create_client(options) do
    IO.inspect options
    IO.inspect options[:redirect_uri]
    IO.inspect options[:rdot]
  end
end