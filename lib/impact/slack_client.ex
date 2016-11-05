defmodule Impact.SlackClient do
  use Slack

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
  def handle_info(%{type: "message", text: text, channel: channel}, slack, state) do
    send_message(text, channel, slack)
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end