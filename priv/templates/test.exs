defmodule <%= app %>Test.<%= module %> do
  use Apocryphal.Case, async: true

  # Example:
  # alias PetStore.Pet
  # alias PetStore.Store
  #
  # @swagger "./docs/pet_store.yml"
  # @mime "application/json"
  #
  # test "List of stores" do
  #   %Store{ address: "123 Ship St.",
  #           city: "Los Angeles",
  #           state: "CA",
  #           postal_code: "90210" } |> Repo.insert!
  #
  #   # assert_schema/1 will dispatch the transaction if a request isn't
  #   # present, or it can be manually dispatched
  #
  #   @swagger
  #   |> Apocryphal.Transaction.get("/stores", 200, @mime)
  #   |> Apocryphal.Transaction.dispatch
  #   |> assert_schema
  # end
  #
  # test "[GET] /pets (200)" do
  #   %Pet{ name: "Chauncy", type: "dog" } |> Repo.insert!
  #
  #   @swagger
  #   |> Apocryphal.Transaction.get("/pets", 200, @mime)
  #   |> put_in([:request, :params], [limit: 20])
  #   |> assert_schema
  # end
  #
  # test "[POST] /pets (201)" do
  #   pet_params = %{ pet: %{ name: "Chuancy", type: "cat" } }
  #
  #   @swagger
  #   |> Apocryphal.Transaction.post("/pets", 201, @mime)
  #   |> put_in([:request, :body], pet_params)
  #   |> assert_schema
  # end
  #
  # test "[POST] /pets 422" do
  #   pet_params = %{ pet: %{ name: "Doge", type: "pupperino" } }
  #
  #   @swagger
  #   |> Apocryphal.Transaction.post("/pets", 422, @mime)
  #   |> put_in([:request, :body], pet_params)
  #   |> assert_schema
  # end
  #
  # test "[GET] /pets/{id} (200)" do
  #   pet = %Pet{name: "Chauncy", type: "cat"} |> Repo.insert!
  #
  #   @swagger
  #   |> Apocryphal.Transaction.get("/pets/{id}", 200, @mime)
  #   |> put_in([:request, :path_params], %{"id" => pet.id})
  #   |> assert_schema
  # end
  #
  # test "[GET] /pets/{id} (404)" do
  #   @swagger
  #   |> Apocryphal.Transaction.get("/pets/{id}", 404, @mime)
  #   |> put_in([:request, :path_params], %{"id" => "-1"})
  #   |> assert_schema
  # end


<%= if api["basePath"], do: ~s(  # Base Path: #{api["basePath"]}) %>
<%= for mime <- consumes do %>
  @swagger "<%= doc %>"
  @mime "<%= mime %>"

  <%= for {path, path_item} <- paths do %><%= for {verb, operations} <- path_item do %><%= for {http_status, responses} <- operations["responses"] do %>
  test "[<%= String.upcase(verb)%>] <%= path %> (<%= http_status %>)" do
    <%= if verb == "get" && http_status == "200" do %>
    thing = %Thing{} |> Repo.insert!
    <% end %>
    @swagger
      |> Apocryphal.Transaction.get("<%=path%>", <%=http_status%>, @mime)
      <%= if verb == "get" && http_status == "200" && Regex.match?(~r/\{/,path) do %>
      |> put_in([:request, :path_params], %{"id" => thing.id})
      <% end %>
      |> assert_schema
  end
  <% end %><% end %><% end %>
<% end %>
end
