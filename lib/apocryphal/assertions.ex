defmodule Apocryphal.Assertions do
  import ExUnit.Assertions

  def assert_schema(%{expected: expected, response: response} = transaction) do
    assert response.status_code == expected.status_code
    assert :ok == ExJsonSchema.Validator.validate(expected.schema, response.body)
  end

  def assert_schema(transaction) do
    transaction
    |> Apocryphal.Transaction.dispatch
    |> assert_schema
  end
end
