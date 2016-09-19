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
            "200" => %{
              "description" => "Its a pretty simple API!"
            }
          }
        }
      }
    }
  }

  describe ".parse" do
    test "given a YML file parses the config to a map" do
      api = Apocryphal.parse("test/support/simple.yml")
      assert api == @simple_api
    end

    test "given a JSON file parses the config to a map" do
      api = Apocryphal.parse("test/support/simple.json")
      assert api == @simple_api
    end

    test "given another file type an exception is raised" do
      assert_raise RuntimeError, fn ->
        Apocryphal.parse("test/support/simple.txt")
      end
    end
  end

  describe ".expand" do
    test "expands JSON Schema references" do
      doc = Apocryphal.parse("test/support/pet_store.yml")
      resolved = Apocryphal.expand(doc)

      resolved_schema = resolved["paths"]["/pets/{id}"]["get"]["responses"]["200"]["schema"]
      referenced_schema = doc["definitions"]["Pet"]
      assert resolved_schema == referenced_schema
    end
  end
end
