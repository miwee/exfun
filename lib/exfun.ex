defmodule Exfun do
  @doc """
  Pipes `val` through `fun`, useful with |> operator
  for transforming single (non-list) return values 
  from previous pipeline stage.
  ## Examples

  iex(1)> %{a: 4} |> Exfun.pipe_fn(fn x -> x.a end) 
  4

  """
  def pipe_fn(val, fun) do 
    fun.(val)
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

defmodule Exfun.Macros do
end
