defmodule ExfunTest do
  use ExUnit.Case
  doctest Exfun
  doctest Exmac

  test "the truth" do
    assert 1 + 1 == 2
  end
end
