defmodule Buckets.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @manager_name Buckets.EventManager
  @registry_name Buckets.Registry
  @bucket_supervisor_name Buckets.Bucket.Supervisor

  def init(:ok) do
    children = [
      worker(GenEvent,                  [[name: @manager_name]]),
      worker(Buckets.Bucket.Supervisor, [[name: @bucket_supervisor_name]]),
      worker(Buckets.Registry,          [@manager_name, @bucket_supervisor_name, [name: @registry_name]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
