require IEx
defmodule Apocryphal.Case do
  defmacro __using__(options) do
    quote do
      import Apocryphal.Case
      use ExUnit.Case, unquote(options)
    end
  end

  defmacro verify(desc, path, http_method, func) do
    IEx.pry
    # IO.puts func.("hi")

    quote do
      IO.puts unquote(desc)
    end

    # documentation = Module.get_attribute(__MODULE__, :documentation)
    # ExUnit.Case.test(desc, fn ->
    #   ExUnit.Assertions.assert true == false
    # end)
  end

  defmacro verify(path, http_method, func) do
    verify(path, path, http_method, func)
  end

  # def verify(path, http_method, func) do
  #   ExUnit.Case.test(path, fn ->
  #     ExUnit.Assertions.assert true == false
  #   end)
  # end

  # defmacro verify(desc, path, http_method, body) do
  #   IO.puts desc
  # end

  # full_message = ExSpec.Helpers.full_message(__MODULE__, unquote(message))
  #
  # ExUnit.Case.test(full_message, unquote(var), unquote(body))
  #end
end
