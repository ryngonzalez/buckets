defmodule Buckets.Bucket do
  @doc """
  Starts a new `bucket`
  """
  def start_link do
    Agent.start_link(fn -> HashDict.new end)
  end

  @doc """
  Gets a value from a given `bucket` by `key`
  """
  def get(bucket, key) do
    Agent.get(bucket, &HashDict.get(&1, key))
  end

  @doc """
  Puts a value into a `bucket` associated with a `key`
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &HashDict.put(&1, key, value))
  end

  @doc """
  Deletes a value from a `bucket` given a key.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn dict ->
      HashDict.pop(dict, key)
    end)
  end
end
