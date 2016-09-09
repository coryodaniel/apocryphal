defmodule Apocryphal do
  @file_formats [
    {~r/y(a)?ml$/i, :yaml}
    # {~r/json/i, :json}
    # {~r/apib/i, :apib}
  ]

  def dir, do: "test/apocryphal"

  def parse(nil), do: raise ArgumentError, "A swagger documentation file is required"
  def parse(path) do
    {_, type} = Enum.find(@file_formats, {nil, :unknown}, fn {pattern, _type} ->
      String.match?(path, pattern)
    end)

    parse_file({type, path})
  end

  defp parse_file({:yaml, path}) do
    Application.ensure_all_started(:yaml_elixir)
    path |> File.read! |> YamlElixir.read_from_string
  end
  defp parse_file({:unknown, path}), do: raise RuntimeError, "Unsupported file type: #{path}"
end
