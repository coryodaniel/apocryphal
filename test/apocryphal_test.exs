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
              "description" => "OK"
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

  # describe "when something is doing something" do
  #   setup [:some_setup_method, :some_other_setup_method]
  #
  #   test ...
  # end
  #
  # describe "when something is doing something else" do
  #   setup [:some_setup_method, :some_other_setup_method]
  #
  #   test ...
  # end
  #
  # defp some_setup_method(context) do
  #   # ...
  # end

  # import Mock
  # test "test_name" do
  #   with_mock HTTPotion, [get: fn(_url) -> "<html></html>" end] do
  #     HTTPotion.get("http://example.com")
  #     # Tests that make the expected call
  #     assert called HTTPotion.get("http://example.com")
  #   end
  # end
end
