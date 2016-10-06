defmodule ApocryphalTest.Transaction do
  use ExUnit.Case, async: true

  describe "dispatch/1" do
    test ""
  end

  describe "replace_path_params/2" do
    test "replacing a single parameter" do
      path = Apocryphal.Transaction.replace_path_params("/users/{id}", %{"id" => "3"})
      assert path == "/users/3"
    end

    test "replacing multiple parameters" do
      params = %{"id" => "3", "account_id" => "1337"}
      path = Apocryphal.Transaction.replace_path_params("/users/{id}/account/{account_id}", params)
      assert path == "/users/3/account/1337"
    end
  end

  describe "get/4" do
    test "builds a GET transaction" do
      require Apocryphal.Transaction
      doc = "test/support/pet_store.yml"
      transaction = Apocryphal.Transaction.get(doc, "/stores", 200, "application/json")

      assert transaction.expected.status_code == 200
      assert transaction.request.method == :get
      assert transaction.description == "List of stores"
    end
  end

  describe "build/5" do
    test "given a swagger doc path, parses the document first" do
      %{request: request} = Apocryphal.Transaction.build("test/support/pet_store.yml", :get, "/pets", 200, "application/json")

      assert request == %{
        method: :get,
        path: "/v1/pets",
        headers: [{"accept", "application/json"}],
        params: [],
        path_params: %{},
        body: %{}
      }
    end

    test "when the response description is not present sets the description" do
      doc = %{"paths" =>
        %{ "/" => %{ "get" => %{ "responses" => %{ "200" => %{} } } } }
      }
      %{description: description} = Apocryphal.Transaction.build(doc, :get, "/", 200, "application/json")
      assert description == "[GET] / (200)"
    end

    test "builds an HTTP request" do
      doc = Apocryphal.parse("test/support/pet_store.yml")
      %{request: request} = Apocryphal.Transaction.build(doc, :get, "/pets", 200, "application/json")

      assert request == %{
        method: :get,
        path: "/v1/pets",
        headers: [{"accept", "application/json"}],
        params: [],
        path_params: %{},
        body: %{}
      }
    end

    test "configures the expectation" do
      doc = Apocryphal.parse("test/support/pet_store.yml")
      %{expected: expected} = Apocryphal.Transaction.build(doc, :get, "/pets", 200, "application/json")

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
