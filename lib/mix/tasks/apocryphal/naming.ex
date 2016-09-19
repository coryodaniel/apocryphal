defmodule Mix.Tasks.Apocryphal.Naming do
  def inflect(singular) do
    base     = "Apocryphal"
    scoped   = Macro.camelize(singular)
    path     = Macro.underscore(scoped)
    singular = path |> String.split("/") |> List.last
    module   = base |> Module.concat(scoped) |> inspect
    alias    = module |> String.split(".") |> List.last

    [app: app_name,
     alias: alias,
     base: base,
     module: module,
     scoped: scoped,
     singular: singular,
     path: path]
  end

  def app_name do
    app = Mix.Project.config |> Keyword.fetch!(:app)
    case Application.get_env(app, :namespace, app) do
      ^app -> app |> to_string |> Macro.camelize
      mod  -> mod |> inspect
    end
  end
end
