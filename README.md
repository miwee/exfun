# Exfun and Exmac

Exfun is a collection of small utility functions and Exmac is a collection of small utility macros for Elixir language, [check out Elixir's website](http://elixir-lang.org/).

There is no external dependency on any other third party library.

## Using Exfun and Exmac with Mix

First add Exfun as a dependency:

```elixir
def deps do
  [{:exfun, github: "miwee/exfun"}]
end
```

After adding Exfun as a dependency, run `mix deps.get` to install it.

## Using Exfun and Exmac without Mix

For using Exfun, just copy file lib/exfun.ex in your project's lib directory

For using Exmac, just copy file lib/exmac.ex in your project's lib directory

## Examples
Examples are part of the doctest strings within source files lib/exfun.ex and lib/exmac.ex

For complete list, please refer to the respective source files. 

Below is detail of some of the functions and macros

```
Convert Erlang terms to Elixir terms. 
Useful for working with erlang libraries.
As of now it supports following cases:
  1. Erlang strings are list, while Elixir strings are binary
  2. Some Erlang libraries use :null, while Elixir has nil
```

```elixir
  iex(1)> 'nodes' |> Exfun.to_elixir_terms() 
  "nodes"
  iex(2)> "nodes" |> Exfun.to_elixir_terms() 
  "nodes"
  iex(3)> {:ok, 'nodes'} |> Exfun.to_elixir_terms() 
  {:ok, "nodes"}
  iex(4)> :null |> Exfun.to_elixir_terms() 
  nil
  iex(5)> ['nodes', 'more'] |> Exfun.to_elixir_terms() 
  ["nodes", "more"]
  iex(6)> {:ok, ['nodes', 'more'], 123} |> Exfun.to_elixir_terms() 
  {:ok, ["nodes", "more"], 123}
```

Inspects `val` and returns `val`, useful with |> operator
  
```elixir
  iex(1)> %{a: 4} |> Exfun.pipe_inspect() |> Dict.put(:b, 6)
  %{a: 4, b: 6} 
```

```
Creates a map from a list of variables
`key` is variable name as `atom`
`value` is variable value
`key` is variable name as `binary`, if `use_binaries` option is set
```

```elixir
  iex(1)> require Exmac
  nil
  iex(2)> {a, b} = {4, 6}
  {4, 6}
  iex(3)> Exmac.create_map([a, b])
  %{a: 4, b: 6}
  iex(4)> Exmac.create_map([a, b], [use_binaries: true])
  %{"a" => 4, "b" => 6}
```

```
Creates a list of variable name and value pair
Useful for quick debugging of a list of variables
```

```elixir
  iex(1)> require Exmac
  nil
  iex(2)> {a, b} = {4, 6}
  {4, 6}
  iex(2)> c = %{d: {a, b}}
  %{d: {4, 6}}
  iex(3)> Exmac.inspect_vars([a, b, c])
  ["a = 4", "b = 6", "c = %{d: {4, 6}}"]
```
