# Okta

This library provides an Elixir API for accessing the [Okta Developer APIs](https://developer.okta.com/docs/reference/).

Currently implemented are:
* [Users API](https://developer.okta.com/docs/reference/api/users/)
* [Groups API](https://developer.okta.com/docs/reference/api/groups/)

The API access uses the [Tesla](https://github.com/teamon/tesla) library and relies on the caller passing in an Okta base URL and an API Key
to create a client. The client is then passed into all API calls. 

The API returns a 3 element tuple. If the API HTTP status code is less the 300 (ie. suceeded) it returns `:ok`, the HTTP body as a map and the full Tesla Env if you need to access more data about thre return. if the API HTTP status code is greater than 300. it returns `:error`, the HTTP body and the Telsa Env. If the API doesn't return at all it should return `:error`, a blank map and the error from Tesla.

```
client = Okta.client("https://dev-000000.okta.com", "thisismykeycreatedinokta")

profile = %{
    firstName: "test",
    lastName: "user",
  }

case Okta.Users.create_user(client, profile) do
  {:ok, %{"id" => id, "status" => status}, _env} -> update_user(%{okta_id: id, okta_status: status})
  {:error, %{"errorSummary" => errorSummary}, _env} -> Logger.error(errorSummary)
end
```

## Installation

Add `okta_api` to your list of dependencies in mix.exs

```
def deps do
  [
    {:okta_api, "~> 0.1.4"}
  ]
end
```

## Documentation

Documentation can be be found at [https://hexdocs.pm/okta_api](https://hexdocs.pm/okta_api). 

