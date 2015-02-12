defmodule Buckets.Registry do
  use GenServer

  ################
  # Client API
  ################

  @doc """
  Starts the registry.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the pid for a given bucket for a name
  stored in the server.

  Returns `{:ok, pid}` if a bucket is found.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Creates a bucket associated with a name in the server
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  @doc """
  Stops our GenServer process
  """
  def stop(server) do
    GenServer.call(server, :stop)
  end

  ################
  # Server callbacks
  ################

  def init(:ok) do
    refs  = HashDict.new
    names = HashDict.new
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, HashDict.fetch(names, name), state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_cast({:create, name}, {names, refs}) do
    if HashDict.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, pid} = Buckets.Bucket.start_link()
      ref = Process.monitor(pid)
      refs = HashDict.put(refs, ref, name)
      names = HashDict.put(names, name, pid)
      {:noreply, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = HashDict.pop(refs, ref)
    names = HashDict.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end
