Mix.shell(Mix.Shell.Process)

defmodule MixHelper do
  import ExUnit.Assertions

  def path_to_doc(name) do
    "test/support" |> Path.join(name) |> Path.expand
  end

  def assert_file(file, match) do
    cond do
      is_list(match) ->
        assert_file file, &(Enum.each(match, fn(m) -> assert &1 =~ m end))
      is_binary(match) or Regex.regex?(match) ->
        assert_file file, &(assert &1 =~ match)
      is_function(match, 1) ->
        assert_file(file)
        match.(File.read!(file))
    end
  end

  def assert_file(name) do
    assert File.regular?(name)
  end

  def create_tmp_path do
    File.mkdir_p! tmp_path
  end

  def remove_tmp_path do
    File.rm_rf! tmp_path
  end

  def tmp_path do
    Path.expand("../tmp", __DIR__)
  end

  def in_tmp(which, function) do
    path = Path.join(tmp_path(), which)
    File.rm_rf! path
    File.mkdir_p! path
    File.cd! path, function
  end
end
