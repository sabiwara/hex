defmodule Mix.Tasks.Hex.Update do
  use Mix.Task
  alias Mix.Tasks.Hex.Util

  @install_url "http://s3.hex.pm/installs/hex.ez"

  @shortdoc "Update hex"

  @moduledoc """
  Update the hex installation or registry file.

  `mix hex.update`

  Updating the registry should be done periodically. The registry status can be
  checked with `mix hex.info`. The registry contains an index of all packages,
  releases and their dependencies that is used during Hex's dependency
  resolution.

  If the command line option `--system` is supplied

  ## Command line options

  * `--system` - Update the hex installation
  """

  def run(args) do
    { opts, _, _ } = OptionParser.parse(args)
    Hex.start_api

    # TODO: Check /api/installs for url
    if opts[:system] do
      Mix.shell.info("Updating Hex installation...")
      Mix.Task.run "local.install", [@install_url, "--force"]
      Mix.shell.info("Updating Hex was successful!")
    end

    Mix.shell.info("Downloading registry...")

    case Hex.API.get_registry do
      { 200, body } ->
        data = :zlib.gunzip(body)
        File.write!(Hex.Registry.path, data)
        Mix.shell.info("Registry update was successful!")
      { code, body } ->
        Mix.shell.error("Registry update failed! (#{code})")
        Util.print_error_result(code, body)
    end
  end
end
