defmodule Mix.Tasks.Apocryphal.Gen.Test do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generate apocryphal tests from a Swagger document"

  @moduledoc """
  Generate apocryphal tests from a Swagger document

  Parse swagger documentation into ExUnit tests

      mix apocryphal.gen.test V1.Pets --only=^\/pets --swagger-file=./docs/pet_store.yaml
      mix apocryphal.gen.test V1.Stores --only=^\/stores --swagger-file=./docs/pet_store.yaml


  "One big ass file" mode:

      mix apocryphal.gen.test V1.PetAPI --swagger-file=./docs/pet_store.yml

  """
  def run(args) do
    Mix.Task.run "apocryphal.init"
    switches = [swagger_file: :string, only: :string]
    {opts, parsed, _} = OptionParser.parse(args,
      switches: switches,
      aliases: [s: :swagger_file]
    )

    [test_module_name | _] = validate_args!(parsed)

    api = try do
      Apocryphal.parse(opts[:swagger_file])
    rescue
      ArgumentError -> raise_with_help
      RuntimeError -> raise_with_help
    end

    binding = inflect(test_module_name) ++ [
      doc:   opts[:swagger_file],
      meta:  Map.delete(api, "paths"),
      paths: filter_paths(api["paths"], opts[:only])
    ]

    check_module_name_availability! binding[:module]
    generate_file(binding)
  end

  defp generate_file(binding) do
    source = :apocryphal
      |> Application.app_dir
      |> Path.join("priv/templates/test.exs")

    contents = EEx.eval_file(source, binding, trim: true)
    target   = Path.join(Apocryphal.dir, "#{binding[:path]}_test.exs")

    Mix.Generator.create_file(target, contents)
  end

  defp inflect(singular) do
    base     = "Apocryphal"
    scoped   = Macro.camelize(singular)
    path     = Macro.underscore(scoped)
    singular = path |> String.split("/") |> List.last
    module   = base |> Module.concat(scoped) |> inspect
    alias    = module |> String.split(".") |> List.last

    [alias: alias,
     base: base,
     module: module,
     scoped: scoped,
     singular: singular,
     path: path]
  end

  # TBD?
  defp validate_args!(args) do
    args
  end

  defp validate_args!([]) do
    raise_with_help()
  end

  @spec raise_with_help() :: no_return()
  defp raise_with_help do
    Mix.raise """
    mix apocryphal.gen.test expects a module name and a swagger file to generate tests into:
        mix apocryphal.gen.test V1.Pets -s ./docs/pets_api.yml
    """
  end

  defp check_module_name_availability!(name) do
    name = Module.concat(Elixir, name)
    if Code.ensure_loaded?(name) do
      Mix.raise "Module name #{inspect name} is already taken, please choose another name"
    end
  end

  defp filter_paths(paths, pattern) do
    filter_pattern = Regex.compile!(pattern || "")

    for {path, path_doc} <- paths,
      Regex.match?(filter_pattern, path),
      into: %{},
      do: {path, path_doc}
  end
end
