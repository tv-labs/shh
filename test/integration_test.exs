defmodule Shh.IntegrationTest do
  use Shh.IntegrationCase

  describe "connection methods" do
    test "it can connect with username and password", %{hosts: [host], password_user: user} do
      assert {:ok, _conn} =
               Shh.connect(host.hostname,
                 port: host.port,
                 user: user.user,
                 password: user.password
               )

      assert {:error, "Unable to connect using the available authentication methods"} =
               Shh.connect(host.hostname, port: host.port, user: user.user, password: "invalid")
    end

    test "it can connect with a public key", %{hosts: [host], pubkey_user: user} do
      assert {:ok, _conn} =
               Shh.connect(host.hostname,
                 port: host.port,
                 user: user.user,
                 user_dir: "./test/support/docker"
               )

      assert {:error, "Unable to connect using the available authentication methods"} =
               Shh.connect(host.hostname,
                 port: host.port,
                 user: user.user
               )
    end
  end

  describe "exec!/3" do
    @describetag user: :pubkey_user
    setup [:one_host, :connect_host]

    test "it can run commands and return the results", %{conn: conn} do
      assert Shh.exec!(conn, "cat /home/pubkey_user/world.txt") == %Shh.Result{
               data: ["hello_pubkey_user\n"]
             }
    end

    test "it can return errors", %{conn: conn} do
      assert Shh.exec!(conn, "cat /home/pubkey_user/nope.txt") == %Shh.Result{
               exit_status: 1,
               errors: [
                 "cat: can't open '/home/pubkey_user/nope.txt': No such file or directory\n"
               ]
             }
    end

    test "it can handle mixed output", %{conn: conn} do
      assert Shh.exec!(conn, "/app/mixed_output.sh") == %Shh.Result{
               data: ["Normal: 1\nNormal: 2\n"],
               errors: ["Error: 1\nError: 2\n"],
               exit_status: 0
             }
    end
  end

  defp one_host(%{hosts: hosts}) do
    %{host: List.first(hosts)}
  end

  defp connect_host(%{host: host, user: :pubkey_user}) do
    {:ok, conn} =
      Shh.connect(host.hostname,
        port: host.port,
        user: "pubkey_user",
        user_dir: "./test/support/docker"
      )

    %{conn: conn}
  end
end
