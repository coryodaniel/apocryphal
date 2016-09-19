defmodule Apocryphal.Assertions do
  import ExUnit.Case
  import ExUnit.Assertions

  def assert_schema(transaction) when is_map(transaction) do
    %{request: request, expected: expected} = transaction

    response = Apocryphal.Transaction.dispatch(transaction)

    assert response.status_code == expected.status_code

    response_body = if response.body do
      Apocryphal.Transaction.parse_body(response)
    else
      %{}
    end

    assert :ok == ExJsonSchema.Validator.validate(expected.schema, response_body)
  end
end
