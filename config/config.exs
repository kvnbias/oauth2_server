use Mix.Config

config :oauth2_server, Oauth2Server.Repo,
  adapter: Ecto.Adapters.MySQL,
  timeout: 15000,
  username: "kev",
  password: "chickenburritome",
  database: "phoenixtrial_dev",
  hostname: "localhost",
  ssl: false,
  port: 3306,
  connect_timeout: 5000
