defmodule Shh.IntegrationCase do
  @moduledoc false

  require Logger

  use ExUnit.CaseTemplate

  @image "shh-test"

  using do
    quote do
      @moduletag :integration
    end
  end

  setup_all do
    config = start_container!()

    on_exit(fn -> stop_container!(config.id) end)

    password_user = %{user: "password_user", password: "secret"}

    pubkey_user = %{
      user: "pubkey_user",
      password: "password",
      rsa_pass_phrase: File.read!("./test/support/docker/pubkey_user.pub") |> String.trim()
    }

    %{hosts: [config], password_user: password_user, pubkey_user: pubkey_user}
  end

  def start_container! do
    Logger.debug("Starting docker container #{@image}")
    id = Docker.run!(["--rm", "--publish-all", "--detach"], @image)
    [host, port] = Docker.cmd!("port", [id, "22/tcp"]) |> String.split(":")

    dbg(%{
      id: id,
      hostname: host,
      port: String.to_integer(port)
    })
  end

  def stop_container!(id) do
    Logger.debug("Stopping docker container #{id}")
    Docker.cmd!("kill", [id])
  end
end
