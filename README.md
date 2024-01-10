# Shh 🤫🤫🤫

A friendly SSH client for Elixir

## Features
* Uses OTPs [:ssh module](https://www.erlang.org/doc/man/ssh)
* Concurrently run the same command on multiple hosts
* Concurrently run multiple commands, single host

## Example

``` elixir
iex> {:ok, conn} =
...>  Shh.connect("elixir-lang.org",
...>    port: 22,
...>    user: "José",
...>    user_dir: "./my_keys"
...>  )

iex> Shh.exec!(conn, "install_elixir.sh")
%Shh.Result{exit_status: 0, data: ["Success"]}
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `shh` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:shh, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/shh>.

