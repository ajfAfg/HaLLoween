ExUnit.start()

# Find an appropriate seed as follows.
# 1..10
# |> Enum.to_list()
# |> Enum.map(fn n ->
#   :rand.seed(:exsss, n)
#   {Enum.random(0..100), Enum.random(0..100)}
# end)
#
# First and second random number are 3 and 74, respectively.
ExUnit.configure(seed: 60)
