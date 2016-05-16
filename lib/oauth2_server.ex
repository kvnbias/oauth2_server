
# Sample execution :
# ./lib/modules/oauth2server/cli/generate --client-credential=true --password=true --authorization-code=true --refresh-token=true --redirect-uri="http://facebook.com"
defmodule Oauth2Server do

  def start(_type, _args) do
    Supervisor.start_link
  end

  def main(args) do
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

