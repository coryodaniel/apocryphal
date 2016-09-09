Code.require_file "../../../mix_helper.exs", __DIR__
defmodule ApocryphalTest.Mix.Tasks.Apocryphal.Gen.Test do
  use ExUnit.Case
  import MixHelper

  setup do
    remove_tmp_path
    create_tmp_path
    on_exit &remove_tmp_path/0
    :ok
  end

  describe "when no swagger file is provided" do
    test "outputs usage instructions" do
      assert_raise Mix.Error, ~r/expects a module name and a swagger file/, fn ->
        Mix.Tasks.Apocryphal.Gen.Test.run ["V1.MyAPI"]
      end
    end
  end

  describe "when a swagger file is provided" do
    test "generates tests" do
      path = path_to_doc("simple.yml")

      in_tmp "generate tests", fn ->
        Mix.Tasks.Apocryphal.Gen.Test.run ["V1.Simple", "--swagger-file=#{path}"]

        assert_file "test/apocryphal/v1/simple_test.exs", fn file ->
          assert file =~ ~s(verify "Its a pretty simple API!", "/", :get)
        end
      end
    end
  end

  describe "when a filtering API paths" do
    test "generates tests for applicable paths" do
      path = path_to_doc("pet_store.yml")

      in_tmp "generate tests", fn ->
        Mix.Tasks.Apocryphal.Gen.Test.run ["V1.Pets", "--only=^\/pets", "--swagger-file=#{path}"]

        assert_file "test/apocryphal/v1/pets_test.exs", fn file ->
          assert file =~ ~s(verify "List all pets", "/v1/pets", :get)
          refute file =~ ~s(List of stores)
          refute file =~ ~s("/stores")
        end
      end
    end
  end

end