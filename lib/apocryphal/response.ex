defmodule Apocryphal.Response do
  defstruct body: nil, headers: [], status_code: nil

  def build(%HTTPoison.Response{body: body, headers: headers, status_code: status_code}) do
    mime = Apocryphal.Transaction.extract_mime_from_content_type(headers)

    %Apocryphal.Response{
      headers: headers,
      status_code: status_code,
      body: parse_body(body, mime)
    }
  end

  defp parse_body(body, mime) do
    case body do
      "" -> nil
      nil -> nil
      body -> Apocryphal.deserialize(body, mime)
    end
  end
end
