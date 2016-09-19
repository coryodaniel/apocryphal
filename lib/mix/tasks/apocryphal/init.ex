defmodule Mix.Tasks.Apocryphal.Init do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Create test/apocryphal"

  @moduledoc """
  Creates necessary files.

  This tasks creates `test/apocryphal`
  """

  def run(_args) do
    create_directory Apocryphal.dir

    #Mix.Project.config |> Keyword.fetch!(:app)

    #Application.get_env(app, :namespace, app)
  end
end
