defmodule <%= module %>Test do
  use Apocryphal.Case, async: true

  # Example:
  # verify "docs/v1.yml", "application/json" do
  #   get "List all pets", "/pets", :get,, 200
  #   get "Find a pet by ID", "/pets/{id}", :get, 200, fn(transaction) ->
  #     # You can modify the default request before it is made
  #     #     transaction.request
  #
  #     # Injecting authorization
  #     #     changeset = User.changeset(%User{}, %{name: "Chauncy"})
  #     #     {:ok, user} = Repo.insert(changeset)
  #     #     bearer = "Bearer my-cool-secure-bearer"
  #     #     transaction = put_in(transaction, [:request, :age, "Authorization"], bearer)
  #     #
  #     # Changing the URI, defaults to interpolating Swagger docs example into Path templates
  #     # i.e.: /pets/{id} => /pets/3
  #     #     transaction = put_in(transaction, [:request, :uri], "/pets/9001")
  #
  #     # Injecting a request body, defaults to the Swagger docs response example
  #     #     transaction = put_in(transaction, [:body], %{...my JSON body...})
  #
  #     # You can modify what is to be asserted, defaults to testing the response against the JSON Schema
  #     #     transaction.expected
  #
  #     # Changing the expectation to match the example
  #     #     transaction = ... :/
  #
  #     # Additional assertions
  #     #     put_in(transaction, [:assertions], [fn(response) -> IEx.pry end])
  #
  #     # Return the modified transaction for testing
  #     transaction
  #   end
  # end

<%= if api["basePath"], do: ~s(  # Base Path: #{api["basePath"]}) %>
<%= for mime <- consumes do %>
  verify "<%= doc %>", "<%= mime %>" do<%= for {path, path_item} <- paths do %><%= for {verb, operations} <- path_item do %><%= for {http_status, responses} <- operations["responses"] do %>

    <%= verb %> "<%= path %>", <%= http_status %>, fn(transaction) ->
      transaction
    end<% end %><% end %><% end %>
  end
<% end %>
end
