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

  @doc """
  Returns a hex encoded binary from a list, binary or integer.

  ## Examples

      iex> Exfun.hex_encode("12345678")
      "3132333435363738"

      iex> Exfun.hex_encode('12345678')
      "3132333435363738"

      iex> Exfun.hex_encode("\x01\x02\x03\x04")
      "01020304"

      iex> Exfun.hex_encode([1, 2, 3, 4])
      "01020304"

      iex> Exfun.hex_encode(12345678)
      "BC614E"
  """
  def hex_encode(str) when is_binary(str) or is_list(str) do
    hex_encode_(str, "")
  end

  def hex_encode(int) when is_integer(int) do
    Integer.to_string(int, 16)
  end

  defp hex_encode_(<<>>, acc) do
    acc
  end

  defp hex_encode_(<<x::size(8), remain::binary>>, acc) do
    hex_encode_step_(x, remain, acc)
  end

  defp hex_encode_([], acc) do
    acc
  end

  defp hex_encode_([x | remain], acc) do
    hex_encode_step_(x, remain, acc)
  end

  defp hex_encode_step_(x, remain, acc) do
    case Integer.to_string(x, 16) do
      <<a::size(8), b::size(8)>> ->
        hex_encode_(remain, acc <> <<a, b>>)
      <<b::size(8)>> ->
        hex_encode_(remain, acc <> <<?0, b>>)
    end
  end

  @doc """
  Returns a decoded binary from a hex string in either list
  or binary form.

  ## Examples

      iex> Exfun.hex_decode("3132333435363738")
      "12345678"

      iex> Exfun.hex_decode('3132333435363738')
      "12345678"

      iex> Exfun.hex_decode("0x3132333435363738")
      "12345678"

      iex> Exfun.hex_decode('0x3132333435363738')
      "12345678"
  """
  def hex_decode(hex_str) when is_binary(hex_str) do
    if String.starts_with?(hex_str, "0x") do
      <<"0x", hex_str2::binary>> = hex_str
      hex_decode_(hex_str2, "")
    else 
      hex_decode_(hex_str, "")   
    end   
  end

  def hex_decode(hex_str) when is_list(hex_str) do 
    [a, b | hex_str2] = hex_str
    if [a, b] == '0x' do
      hex_decode_(hex_str2, "")
    else
      hex_decode_(hex_str, "")
    end
  end

  defp hex_decode_(<<>>, acc) do
    acc
  end

  defp hex_decode_(<<x::size(8), y::size(8), remain::binary>>, acc) do
    hex_decode_step_(x, y, remain, acc)
  end

  defp hex_decode_([], acc) do
    acc
  end

  defp hex_decode_([x, y | remain], acc) do
    hex_decode_step_(x, y, remain, acc)
  end

  defp hex_decode_step_(x, y, remain, acc) do
    x2 = String.to_integer(<<x, y>>, 16)
    hex_decode_(remain, acc <> <<x2::size(8)>>)
  end

  @doc """
  Returns an hex string visual representation of a given 
  list or binary.

  ## Examples

      iex> Exfun.hexify('ABcd')
      "[0x41, 0x42, 0x63, 0x64]"

      iex> Exfun.hexify("ABcd")
      "<<0x41, 0x42, 0x63, 0x64>>"
  """
  def hexify(str) when is_list(str) do
    "[" <> hexify_(str, "") <> "]"
  end

  def hexify(str) when is_binary(str) do
    "<<" <> hexify_(str, "") <> ">>"
  end

  defp hexify_(<<x::size(8)>>, acc) do
    hexify_step1_(x, acc)
  end

  defp hexify_(<<x::size(8), remain::binary>>, acc) do
    hexify_step_(x, remain, acc)
  end

  defp hexify_([x], acc) do
    hexify_step1_(x, acc)
  end

  defp hexify_([x | remain], acc) do
    hexify_step_(x, remain, acc)
  end

  defp hexify_step1_(x, acc) do
    case Integer.to_string(x, 16) do
      <<a::size(8), b::size(8)>> ->
        acc <> <<"0x", a, b>>
      <<b::size(8)>> ->
        acc <> <<"0x", ?0, b>>
    end
  end

  defp hexify_step_(x, remain, acc) do
    case Integer.to_string(x, 16) do
      <<a::size(8), b::size(8)>> ->
        hexify_(remain, acc <> <<"0x", a, b, ", ">>)
      <<b::size(8)>> ->
        hexify_(remain, acc <> <<"0x", ?0, b, ", ">>)
    end
  end

end