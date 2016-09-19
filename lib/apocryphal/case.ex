defmodule Apocryphal.DSL do
  import ExUnit.Case
  import ExUnit.Assertions

  def get_url(path) do
    host = Application.get_env(:apocryphal, :host)
    port = Application.get_env(:apocryphal, :port)
    "http://#{host}:#{port}#{path}"
  end

  def assert_schema(%{request: request, expected: expected} = transaction) do
    response = dispatch(request)

    assert response.status_code == expected.status_code

    response_body = if response.body do
      parse_body(response)
    else
      %{}
    end

    assert :ok == ExJsonSchema.Validator.validate(expected.schema, response_body)
  end

  def dispatch(request) do
    url = get_url(request.uri)
    %{headers: headers, params: params, body: body} = request

    body = cond do
      body != %{} ->
        mime = extract_mime_from_content_type(headers)
        Apocryphal.serialize(body, mime)
      true -> ""
    end

    {:ok, resp} = HTTPoison.request(request.method, url, body, headers, params: params)
    resp
  end

  defmacro verify(verb, path, http_status, config \\ nil) do
    quote bind_quoted: binding() do
      transaction = Apocryphal.Transaction.create(
        Module.get_attribute(__MODULE__, :swagger),
        Module.get_attribute(__MODULE__, :mime),
        verb,
        path,
        http_status,
        fn(x) -> x end
      )

      Apocryphal.Registry.put(transaction.description, config || fn(x) -> x end)
      Module.put_attribute __MODULE__, :apocryphal_transaction, transaction
      Module.put_attribute __MODULE__, :apocryphal_transaction, transaction

      test(transaction.description, tags) do
        func = Apocryphal.Registry.get(@apocryphal_transaction.description)
        func.(@apocryphal_transaction)
          |> Apocryphal.Transaction.add_content_type_header(@mime)
          |> assert_schema
      end
    end
  end

  def extract_mime_from_content_type(headers) do
    headers
      |> Enum.into(%{})
      |> Map.get("content-type")
      |> String.split(";")
      |> List.first
  end

  def parse_body(%{body: body, headers: headers} = response) do
    mime = extract_mime_from_content_type(headers)
    Apocryphal.deserialize(response.body, mime)
  end

  defmacro xverify(verb, path, http_status, config \\ nil) do
    quote bind_quoted: binding() do
      transaction = Apocryphal.Transaction.create(
        Module.get_attribute(__MODULE__, :swagger),
        Module.get_attribute(__MODULE__, :mime),
        verb,
        path,
        http_status,
        config || fn(x) -> x end
      )
      IO.puts "Skipping #{transaction.description}"
    end
  end
end
