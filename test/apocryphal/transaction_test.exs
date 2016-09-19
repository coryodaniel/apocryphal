defmodule ApocryphalTest.Transaction do
  use ExUnit.Case, async: true

  describe ".build when the response description is not present" do
    test "sets the description" do
      doc = %{"paths" =>
        %{ "/" => %{ "get" => %{ "responses" => %{ "200" => %{} } } } }
      }
      %{description: description} = Apocryphal.Transaction.build(doc, :get, "/", 200)
      assert description == "[GET] /"
    end
  end

  describe ".build" do
    test "building a transaction when a request has no body" do
      doc = Apocryphal.parse("test/support/pet_store.yml")
      %{request: request} = Apocryphal.Transaction.build(doc, :get, "/pets", 200)

      assert request == %{
        method: :get,
        uri: "/v1/pets",
        headers: [],
        body: nil
      }
    end

    test "building a transaction when a request has a body" do
      doc = Apocryphal.parse("test/support/pet_store.yml")
      %{request: request} = Apocryphal.Transaction.build(doc, :post, "/pets", 201)

      assert request == %{
        method: :post,
        uri: "/v1/pets",
        headers: [],
        body: %{}
      }
    end

    test "configures the expectation" do
      doc = Apocryphal.parse("test/support/pet_store.yml")
      %{expected: expected} = Apocryphal.Transaction.build(doc, :get, "/pets", 200)

      assert expected == %{
        status_code: 200,
        headers: [],
        schema: %{
          "additionalItems" => true,
          "type" => "array",
          "items" => %{
            "type" => "object",
            "properties" => %{
              "name" => %{
                "type" => "string"
              },
              "type" => %{
                "enum" => ["dog", "cat", "bird"]
              }
            },
            "required" => ["name", "type"]
          }
        }
      }
    end
  end
end
