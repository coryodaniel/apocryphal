Code.require_file "../../mix_helper.exs", __DIR__

defmodule ApocryphalTest.Mix.Tasks.Apocryphal.Init do
  use ExUnit.Case
  import MixHelper

  setup do
    create_tmp_path
    on_exit &remove_tmp_path/0
    :ok
  end

  test "creates test/apocryphal directory" do
    dir = Path.join(tmp_path, "test/apocryphal")
    refute File.exists?(dir)
    File.cd! tmp_path, fn -> Mix.Tasks.Apocryphal.Init.run([]) end
    assert File.exists?(dir)
  end

  test "creates test/support/apocryphal_case.ex" do
    dir = Path.join(tmp_path, "test/support/apocryphal_case.ex")
    refute File.exists?(dir)
    File.cd! tmp_path, fn -> Mix.Tasks.Apocryphal.Init.run([]) end
    assert File.exists?(dir)    
  end
end
