defmodule Apocryphal do
  def dir, do: "test/acceptance"

  @doc"""
  Get the full URL of the server under test.

  ## Example
        config :apocryphal,
          port: 4001,
          host: "localhost"
  """
  @spec url(String.t) :: String.t
  def url(path) do
    host = Application.get_env(:apocryphal, :host)
    port = Application.get_env(:apocryphal, :port)
    url(host, port, path)
  end
  def url(nil, _, _), do: raise "Apocryphal host not set"
  def url(_, nil, _), do: raise "Apocryphal port not set"
  def url(host, port, path), do: "http://#{host}:#{port}#{path}"

  @doc"""
  Serializes an HTTP Body

  ## Example
        config :apocryphal,
          serializers: %{
            "application/json" => fn(body) -> Poison.encode!(body) end
          }
  """
  @spec serialize(Map.t | List.t, String.t) :: String.t
  def serialize(body, mime \\ nil) do
    Application.get_env(:apocryphal, :serializers)[mime].(body)
  end

  @doc"""
  Deserializes an HTTP Response

  ## Example
        config :apocryphal,
          deserializers: %{
            "application/json" => fn(body) -> Poison.decode!(body) end
          }
  """
  @spec deserialize(Map.t | List.t, String.t) :: String.t
  def deserialize(body, mime) do
    Application.get_env(:apocryphal, :deserializers)[mime].(body)
  end

  @doc"""
  ## Examples
      iex> Apocryphal.parse("http://example.com/path/to/v1.yaml")

      iex> Apocryphal.parse("http://example.com/path/to/v1.json")
  """
  @spec parse(String.t) :: Map.t
  def parse("http" <> _rest = url) do
    text = HTTPoison.get!(url).body
    ext = Path.extname(url)
    do_parse(text, ext)
  end

  @doc"""
  ## Examples
      iex> Apocryphal.parse("./path/to/v1.yaml")

      iex> Apocryphal.parse("./path/to/v1.json")
  """
  @spec parse(String.t) :: Map.t
  def parse(path) when is_binary(path) do
    ext = Path.extname(path)

    path
    |> File.read!
    |> do_parse(ext)
  end

  defp do_parse(text, ext) do
    case ext do
      ".yml"  -> parse_yaml(text)
      ".yaml" -> parse_yaml(text)
      ".json" -> parse_json(text)
      _ -> raise RuntimeError, "Unsupported file type: #{ext}"
    end
  end

  defp parse_json(text), do: text |> Poison.decode! |> expand

  defp parse_yaml(text) do
    Application.ensure_all_started(:yaml_elixir)
    text
    |> YamlElixir.read_from_string
    |> Apocryphal.Util.stringify_keys
    |> expand
  end

  def expand(map) do
    swagger = ExJsonSchema.Schema.resolve(map)
    expand(swagger, swagger.schema)
  end

  defp expand(swagger, %{"$ref" => ref_schema} = schema) when is_map(schema) do
    ref = ExJsonSchema.Schema.get_ref_schema(swagger, ref_schema)

    schema
    |> Map.delete("$ref")
    |> Map.merge(expand(swagger, ref))
  end

  defp expand(swagger, schema) when is_map(schema) do
    Enum.reduce(
      Map.keys(schema), %{},
      fn(k, acc) ->
        Map.put(acc, k, expand(swagger, schema[k]))
      end
    )
  end

  defp expand(swagger, list) when is_list(list) do
    Enum.map list, fn(item) -> expand(swagger, item) end
  end

  defp expand(_, value), do: value
end
