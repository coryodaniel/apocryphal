defmodule ApocryphalTest.Mix.Tasks.Apocryphal.Init do
  use ExUnit.Case

  @tmp_path Path.join(__DIR__, "tmp")

  def clear, do: File.rm_rf! @tmp_path

  setup do
    Mix.shell(Mix.Shell.Process) # Get Mix output sent to the current process to avoid polluting tests.
    File.mkdir_p! @tmp_path
    File.cd! @tmp_path, fn -> Mix.Tasks.Apocryphal.Init.run([]) end
    on_exit(&clear/0)
    :ok
  end

  test "check folder" do
    assert File.exists?(Path.join(@tmp_path, "test/apocryphal"))
  end
end
