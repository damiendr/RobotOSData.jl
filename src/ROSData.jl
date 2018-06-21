module ROSData

include("rosbag.jl")
export Subscription, Bag

include("rosmsg.jl")
export read_string, read_array, read_array!

end # module
