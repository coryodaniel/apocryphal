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

  describe "when a swagger file is provided" do
    test "generates tests" do
      path = path_to_doc("simple.yml")

      in_tmp "generate tests", fn ->
        Mix.Tasks.Apocryphal.Gen.Test.run ["V1.Simple", "--swagger-file=#{path}"]

        assert_file "test/acceptance/v1/simple_test.exs", fn file ->
          assert file =~ "[GET] /pets (200)"
        end
      end
    end
  end

  describe "when a filtering API paths" do
    test "generates tests for applicable paths" do
      path = path_to_doc("pet_store.yml")

      in_tmp "generate tests", fn ->
        Mix.Tasks.Apocryphal.Gen.Test.run ["V1.Pets", "--only=^\/pets", "--swagger-file=#{path}"]

        assert_file "test/acceptance/v1/pets_test.exs", fn file ->
          assert file =~ "[GET] /pets (200)"
          refute file =~ "[GET] /stores (200)"
        end
      end
    end
  end
end
