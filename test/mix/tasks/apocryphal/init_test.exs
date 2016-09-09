Code.require_file "../../mix_helper.exs", __DIR__

defmodule ApocryphalTest.Mix.Tasks.Apocryphal.Init do
  use ExUnit.Case
  import MixHelper

  setup do
    create_tmp_path
    on_exit &remove_tmp_path/0
    :ok
  end

  test "check folder" do
    dir = Path.join(tmp_path, "test/apocryphal")
    refute File.exists?(dir)
    File.cd! tmp_path, fn -> Mix.Tasks.Apocryphal.Init.run([]) end
    assert File.exists?(dir)
  end
end
