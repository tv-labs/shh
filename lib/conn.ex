defmodule Shh.Conn do
  @moduledoc false

  # sensitive data might be in options, so dont show it
  @derive {Inspect, except: [:opts]}

  defstruct [:host, :port, :ref, :opts]

  @type t :: %__MODULE__{}

  @default_opts [
    silently_accept_hosts: true,
    user_interaction: false
  ]

  # 128 KiB
  @default_window_size 128 * 1024
  # 32 Kib
  @max_packet_size 32 * 1204

  def connect(host, opts \\ []) do
    {port, opts} = Keyword.pop(opts, :port, 22)

    opts =
      for {k, v} <- Keyword.merge(@default_opts, opts) do
        {k, if(is_binary(v), do: to_charlist(v), else: v)}
      end

    case :ssh.connect(to_charlist(host), port, opts) do
      {:ok, ref} -> {:ok, %__MODULE__{host: host, port: port, ref: ref, opts: opts}}
      {:error, error} -> {:error, format_error(error)}
    end
  end

  def connect!(host, opts \\ []) do
    case connect(host, opts) do
      {:ok, conn} ->
        conn

      {:error, reason} ->
        # TODO raise a better exception
        raise reason
    end
  end

  @spec open_channel(t()) :: {:ok, t(), :ssh.channel_id()} | {:error, :closed | :timeout}
  def open_channel(%__MODULE__{ref: ref}, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, :infinity)
    window_size = Keyword.get(opts, :initial_window_size, @default_window_size)
    max_packet_size = Keyword.get(opts, :max_packet_size, @max_packet_size)

    :ssh_connection.session_channel(ref, window_size, max_packet_size, timeout)
  end

  def open_channel!(conn, opts \\ []) do
    case open_channel(conn, opts) do
      {:ok, id} ->
        id

      {:error, reason} ->
        # TODO raise a better exception
        raise reason
    end
  end

  def exec(%__MODULE__{ref: ref} = conn, command, opts \\ []) do
    timeout = opts[:timeout] || :infinity
    {:ok, channel} = open_channel(conn)
    :ssh_connection.exec(ref, channel, command, timeout)
  end

  def receive_channel(%__MODULE__{ref: ref}, id, timeout) do
    receive do
      {:ssh_cm, ^ref, {:data, ^id, type, data}} ->
        {:data, if(type == 0, do: :normal, else: :error), data}

      {:ssh_cm, ^ref, {:exit_status, ^id, code}} ->
        {:exit_status, code}

      {:ssh_cm, ^ref, {message, ^id}} when message in [:eof, :closed] ->
        :closed

      other ->
        raise "TODO Need to handle other cases #{inspect(other)}"
    after
      timeout -> {:error, :timeout}
    end
  end

  def flush_channel(%__MODULE__{ref: ref} = conn, id) do
    receive do
      {:ssh_cm, ^ref, {_, ^id, _}} -> flush_channel(conn, id)
    after
      0 -> :ok
    end
  end

  defp format_error(list) when is_list(list) do
    List.to_string(list)
  end

  defp format_error(error), do: error
end
