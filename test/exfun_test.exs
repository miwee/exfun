defmodule ExfunTest do
  use ExUnit.Case
  doctest Exfun
  doctest Exfun.Macros

  test "the truth" do
    assert 1 + 1 == 2
  end
end
