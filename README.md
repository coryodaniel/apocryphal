TODOs:

* smarter approach to remote files
* easy handler for passing to exjsonschema
* SUT: config
* header assertions
* handling hostname, scheme in json file.


# Apocryphal

Swagger based documentation driven development for ExUnit

## Installation

```elixir
def deps do
  [{:apocryphal, "~> 0.2.0", only: [:test, :dev]}]
end
```

```bash
mix deps.get
mix apocryphal.init
```

Add `HTTPoison.start` to test_helper.exs:

```elixir
ExUnit.start
HTTPoison.start
Ecto.Adapters.SQL.Sandbox.mode(PetStore.Repo, :manual)
```

### Configure for Phoenix (HTTP Requests, SQL Sandbox)

Configure `test.exs` env to use Ecto SQL Sandbox and serve content

```elixir
config :YOUR_APP, YOUR_APP.Endpoint,
  http: [port: 4001],
  server: true

config :YOUR_APP, :sql_sandbox, true
```

Configure `lib/YOUR_APP/endpoint.ex`
```elixir
if Application.get_env(:YOUR_APP, :sql_sandbox) do
  plug Phoenix.Ecto.SQL.Sandbox
end
```

Configure Apocryphal

```elixir
config :apocryphal,
  port: 4001,
  host: "localhost",
  serializers: %{
    "application/json" => fn(body) -> Poison.encode!(body) end
  },
  deserializers: %{
    "application/json" => fn(body) -> Poison.decode!(body) end
  }
```

### Configure for Plug

[TBD](https://github.com/coryodaniel/apocryphal/issues/4)


## Usage

### Generating an API verification test

Parse swagger documentation into ExUnit tests
```bash
mix apocryphal.gen.test V1.Pets --only=^\/pets --swagger-file=./docs/pet_store.yml
mix apocryphal.gen.test V1.Stores --only=^\/stores --swagger-file=./docs/pet_store.yml
```

"One big file" mode:
```bash
mix apocryphal.gen.test V1.PetAPI --swagger-file=./docs/pet_store.yml
```

Then just run `mix test`.

### Full Example

Check out the [Petz Sample Phoenix app](http://github.com/coryodaniel/petz)


```elixir
defmodule PetStore.V1.PetAPITest do
  use Apocryphal.Case
  alias PetStore.Pet
  alias PetStore.Store

  @swagger "./docs/pet_store.yml"
  @mime "application/json"

  test "[GET] /stores (200)" do
    %Store{ address: "123 Ship St.",
            city: "Los Angeles",
            state: "CA",
            postal_code: "90210" } |> Repo.insert!


    # assert_schema/1 will dispatch the transaction if a request isn't
    # present, or it can be manually dispatched
    @swagger
    |> Apocryphal.Transaction.get("/stores", 200, @mime)
    |> Apocryphal.Transaction.dispatch
    |> assert_schema

    # @swagger
    # |> Apocryphal.Transaction.get("/stores", 200, @mime)
    # |> assert_schema
  end

  test "[GET] /pets (200)" do
    %Pet{ name: "Chauncy", type: "dog" } |> Repo.insert!

    @swagger
    |> Apocryphal.Transaction.get("/pets", 200, @mime)
    |> put_in([:request, :params], [limit: 20])
    |> assert_schema
  end

  test "[POST] /pets (201)" do
    pet_params = %{ pet: %{ name: "Chuancy", type: "cat" } }
    @swagger
    |> Apocryphal.Transaction.post("/pets", 201, @mime)
    |> put_in([:request, :body], pet_params)
    |> assert_schema
  end

  test "[POST] /pets 422" do
    pet_params = %{ pet: %{ name: "Doge", type: "pupperino" } }
    @swagger
    |> Apocryphal.Transaction.post("/pets", 422, @mime)
    |> put_in([:request, :body], pet_params)
    |> assert_schema
  end

  test "[GET] /pets/{id} (200)" do
    pet = %Pet{name: "Chauncy", type: "cat"} |> Repo.insert!

    @swagger
    |> Apocryphal.Transaction.get("/pets/{id}", 200, @mime)
    |> put_in([:request, :path_params], %{"id" => pet.id})
    |> assert_schema
  end

  test "[GET] /pets/{id} (404)" do
    @swagger
    |> Apocryphal.Transaction.get("/pets/{id}", 404, @mime)
    |> put_in([:request, :path_params], %{"id" => "-1"})
    |> assert_schema
  end
end
```

### Using remote swagger files

Under the hood Apocryphal uses ExJsonSchema. To set up resolves for remote schemas see the [ExJsonSchema docs](https://github.com/jonasschmidt/ex_json_schema#installation)


### Note for Umbrella apps

If you are creating an umbrella app `YOUR_APP` above should be the app containing the ecto repo!

Issues have been experience with async tests with umbrella apps where Ecto raises an `Ownership.Error`. Setting the tests explicitly as `async: false` fixes this.
