defmodule HalloweenTest do
  use ExUnit.Case
  doctest Halloween

  test "greets the world" do
    assert Halloween.hello() == :world
  end
end
