defmodule Buckets.RegistryTest do
  use ExUnit.Case, async: true

  defmodule Forwarder do
    use GenEvent

    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end


  setup do
    {:ok, manager} = GenEvent.start_link
    {:ok, registry} = Buckets.Registry.start_link(manager)

    GenEvent.add_mon_handler(manager, Forwarder, self())
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert Buckets.Registry.lookup(registry, "shopping") == :error

    Buckets.Registry.create(registry, "shopping")
    assert {:ok, bucket} = Buckets.Registry.lookup(registry, "shopping")

    Buckets.Bucket.put(bucket, "milk", 1)
    assert Buckets.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    Buckets.Registry.create(registry, "shopping")

    {:ok, bucket} = Buckets.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)

    assert Buckets.Registry.lookup(registry, "shopping") == :error
  end

  test "sends events on create and crash", %{registry: registry} do
    Buckets.Registry.create(registry, "shopping")
    {:ok, bucket} = Buckets.Registry.lookup(registry, "shopping")
    assert_receive {:create, "shopping", ^bucket}

    Agent.stop(bucket)
    assert_receive {:exit, "shopping", ^bucket}
  end
end
