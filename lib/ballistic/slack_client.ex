defmodule Ballistic.SlackClient do
  require Logger
  use Slack

  @message_types [
    {"go live$", :golive}
  ]

  def start_link(name) do
    token = Application.get_env(:slack, :api_token)

    # For some reason, the name isn't being passed as expected
    {:ok, pid} = Slack.Bot.start_link(__MODULE__, [], token)
    Process.register(pid, name)
    {:ok, pid}
  end

  # Public API
  def send_message(message_text, channel) do
    rtm = GenServer.whereis(__MODULE__)
    send rtm, %{type: "message", text: message_text, channel: channel}
  end

  def handle_connect(slack, state) do
    Logger.debug("Connected to Slack as #{slack.me.name}.")
    {:ok, state}
  end

  # Private'ish API
  def handle_event(message = %{type: "message"}, slack, state) do
    message |> parse(slack) |> act_on_message(slack)
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  defp act_on_message({:golive, _message}, _slack) do
    Ballistic.Server.go_live
  end

  defp act_on_message({:unknown, _message}, _slack), do: :ok

  defp parse(message, slack) do
    Logger.debug("Slack message received: #{message.text}")
    {_, type} = Enum.find(@message_types, {nil, :unknown}, fn {reg, _type} ->
       String.match?(message.text, ~r/<@#{slack.me.id}>:?\s#{reg}/)
     end)
    {type, message}
  end

  def handle_info(%{type: "message", text: text, channel: channel}, slack, state) do
    send_message(text, channel, slack)
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end