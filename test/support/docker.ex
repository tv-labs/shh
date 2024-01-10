defmodule Docker do
  @moduledoc false

  defmodule Error do
    defexception [:command, :args, :status, :output]

    def message(%{command: command, args: args, status: status, output: output}) do
      "Failed on docker #{Enum.join([command | args], " ")} (#{status}):\n#{output}"
    end
  end

  @doc """
  Checks whether docker is available and ready to be run.

  Returns false if:

  1. Docker is not installed or the `docker` command cannot be found.
  2. you're on Mac or Windows, but Docker Machine is not set up.

  Otherwise returns true and Docker should be ready for use.
  """
  def ready? do
    case cmd("info", []) do
      {_, 0} -> true
      _ -> false
    end
  end

  def build!(tag, dockerfile_path) do
    cmd!("build", ["--quiet", "--tag", tag, dockerfile_path])
  end

  def run!(opts, image, command \\ nil, args \\ []) do
    cmd!("run", Enum.reject(opts ++ [image, command] ++ args, &is_nil/1))
  end

  @doc """
  Runs a docker command with the given arguments.

  Returns a tuple containing the command output and exit status.

  For details, see [`System.cmd/3`](https://hexdocs.pm/elixir/System.html#cmd/3).
  """
  def cmd(command, args \\ []) do
    System.cmd("docker", [command | args], stderr_to_stdout: true)
  end

  @doc """
  Runs a docker command with the given arguments.

  Returns the command output or, if the command exits with a non-zero status,
  raises a `Docker.Error`.
  """
  def cmd!(command, args \\ []) do
    {output, status} = cmd(command, args)

    case status do
      0 -> String.trim(output)
      _ -> raise Error, command: command, args: args, status: status, output: output
    end
  end
end
