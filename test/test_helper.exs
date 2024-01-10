# TODO Check if we need docker before building
require Logger
Logger.debug("Building docker image")
Docker.build!("shh-test", "test/support/docker")

unless Docker.ready?() do
  IO.puts("""
  It seems like Docker isn't available?

  Please check:

  1. Docker is installed: `docker version`
  2. Docker is running: `docker info`

  Learn more about Docker:
  https://www.docker.com/
  """)

  exit({:shutdown, 1})
end

ExUnit.start()
