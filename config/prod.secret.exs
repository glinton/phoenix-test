use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :app, App.Endpoint,
  secret_key_base: "ilPlYBrWi3h7Xsh7FmaQi2EVlYNL39Qmyfe+fkfkh5W+zAh2UEkPdhmpqz0vwlKF"

# Configure your database: "gonano",
config :app, App.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  database: "gonano",
  hostname: System.get_env("DATA_DB_HOST"),
  pool_size: 20
