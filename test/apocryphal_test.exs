defmodule ApocryphalTest do
  use ExUnit.Case
  doctest Apocryphal

  @simple_api %{
    "swagger" => "2.0",
    "info" => %{
      "version" => "0.0.0",
      "title" => "Simple API"
    },
    "paths" => %{
      "/" => %{
        "get" => %{
          "responses" => %{
            200 => %{
              "description" => "Its a pretty simple API!"
            }
          }
        }
      }
    }
  }

  describe "given a YAML Swagger document" do
    test "parses the config to a map" do
      api = Apocryphal.parse("test/support/simple.yml")
      assert api == @simple_api
    end
  end

  describe "given a JSON Swagger document" do
    test "an exception is raised" do
      assert_raise RuntimeError, fn ->
        Apocryphal.parse("test/support/simple.json")
      end
    end
  end
end
