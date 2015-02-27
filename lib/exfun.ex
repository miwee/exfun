defmodule Exfun do

  @doc """
  Convert Erlang terms to Elixir terms. 
  Useful for working with erlang libraries.
  As of now it supports following cases:
    1. Erlang strings are list, while Elixir strings are binary
    2. Some Erlang libraries use :null, while Elixir has nil

  ## Examples

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

  """
  def to_elixir_terms(:null) do 
    nil
  end  

  def to_elixir_terms(x) when is_list(x) do 
    n = Enum.count(x, fn t -> not is_integer(t) end)
    case n do 
      0 ->
        to_string(x)

      _ ->
        Enum.map(x, &to_elixir_terms/1)
    end
  end  

  def to_elixir_terms({:null, x}) do 
    {nil, to_elixir_terms(x)}
  end  

  def to_elixir_terms({t, x}) when is_atom(t) do 
    {t, to_elixir_terms(x)}
  end  

  def to_elixir_terms(x) when is_tuple(x) do
    x 
    |> Tuple.to_list()
    |> to_elixir_terms()
    |> List.to_tuple()
  end  

  def to_elixir_terms(x) do 
    x
  end  

  @doc """
  Convert Elixir terms to Erlang terms. 
  Useful for working with erlang libraries.
  As of now it supports following cases:
    1. Erlang strings are char lists, while Elixir strings are binary
    2. Some Erlang libraries use :null, while Elixir has nil

  ## Examples

  iex(1)> "nodes" |> Exfun.to_erlang_terms() 
  'nodes'
  iex(2)> 'nodes' |> Exfun.to_erlang_terms() 
  'nodes'
  iex(3)> {:ok, "nodes"} |> Exfun.to_erlang_terms() 
  {:ok, 'nodes'}
  iex(4)> nil |> Exfun.to_erlang_terms() 
  :null
  iex(5)> {123, 456} |> Exfun.to_erlang_terms() 
  {123, 456}
  iex(6)> ["nodes", "more"] |> Exfun.to_erlang_terms() 
  ['nodes', 'more']
  iex(7)> {:ok, ["nodes", "more"], 123} |> Exfun.to_erlang_terms() 
  {:ok, ['nodes', 'more'], 123} 

  """
  def to_erlang_terms(nil) do 
    :null
  end  

  def to_erlang_terms(x) when is_list(x) do 
    Enum.map(x, &to_erlang_terms/1)
  end  

  def to_erlang_terms(x) when is_binary(x) do 
    to_char_list(x)
  end  

  def to_erlang_terms({nil, x}) do 
    {:null, to_erlang_terms(x)}
  end  

  def to_erlang_terms({t, x}) when is_atom(t) do 
    {t, to_erlang_terms(x)}
  end  

  def to_erlang_terms(x) when is_tuple(x) do
    x 
    |> Tuple.to_list()
    |> to_erlang_terms()
    |> List.to_tuple()
  end  

  def to_erlang_terms(x) do 
    x
  end  

  @doc """
  String join function in Elixir terms

  ## Examples

  iex(1)> ["a", "b", "c"] |> Exfun.join(?,) 
  "a,b,c"
  iex(2)> ["a"] |> Exfun.join(?,) 
  "a"
  iex(3)> ["a", "b", "c"] |> Exfun.join(",") 
  "a,b,c"
  iex(4)> ["a"] |> Exfun.join(",") 
  "a"

  """
  def join([a], _sep) when is_binary(a) do 
    a
  end

  def join([h | t], sep) when is_binary(h) and (sep in 1..127) do
    Enum.reduce(t, h, fn x, acc -> 
      <<acc::binary, sep::integer, x::binary>> 
    end)
  end

  def join([h | t], sep) when is_binary(h) and is_binary(sep) do 
    Enum.reduce(t, h, fn x, acc -> 
      <<acc::binary, sep::binary, x::binary>> 
    end)
  end

  @doc """
  Pipes `val` through `fun`, useful with |> operator
  for transforming single (non-list) return values 
  from previous pipeline stage.
  ## Examples

  iex(1)> %{a: 4} |> Exfun.pipe_apply(fn x -> x.a end) 
  4

  """
  def pipe_apply(val, fun) do 
    fun.(val)
  end

  @doc """
  Inspects `val` and returns `val`, useful with |> operator
  TBD: How to test for IO.inspect?
  
  ## Examples

  iex(1)> %{a: 4} |> Exfun.pipe_inspect() |> Dict.put(:b, 6)
  %{a: 4, b: 6} 

  """
  def pipe_inspect(val) do 
    IO.inspect val
    val
  end

  @doc """
  Put `value` for `key` in Dict `m`, 
  unless `value` is nil
  ## Examples

  iex(1)> %{a: 4, b: 5} |> Exfun.put_unless_nil(:a, 6) 
  %{a: 6, b: 5}
  iex(2)> %{a: 4, b: 5} |> Exfun.put_unless_nil(:a, nil) 
  %{a: 4, b: 5}

  """
  def put_unless_nil(m, _key, nil) when is_map(m) do 
    m
  end  

  def put_unless_nil(m, key, value) when is_map(m) do 
    Dict.put(m, key, value)
  end  

end