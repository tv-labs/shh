defmodule ShhTest do
  use ExUnit.Case, async: true
  doctest Shh

  test "raises on exec! with closed connection" do
    host = Shh.IntegrationCase.start_container!()

    conn =
      Shh.Conn.connect!(host.hostname,
        port: host.port,
        user: "pubkey_user",
        user_dir: "./test/support/docker"
      )

    assert Shh.exec!(conn, "/app/mixed_output.sh") == %Shh.Result{
             data: ["Normal: 1\nNormal: 2\n"],
             errors: ["Error: 1\nError: 2\n"],
             exit_status: 0
           }

    Docker.cmd!("stop", [host.id])

    assert_raise ErlangError, "Erlang error: :closed", fn ->
      Shh.exec!(conn, "/app/mixed_output.sh")
    end
  end
end
