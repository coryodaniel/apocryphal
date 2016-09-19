defmodule Apocryphal.Transaction do
  def build(swagger, verb, path, http_status) do
    operation = get_in(swagger, ["paths", path, ~s(#{verb})])
    parameters = operation["parameters"]
    response = Map.get(operation["responses"], ~s(#{http_status}))
    # TODO: TBD raise error if status not found...
    full_path = "#{swagger["basePath"]}#{path}"

    request = %{
      method: verb,
      uri: full_path,
      headers: [],
      params: [],
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
      request: request
    }
  end

  def create(swagger, mime, verb, path, http_status, config \\ nil) do
    config = config || fn(x) -> x end
    swagger
      |> Apocryphal.parse
      |> build(verb, path, http_status)
      |> add_accept_header(mime)
      |> config.()
      |> add_content_type_header(mime)
  end

  def describe(verb, path, http_status) do
    "[#{String.upcase(~s(#{verb}))}] #{path} (#{http_status})"
  end

  def add_accept_header(transaction, mime) do
    transaction |> put_in([:request, :headers], [{"accept", mime}])
  end

  def add_content_type_header(%{ request: %{ body: body, headers: headers } } = transaction, mime) do
    if headers[:"content-type"] == nil && body != "" && body != nil && body != %{} do
      transaction |> put_in([:request, :headers], [{"content-type", mime}])
    else
      transaction
    end
  end
end
