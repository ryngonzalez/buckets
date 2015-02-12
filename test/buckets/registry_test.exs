defmodule Buckets.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, registry} = Buckets.Registry.start_link()
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
end
