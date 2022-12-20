# defmodule Home do
#   room :bathroom do
#     sensor

#     group :spot do
#       light(:left)
#       light(:middle)
#       light(:right)
#     end
#   end

#   room :bedroom do
#     light(:ceiling)
#     light(:globe)
#   end

#   room :hallway do
#     sensor
#     light(:ceiling)
#   end

#   room :kitchen do
#     sensor
#     light(:ceiling)
#     light(:counter)
#     light(:table)
#     light(:sofa)
#   end

#   room :play do
#     group :spot do
#       light(:desk)
#       light(:floor)
#       light(:bed)
#     end
#   end

#   rule for: :bathroom do
#     loop do
#       wait({:sensor, :occupancy, true})
#       off(:spot)
#     end
#   end
# end
