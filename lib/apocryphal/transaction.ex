defmodule Apocryphal.Transaction do
  @http_methods [:get, :post, :put, :patch, :delete, :options, :connect, :trace, :head]

  for verb <- @http_methods do
    @doc """
    Create a transaction for this request type
    """
    defmacro unquote(verb)(swagger, path, expected_status, mime) do
      verb = unquote(verb)
      quote bind_quoted: binding() do
        swagger
          |> Apocryphal.parse
          |> Apocryphal.Transaction.build(verb, path, expected_status, mime)
      end
    end
  end

  def replace_path_params(path, params) do
    Enum.reduce params, path, fn({key,value}, acc) ->
      Regex.replace(~r/\{#{key}\}/, acc, "#{value}")
    end
  end

  def dispatch(%{request: request, mime: mime}) do
    path =  replace_path_params(request.path, request.path_params)

    url = Apocryphal.url(path)
    %{headers: headers, params: params, body: body} = request

    body = cond do
      body != %{} -> Apocryphal.serialize(body, mime)
      true -> ""
    end

    headers = add_content_type_header(headers, body, mime)

    {:ok, resp} = HTTPoison.request(request.method, url, body, headers, params: params)
    resp
  end

  def parse_body(%{body: body, headers: headers}) do
    mime = Apocryphal.Transaction.extract_mime_from_content_type(headers)
    Apocryphal.deserialize(body, mime)
  end

  def build(swagger, verb, path, http_status, mime) do
    operation = get_in(swagger, ["paths", path, ~s(#{verb})])
    parameters = operation["parameters"]

    status = ~s(#{http_status})
    %{^status => response} = operation["responses"]
    full_path = "#{swagger["basePath"]}#{path}"

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
      description: response["description"] || describe(verb, full_path, http_status),
      expected: expected,
      request: request,
      mime: mime
    }
  end

  def describe(verb, path, http_status) do
    "[#{String.upcase(~s(#{verb}))}] #{path} (#{http_status})"
  end

  def extract_mime_from_content_type(headers) do
    content_type = headers
      |> Enum.into(%{})
      |> Map.get("content-type")

    if content_type do
      content_type |> String.split(";") |> List.first
    else
      nil
    end
  end

  def add_content_type_header(headers, body, mime) do
    if extract_mime_from_content_type(headers) == nil && body != "" && body != nil && body != %{} do
      headers ++ [{"content-type", mime}]
    else
      headers
    end
  end
end
