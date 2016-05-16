
**TODO: Add description**

## Installation

Oauth2 Server for Phoenix Framework

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add oauth2servercli to your list of dependencies in `mix.exs`:

        def deps do
          [{:oauth2server, "~> 0.0.1"}]
        end

  2. Ensure oauth2server is started before your application:

        def application do
          [applications: [:oauth2server]]
        end
