defmodule Buckets do
  use Application

  def start(_type, _args) do
    Buckets.Supervisor.start_link
  end
end
