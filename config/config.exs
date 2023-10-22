import Config

case config_env() do
  :prod ->
    nil

  :dev ->
    config :mix_test_interactive, clear: true

  :test ->
    nil
end
