defmodule <%= module %>Test do
  use Apocryphal.Case
  @documentation "<%= doc %>"

<%= for {path, path_doc} <- paths do %>
<%= for {http_method, operation_doc} <- path_doc do %>
<%= for {http_status, response_doc} <- operation_doc["responses"], !Regex.match?(~r/default/i, "#{http_status}") do %>
  <%= if response_doc["description"], do: "# #{response_doc["description"]}" %>
  # [<%= String.upcase(http_method) %>] <%= meta["basePath"] %><%= path %>
  verify <%= if response_doc["description"], do: ~s("#{response_doc["description"]}",) %> "<%= meta["basePath"] %><%= path %>", :<%= String.downcase(http_method) %>, fn(transaction) ->
    # You can modify the default request before it is made
    #     transaction.request
    #
    # Injecting authorization
    #     changeset = User.changeset(%User{}, %{name: "Chauncy"})
    #     {:ok, user} = Repo.insert(changeset)
    #     bearer = "Bearer my-cool-secure-bearer"
    #     transaction = put_in(transaction, [:request, :age, "Authorization"], bearer)
    #
    # Changing the URI, defaults to interpolating Swagger docs example into Path templates
    # i.e.: /pets/{id} => /pets/3
    #     transaction = put_in(transaction, [:request, :uri], "/pets/9001")

    # Injecting a request body, defaults to the Swagger docs response example
    #     transaction = put_in(transaction, [:body], %{...my JSON body...})

    # You can modify what is to be asserted, defaults to testing the response against the JSON Schema
    #     transaction.expected

    # Changing the expectation to match the example
    #     transaction = ... :/

    # The meta data from the Swagger doc
    #     transaction.meta

    # Useful for debugging
    #     put_in(transaction, [:inspect], fn(transaction) -> IEx.pry end)

    # Return the modified transaction for testing
    transaction
  end
<% end %>
<% end %>
<% end %>
end
