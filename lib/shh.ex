defmodule Shh do
  @moduledoc """
  Documentation for `Shh`.
  """

  alias Shh.Conn

  @doc """
  Opens an SSH connection to the given host
  """
  defdelegate connect(host, opts), to: Shh.Conn

  def exec(conn, command, _context, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, :infinity)

    Stream.resource(
      fn ->
        channel = Conn.open_channel!(conn, opts)
        :ssh_connection.exec(conn.ref, channel, to_charlist(command), timeout)
      end,
      fn channel_id ->
        case Conn.receive_channel(conn, channel_id, timeout) do
          {:ok, message} -> {[message], channel_id}
          {:error, :timeout} -> {:halt, channel_id}
        end
      end,
      fn channel_id ->
        :ok = :ssh_connection.close(conn.ref, channel_id)
        :ok = Conn.flush_channel(conn, channel_id)
      end
    )
  end

  @doc """
  Executes the given command on each connection
  """
  def exec_all(_conns, _command, _context) do
  end
end
