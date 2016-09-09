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
mix apocryphal.init # Generates
```

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

```elixir
defmodule YOUR_APP.Apocryphal.V1.PetTest do
  use Apocryphal.Case
  @documentation "docs/pet_store.yml"

  # Parses doc and adds all the stubs (matrix: parameters, responses, produces)
  verify "/v1/pets", :post, fn(transaction) ->
    # set up your test here
    #
    transaction
  end

  verify "/v1/pets", :get, fn(transaction) ->
    transaction
  end  

  verify "/v1/pets/{petId}", :get, fn(transaction) ->
    transaction
  end  

  @config {:example, except: {:data, :attributes, :inserted_at}}
  verify "/v1/pets/{petId}", :get, @config, fn(transaction) ->
    transaction
  end
end
```



###

## Development

mix deps.compile; iex -S mix apocryphal.gen.test V1.Pets --swagger-file=./docs/pet_store.yml --only=^\/pets
mix deps.compile; iex -S mix apocryphal.gen.test V1.PetAPI --swagger-file=./docs/pet_store.yml
