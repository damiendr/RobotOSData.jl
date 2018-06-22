module ROSData

include("rosbag.jl")
export Subscription, Bag, read_topics

include("rosmsg.jl")
export read_string, read_array, read_array!

end # module
