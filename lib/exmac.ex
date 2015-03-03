defmodule Exmac do
  @moduledoc """
  Collection of small utility macros for Elixir language
  """

  @doc """
  Creates a map from a list of variables
  `key` is variable name as `atom`
  `value` is variable value
  `key` is variable name as `binary`, if `use_binaries` option is set
     
  ## Examples

  iex(1)> require Exmac
  nil
  iex(2)> {a, b} = {4, 6}
  {4, 6}
  iex(3)> Exmac.create_map([a, b])
  %{a: 4, b: 6}
  iex(4)> Exmac.create_map([a, b], [use_binaries: true])
  %{"a" => 4, "b" => 6}

  """
  defmacro create_map(vars, opts \\ []) do
    m = for {name, _, _} = var <- vars do 
      quote do
        options = unquote(opts)
        case options do
          [] ->
            {unquote(name), unquote(var)}
  
          [use_binaries: true] ->
            {"#{unquote(name)}", unquote(var)}
        end
      end
    end

    quote do
      unquote(m)
      |> Enum.into(%{})
    end
  end  

  @doc """
  Creates a list of variable name and value pair
  Useful for quick debugging of a list of variables

  ## Examples

  iex(1)> require Exmac
  nil
  iex(2)> {a, b} = {4, 6}
  {4, 6}
  iex(2)> c = %{d: {a, b}}
  %{d: {4, 6}}
  iex(3)> Exmac.inspect_vars([a, b, c])
  ["a = 4", "b = 6", "c = %{d: {4, 6}}"]

  """
  defmacro inspect_vars(vars) do
    for {name, _, _} = var <- vars do 
      quote do
        "#{unquote(name)} = #{inspect unquote(var)}"
      end
    end
  end

  @doc """
  Prints a list of variable name and value pair
  Useful for quick debugging of a list of variables
  """
  def print_vars(vars) do
    for {name, _, _} = var <- vars do
      quote do
        IO.puts "#{unquote(name)} = #{inspect unquote(var)}"
      end
    end
  end
end
