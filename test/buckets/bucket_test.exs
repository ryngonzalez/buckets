defmodule Buckets.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Buckets.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "Stores values by key", %{bucket: bucket} do
    assert Buckets.Bucket.get(bucket, "milk") == nil

    Buckets.Bucket.put(bucket, "milk", 3)
    assert Buckets.Bucket.get(bucket, "milk") == 3
  end

  test "deletes value from bucket by key", %{bucket: bucket} do
    Buckets.Bucket.put(bucket, "milk", 3)
    assert Buckets.Bucket.get(bucket, "milk") == 3

    value = Buckets.Bucket.delete(bucket, "milk")
    assert Buckets.Bucket.get(bucket, "milk") == nil
    assert value == 3
  end
end
