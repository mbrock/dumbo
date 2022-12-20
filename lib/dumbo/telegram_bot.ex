defmodule Dumbo.TelegramBot do
  use Telegram.Bot

  require Logger

  def send_message(token, chat_id, text) do
    Telegram.Api.request(
      token,
      "sendMessage",
      chat_id: chat_id,
      text: text
    )
  end

  @impl Telegram.Bot

  def handle_update(
        %{
          "message" => %{
            "text" => "/" <> command,
            "chat" => %{"id" => chat_id}
          }
        },
        token
      ) do
    # turn foo@somebotname into foo
    [command | _] = String.split(command, "@")

    Logger.info("Telegram command: #{command}")

    handle_command(command, chat_id, token)
  end

  def handle_update(message, _token) do
    Logger.info("Telegram message: #{inspect(message)}")
  end

  def set_brightness(device, brightness) do
    Dumbo.Zigbee.set_state(device, true, %{"brightness" => brightness})
  end

  def turn_on(device) do
    Dumbo.Zigbee.set_state(device, true)
  end

  def turn_off(device) do
    Dumbo.Zigbee.set_state(device, false)
  end

  def start_fade(device, step) do
    if step > 0 do
      Dumbo.Zigbee.tell(device, %{"brightness_move_onoff" => step})
    else
      Dumbo.Zigbee.tell(device, %{"brightness_move" => step})
    end
  end

  def fade(:in, device, step) do
    start_fade(device, step)
  end

  def fade(:out, device, step) do
    start_fade(device, -step)
  end

  def fade_home(direction) do
    for device <- ["jazi-spot-bed", "jazi-spot-desk", "jazi-spot-mid"] do
      fade(direction, device, 3)
    end

    for device <- ["living-room-ceiling", "living-room-corner", "kitchen-globe", "oak-lamp"] do
      fade(direction, device, 3)
    end
  end

  def all_off do
    for device <- ["jazi-spot-bed", "jazi-spot-desk", "jazi-spot-mid"] do
      turn_off(device)
    end

    for device <- ["living-room-ceiling", "living-room-corner", "kitchen-globe", "oak-lamp"] do
      turn_off(device)
    end
  end

  def handle_command("bedtime", chat_id, token) do
    send_message(token, chat_id, "Good night!")
    turn_on("jazi-salt-lamp")
    fade_home(:out)
    Dumbo.Rules.Bathroom.set_mode(:sleep)
  end

  def handle_command("morning", chat_id, token) do
    send_message(token, chat_id, "Good morning!")
    fade_home(:in)
    Dumbo.Rules.Bathroom.set_mode(:normal)
  end

  def handle_command("night", chat_id, token) do
    send_message(token, chat_id, "Good night!")
    all_off()
    Dumbo.Rules.Bathroom.set_mode(:sleep)
  end

  def handle_command("livingroom", chat_id, token) do
    send_message(token, chat_id, "Turning on living room lights")
    turn_on("living-room-ceiling")
    turn_on("living-room-corner")
  end

  def handle_command("ping", chat_id, token) do
    send_message(token, chat_id, "pong")
  end
end
