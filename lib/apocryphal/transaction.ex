defmodule Apocryphal.Transaction do
  @http_methods [:get, :post, :put, :patch, :delete, :options, :connect, :trace, :head]

  def describe(verb, path, http_status) do
    "[#{String.upcase(~s(#{verb}))}] #{path} (#{http_status})"
  end

  for verb <- @http_methods do
    @doc"""
    Create a transaction for this request type
    """
    defmacro unquote(verb)(swagger, path, expected_status, mime) do
      verb = unquote(verb)
      quote bind_quoted: binding() do
        Apocryphal.Transaction.build(swagger, verb, path, expected_status, mime)
      end
    end
  end

  def set_path_param(transaction, key, value) do
    new_path = Regex.replace(~r/\{#{key}\}/, transaction.request.path, "#{value}")
    put_in(transaction, [:request, :path], new_path)
  end

  def replace_path_params(path, params) do
    Enum.reduce params, path, fn({key,value}, acc) ->
      Regex.replace(~r/\{#{key}\}/, acc, "#{value}")
    end
  end

  def dispatch(%{request: request, mime: mime} = transaction) do
    url = request.path
          |> replace_path_params(request.path_params)
          |> Apocryphal.url

    %{headers: headers, params: params, body: body} = request

    body = cond do
      body != %{} -> Apocryphal.serialize(body, mime)
      true -> ""
    end

    headers = add_content_type_header(headers, body, mime)

    response = request.method
               |> HTTPoison.request!(url, body, headers, params: params)
               |> Apocryphal.Response.build

    transaction
    |> put_in([:response], response)
  end

  def build(swagger, verb, path, http_status, mime) when is_binary(swagger) do
    swagger
    |> Apocryphal.parse
    |> Apocryphal.Transaction.build(verb, path, http_status, mime)
  end

  def build(swagger, verb, path, http_status, mime) do
    full_path = "#{swagger["basePath"]}#{path}"
    operation_description = describe(verb, full_path, http_status)

    operation = get_in(swagger, ["paths", path, ~s(#{verb})])

    if is_nil(operation), do: raise ArgumentError, "no operation defined in swagger docs for #{operation_description}"

    _parameters = operation["parameters"]
    status = ~s(#{http_status})

    response = operation["responses"][status]

    if is_nil(response), do: raise ArgumentError, "no response defined in swagger docs for #{operation_description}"

    request = %{
      method: verb,
      path: full_path,
      headers: [{"accept", mime}],
      params: [],
      path_params: %{},
      body: %{}
    }

    expected = %{
      status_code: http_status,
      headers: [],
      schema: Map.get(response, "schema")
    }

    %{
      description: response["description"] || operation_description,
      expected: expected,
      request: request,
      mime: mime
    }
  end

  def add_request_header(transaction, header) do
    transaction
    |> put_in([:request, :headers], [header | transaction.request.headers])
  end

  def extract_mime_from_content_type(headers) do
    content_type = headers
    |> Enum.into(%{})
    |> Map.get("content-type")

    if content_type do
      content_type
      |> String.split(";")
      |> List.first
    else
      nil
    end
  end

  defp add_content_type_header(headers, body, mime) do
    if extract_mime_from_content_type(headers) == nil && body != "" && body != nil && body != %{} do
      headers ++ [{"content-type", mime}]
    else
      headers
    end
  end
end
