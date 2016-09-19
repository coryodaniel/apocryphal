defmodule Mix.Tasks.Apocryphal.Init do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Create test/apocryphal"

  @moduledoc """
  This tasks creates:
    `test/apocryphal`
    `test/apocryphal/example.txt`
    `test/support/apocryphal_case.ex`
  """

  def run(_args) do
    create_directory Apocryphal.dir

    generate_case

    # notify
    # test.exs
    # endpoint.exs
  end

  defp generate_case do
    source = :apocryphal
      |> Application.app_dir
      |> Path.join("priv/templates/case.exs")

    binding = [app: Mix.Tasks.Apocryphal.Naming.app_name]
    contents = EEx.eval_file(source, binding, trim: true)
    Mix.Generator.create_file("test/support/apocryphal_case.ex", contents)
  end
end
