defmodule Impact do
  use Application

  def start(_type, _args) do
    Impact.Supervisor.start_link
  end
end
