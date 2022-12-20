defmodule Dumbo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    zigbee_hub_children =
      case Application.fetch_env!(:dumbo, :zigbee_hub) do
        true ->
          [
            Dumbo.DeviceSet,
            Dumbo.MessageLog,
            Dumbo.Rules.Bathroom,
            # Dumbo.Automation,
            {
              Tortoise.Connection,
              client_id: Dumbo.Zigbee,
              handler: {Dumbo.Zigbee, []},
              server: {Tortoise.Transport.Tcp, host: "localhost", port: 1883},
              subscriptions: [{"zigbee2mqtt/#", 0}]
            }
          ]

        _ ->
          []
      end

    telegram_bot_children =
      case Application.fetch_env!(:dumbo, :telegram_token) do
        true ->
          [
            {Telegram.Poller,
             bots: [
               {Dumbo.TelegramBot,
                [
                  token: Application.fetch_env!(:dumbo, :telegram_token),
                  max_bot_concurrency: 10
                ]}
             ]}
          ]

        _ ->
          []
      end

    children =
      [
        # Start the Telemetry supervisor
        DumboWeb.Telemetry,
        # Start the Ecto repository
        Dumbo.Repo,
        # Start the PubSub system
        {Phoenix.PubSub, name: Dumbo.PubSub},
        # Start Finch
        {Finch, name: Dumbo.Finch},
        # Start the Endpoint (http/https)
        DumboWeb.Endpoint
      ] ++ zigbee_hub_children ++ telegram_bot_children

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dumbo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DumboWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
