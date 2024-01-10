defmodule Shh.IntegrationTest do
  use Shh.IntegrationCase

  test "it can connect with username and password", %{hosts: [host], password_user: user} do
    assert {:ok, _conn} =
             Shh.connect(host.hostname, port: host.port, user: user.user, password: user.password)

    assert {:error, "Unable to connect using the available authentication methods"} =
             Shh.connect(host.hostname, port: host.port, user: user.user, password: "invalid")
  end

  test "it can connect with a public key", %{hosts: [host], pubkey_user: user} do
    assert {:ok, _conn} =
             Shh.connect(host.hostname,
               port: host.port,
               user: user.user,
               password: user.password,
               rsa_pass_phrase: user.rsa_pass_phrase
             )

    assert {:error, "Unable to connect using the available authentication methods"} =
             Shh.connect(host.hostname,
               port: host.port,
               user: user.user,
               rsa_pass_phrase: "invalid"
             )
  end
end
