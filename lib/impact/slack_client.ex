defmodule Impact.SlackClient do
  require Logger
  use Slack

  @message_types [
    {"golive$", :golive}
  ]

  def start_link(name) do
    token = Application.get_env(:slack, :api_token)

    # For some reason, the name isn't being passed as expected
    {:ok, pid} = Slack.Bot.start_link(__MODULE__, [], token, %{name: name})
    Process.register(pid, name)
    {:ok, pid}
  end

  # Public API
  def send_message(message_text, channel) do
    rtm = GenServer.whereis(__MODULE__)
    send rtm, %{type: "message", text: message_text, channel: channel}
  end

  # Private'ish API
  def handle_message(message = %{type: "message"}, slack) do
    message |> parse(slack) |> act_on_message(slack)
  end

  def act_on_message({:golive, message}, slack) do
    Impact.Server.go_live
  end

  def act_on_message({:unknown, _message}, _slack), do: :ok

  def parse(message, slack) do
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