defmodule HalloweenTest do
  use ExUnit.Case, async: true
  doctest Halloween

  import Halloween,
    only: [to_halloween: 2, halloween_with_halloween: 2, to_halloween_level: 1, halloween: 1]

  @low_hallo "HALLOWEEN"
  @mid_hallo "HALLOWEEN!"
  @high_hallo "HALLOWEEN..."

  describe "Return a text halloweened." do
    setup do
      [
        text: """
        On the surface, Cosmo doesn't exhibit many emotions aside from her usual smiling , seemingly happy-go-lucky attitude. She doesn't speak except for repeating the word "Halloween" and, like the rest of Quanxi's fiends, follows Quanxi around and seems to be in love with her and under her command.
        (Quote from https://chainsaw-man.fandom.com/wiki/Cosmo)
        """
      ]
    end

    test "When the halloween is 20.", fixture do
      fixture.text
      |> to_halloween(20)
      |> print()
    end

    test "When the halloween is 50.", fixture do
      fixture.text
      |> to_halloween(50)
      |> print()
    end

    test "When the halloween is 100.", fixture do
      fixture.text
      |> to_halloween(100)
      |> print()
    end
  end

  defp print(str) do
    IO.puts("")
    IO.puts(str)
  end

  describe "Return a HALLOWEEN string with the probability of halloween." do
    setup do
      # First and second random number are 93 and 23, respectively.
      :rand.seed(:exsss, ExUnit.configuration()[:seed])

      [
        low_halloween: 20,
        mid_halloween: 50,
        high_halloween: 100
      ]
    end

    test "Return a string HALLOWEEN if the halloween is lower than 20.", fixture do
      assert halloween_with_halloween("foo", fixture.low_halloween) == @low_hallo
      assert halloween_with_halloween("foo", fixture.low_halloween) == "foo"
    end

    test "Return a string HALLOWEEN... if the halloween is higher than 100.", fixture do
      assert halloween_with_halloween("foo", fixture.high_halloween) == @high_hallo
      assert halloween_with_halloween("foo", fixture.high_halloween) == @high_hallo
    end

    test "Return a string HALLOWEEN! if the halloween is greater than 20 and less than 100.",
         fixture do
      assert halloween_with_halloween("foo", fixture.mid_halloween) == @mid_hallo
      assert halloween_with_halloween("foo", fixture.mid_halloween) == "foo"
    end
  end

  describe "Return a halloween level as an atom." do
    test "Return :low if the halloween is lower than 20." do
      assert to_halloween_level(20) == :low
    end

    test "Return :high if the halloween is higher than 100." do
      assert to_halloween_level(100) == :high
    end

    test "Return :midium if the halloween is greater than 20 and less than 100." do
      assert to_halloween_level(21) == :midium
      assert to_halloween_level(99) == :midium
    end
  end

  describe "Return a string HALLOWEEN." do
    test "Return a string HALLOWEEN if the halloween level is :low." do
      assert halloween(:low) == @low_hallo
    end

    test "Return a string HALLOWEEN! if the halloween level is :midium." do
      assert halloween(:midium) == @mid_hallo
    end

    test "Return a string HALLOWEEN... if the halloween level is :high." do
      assert halloween(:high) == @high_hallo
    end
  end
end
