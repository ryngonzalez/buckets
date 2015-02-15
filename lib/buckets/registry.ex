defmodule Buckets.Registry do
  use GenServer

  ################
  # Client API
  ################

  @doc """
  Starts the registry.
  """
  def start_link(event_manager, opts \\ []) do
    GenServer.start_link(__MODULE__, event_manager, opts)
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

  def init(events) do
    refs  = HashDict.new
    names = HashDict.new
    {:ok, %{names: names, refs: refs, events: events}}
  end

  def handle_call({:lookup, name}, _from, %{names: names} = state) do
    {:reply, HashDict.fetch(names, name), state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_cast({:create, name}, state) do
    if HashDict.has_key?(state.names, name) do
      {:noreply, %{state | names: state.names, refs: state.refs}}
    else
      {:ok, pid} = Buckets.Bucket.start_link()
      ref = Process.monitor(pid)
      refs = HashDict.put(state.refs, ref, name)
      names = HashDict.put(state.names, name, pid)
      GenEvent.sync_notify(state.events, {:create, name, pid})
      {:noreply, %{state | names: names, refs: refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    {name, refs} = HashDict.pop(state.refs, ref)
    names = HashDict.delete(state.names, name)
    GenEvent.sync_notify(state.events, {:exit, name, pid})
    {:noreply, %{state | names: names, refs: refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end
