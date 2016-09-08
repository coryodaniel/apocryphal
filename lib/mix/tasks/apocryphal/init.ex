defmodule Mix.Tasks.Apocryphal.Init do
  use Mix.Task
  import Mix.Generator

  @preferred_cli_env :test
  @shortdoc "Create test/apocryphal"

  @moduledoc """
  Creates necessary files.

  This tasks creates `test/apocryphal`
  """

  @apocryphal_folder "test/apocryphal"

  def run(_args) do
    create_directory @apocryphal_folder
  end
end
