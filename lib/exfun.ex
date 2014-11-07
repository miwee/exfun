defmodule Exfun.Utils do
end

defmodule Exfun.MacroUtils do
end

defmodule Exfun.Enum do
end

defmodule Exfun.Kernel do
  @doc """
  Pipes `val` through `fun`, useful with |> operator
  for transforming single (non-list) return values 
  from previous pipeline stage.
  ## Examples

  iex(1)> import Exfun.Kernel
  nil
  iex(2)> %{a: 4} |> pipe_fn(fn x -> x.a end) 
  4

  """
  def pipe_fn(val, fun) do 
    fun.(val)
  end
end
