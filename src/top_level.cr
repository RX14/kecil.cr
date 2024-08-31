# Repeatedly executes the block.
#
# ```
# loop do
#   # ...
#   i = i >> 3
#   break if i == 0
# end
# ```
def loop(&)
  while true
    yield
  end
end
