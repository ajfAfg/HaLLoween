defmodule Halloween do
  @low_border 20
  @high_border 100

  @moduledoc """
  Documentation for `Halloween`.
  """

  def to_halloween(text, halloween) do
    text
    |> String.split()
    |> Enum.map(&halloween_with_halloween(&1, halloween))
    |> Enum.join(" ")
  end

  def halloween_with_halloween(str, halloween) do
    if rand() <= halloween do
      halloween |> to_halloween_level() |> halloween()
    else
      str
    end
  end

  def to_halloween_level(n) when n <= @low_border, do: :low
  def to_halloween_level(n) when @high_border <= n, do: :high
  def to_halloween_level(_), do: :midium

  def halloween(:low), do: "HALLOWEEN"
  def halloween(:midium), do: "HALLOWEEN!"
  def halloween(:high), do: "HALLOWEEN..."

  defp rand(), do: Enum.random(0..100)
end
