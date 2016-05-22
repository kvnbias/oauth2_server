defmodule Mix.Tasks.Oauth2Server.Init do
  use Mix.Task

  @shortdoc "Initialize oauth tables."

  @moduledoc """
    mix oauth2_server.init
  """

  def run(_args) do
    create_oauth_tables
  end

  def create_oauth_tables() do

    Oauth2Server.Repo.start_link

    create_oauth_clients_query = "CREATE TABLE IF NOT EXISTS oauth_clients (id bigint(20) unsigned NOT NULL AUTO_INCREMENT, random_id varchar(255) NOT NULL, secret varchar(255) NOT NULL, allowed_grant_types varchar(2020) NOT NULL, inserted_at datetime, updated_at datetime, PRIMARY KEY (id))"
    create_oauth_access_tokens_query = "CREATE TABLE IF NOT EXISTS oauth_access_tokens (id bigint(20) unsigned NOT NULL AUTO_INCREMENT, oauth_client_id bigint(20) unsigned NOT NULL, user_id bigint(20) unsigned DEFAULT NULL, token varchar(255) DEFAULT NULL, expires_at int(11) NOT NULL, INDEX IDX_1CF73D31A76ED395 (oauth_client_id), INDEX IDX_1CF73D3144F5D008 (user_id), PRIMARY KEY (id), FOREIGN KEY (oauth_client_id) REFERENCES oauth_clients(id), FOREIGN KEY (user_id) REFERENCES users(id))"
    create_oauth_refresh_tokens_query = "CREATE TABLE IF NOT EXISTS oauth_refresh_tokens (id bigint(20) unsigned NOT NULL AUTO_INCREMENT, oauth_client_id bigint(20) unsigned NOT NULL, user_id bigint(20) unsigned DEFAULT NULL, token varchar(255) DEFAULT NULL, expires_at int(11) NOT NULL, is_delete TINYINT(1) DEFAULT 0 NOT NULL, INDEX IDX_1CF73D31A76ED395 (oauth_client_id), INDEX IDX_1CF73D3144F5D008 (user_id), PRIMARY KEY (id), FOREIGN KEY (oauth_client_id) REFERENCES oauth_clients(id), FOREIGN KEY (user_id) REFERENCES users(id))"

    Ecto.Adapters.SQL.query!(Oauth2Server.Repo, create_oauth_clients_query, [])
    Mix.shell.info "TABLE oauth_clients has been created"
    
    Ecto.Adapters.SQL.query!(Oauth2Server.Repo, create_oauth_access_tokens_query, [])
    Mix.shell.info "TABLE oauth_access_tokens has been created"

    Ecto.Adapters.SQL.query!(Oauth2Server.Repo, create_oauth_refresh_tokens_query, [])
    Mix.shell.info "TABLE oauth_refresh_tokens has been created"
  end
end