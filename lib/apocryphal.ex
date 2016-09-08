require IEx
defmodule Apocryphal do
  @file_formats [
    {~r/y(a)?ml$/i, :yaml}
    # {~r/json/i, :json}
    # {~r/apib/i, :apib}
  ]

  def parse(path) do
    {_, type} = Enum.find(@file_formats, {nil, :unknown}, fn {pattern, _type} ->
      String.match?(path, pattern)
    end)

    parse_file({type, path})
  end

  defp parse_file({:yaml, path}), do: path |> read_file |> YamlElixir.read_from_string
  # defp parse_file({:json, path}), do: path |> read_file |> Poison.decode!
  defp parse_file({:unknown, path}), do: raise "Unsupported file type: #{path}"

  defp read_file(path) do
    {:ok, string} = File.read(path)
    string
  end

end
