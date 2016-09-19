defmodule ApocryphalTest.Unit do
  use ExUnit.Case, async: true

  @map_with_non_string_keys %{
    "this" => "that",
    :here => "there",
    200 => "OK"
  }

  describe ".stringify_keys" do
    test "stringifies a shallow map" do
      map = Apocryphal.Util.stringify_keys(@map_with_non_string_keys)
      assert map == %{
        "this" => "that",
        "here" => "there",
        "200" => "OK"
      }
    end

    test "stringifies a deep map" do
      deep_map = %{ "deep" => @map_with_non_string_keys }
      map = Apocryphal.Util.stringify_keys(deep_map)

      assert map == %{
        "deep" => %{
          "this" => "that",
          "here" => "there",
          "200" => "OK"
        }
      }
    end
  end
end
