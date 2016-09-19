# Apocryphal

Swagger based document driven development for ExUnit

## Installation

```elixir
def deps do
  [{:apocryphal, "~> 0.1.0", only: [:test, :dev]}]
end
```

```bash
mix deps.get
mix apocryphal.init
```

## TODO https://app.apiary.io/swaggertest66/editor
* [x] transactions
* [x] consumes
* [x] include ConnCase for Ecto transaction
* [ ] Generate test/support/apocryphal_case
  * [ ] gen.test (new DSL)
  * [ ] Apocryphal.IntegrationCase
  * [ ] Route Helpers (import PetStore.Router.Helpers)
* [ ] STructify request, expected
* [ ] Strict match option (only, except)
* [ ] Searalize body as part of Trans.create after config.()... also set content-type header here, if not present
* [ ] server: true in test and use hackney?
* [ ] SQL sandbox (see wallaby setup)
* [ ] Transaction.params (body or query string params)
* [ ] produces (insert into header expectation)
* [ ] Transaction.apply_to_conn (move all junk out of the ExUnit.test blk)
* [ ] Move some of Case into Transaction
* [ ] change assertion to dump body if !:ok
* [ ] handle required/optional params/headers/etc
* [ ] better error output Transaction.build
* [ ] Documentation
  * [ ] change desc to Phoenix not Elixir :/
  * [ ] test.exs config
* [ ] Credo/Dogma/inch/coverex

## Usage

### Generating an API verification test

Parse swagger documentation into ExUnit tests
```bash
mix apocryphal.gen.test V1.Pets --only=^\/pets --swagger-file=./docs/pet_store.yaml
mix apocryphal.gen.test V1.Stores --only=^\/stores --swagger-file=./docs/pet_store.yaml
```

One big ass file mode:
```bash
mix apocryphal.gen.test V1.PetAPI --swagger-file=./docs/pet_store.yml
```

### Using remote swagger files

Under the hood Apocryphal uses ExJsonSchema. To set up resolves for remote schemas see the [ExJsonSchema docs](https://github.com/jonasschmidt/ex_json_schema#installation)

## Development

mix deps.compile; iex -S mix apocryphal.gen.test V1.Pets --swagger-file=./docs/pet_store.yml --only=^\/pets
mix deps.compile; iex -S mix apocryphal.gen.test V1.PetAPI --swagger-file=./docs/pet_store.yml

```elixir
config :petz, PetStore.Endpoint,
  http: [port: 4001],
  server: true

config :apocryphal,
# port: 4001,
# host: "localhost",
serializers: %{
  "application/json" => fn(body) -> Poison.encode!(body) end
},
deserializers: %{
  "application/json" => fn(body) -> Poison.decode!(body) end
}

```

```elixir
verify "docs/v1.yml", "application/json" do
  get "/v1/stores", 200

  @config {:example, except: {:data, :attributes, :inserted_at}}
  get "/v1/pets", 200, fn(transaction)-> end
  get "/v1/pets/{id}", 500, fn(transaction)-> end  
  get "/v1/pets/{id}", 200, fn(transaction)->
    transaction.expectation.schema by default

    transaction.expectation.match :example
    transaction.expectation.match :example, except: {:data, :attributes, :inserted_at}        

    transaction.expectation.match %{...body...}
    transaction.expectation.match %{}, except: {:data, :attributes, :inserted_at}
  end
end
```


```elixir
defmodule YourApp.ApocryphalCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Apocryphal.DSL

      import Ecto.Model
      import Ecto.Query, only: [from: 2]
      import YourApp.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(YourApp.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(YourApp.Repo, {:shared, self()})
    end

    # What are tags here? Can I see the @swagger & @mime!?
    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(PetStore.Repo, self())
    {:ok, x: "Y"}
  end
end
```

@swagger "./doc/pet_store.yml"
setup %{conn: conn} do
  # IO.inspect @swagger
  # IO.inspect "HI"
  # #{:ok, transaction: Apocryphal.Transaction.create... }
  {:ok, conn: put_req_header(conn, "accept", "application/json")}
end
