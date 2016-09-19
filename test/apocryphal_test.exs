defmodule ApocryphalTest do
  use ExUnit.Case

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

  describe "parse/1" do
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

  describe "serialize/2" do
    test "serializes the payload" do
      payload = %{name: "Chauncy"}
      mime = "application/json"

      Application.put_env(:apocryphal, :serializers, %{
        mime => &Poison.encode!/1
      })

      assert Apocryphal.serialize(payload, "application/json") == ~s({"name":"Chauncy"})
    end
  end

  describe "deserialize/2" do
    test "deserializes the payload" do
      payload = ~s({"name":"Chauncy"})
      mime = "application/json"

      Application.put_env(:apocryphal, :deserializers, %{
        mime => &Poison.decode!/1
      })

      assert Apocryphal.deserialize(payload, "application/json") == %{"name" => "Chauncy"}
    end
  end

  describe "url/1" do
    test "returns a URL" do
      Application.put_env(:apocryphal, :host, "example.com")
      Application.put_env(:apocryphal, :port, 4000)
      assert "http://example.com:4000/kittens" == Apocryphal.url("/kittens")
    end

    test "raises an error when the 'port' is not set" do
      Application.put_env(:apocryphal, :host, "example.com")
      Application.put_env(:apocryphal, :port, nil)
      assert_raise RuntimeError, ~r/port not set/, fn ->
        Apocryphal.url("/kittens")
      end

    end

    test "raises an error when the 'host' is not set" do
      Application.put_env(:apocryphal, :port, 4000)
      Application.put_env(:apocryphal, :host, nil)
      assert_raise RuntimeError, ~r/host not set/, fn ->
        Apocryphal.url("/kittens")
      end
    end
  end

  describe "expand/1" do
    test "expands JSON Schema references" do
      doc = Apocryphal.parse("test/support/pet_store.yml")
      resolved = Apocryphal.expand(doc)

      resolved_schema = resolved["paths"]["/pets/{id}"]["get"]["responses"]["200"]["schema"]
      referenced_schema = doc["definitions"]["Pet"]
      assert resolved_schema == referenced_schema
    end
  end
end
