defmodule ExfunTest do
  use ExUnit.Case
  doctest Exfun.Kernel
  doctest Exfun.Utils
  doctest Exfun.MacroUtils

  test "the truth" do
    assert 1 + 1 == 2
  end
end
