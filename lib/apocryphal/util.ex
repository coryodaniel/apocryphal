defmodule Apocryphal.Util do
  def stringify_keys(nil), do: %{}
  def stringify_keys(map) when is_map(map) do
    Enum.reduce(
      Map.keys(map), %{},
      fn(k, acc) ->
        Map.put(acc, to_string(k), stringify_keys(map[k]))
      end
    )
  end
  def stringify_keys(value), do: value
end
