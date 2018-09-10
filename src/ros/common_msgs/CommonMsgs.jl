module CommonMsgs
include("geometry_msgs.jl")
export geometry_msgs
include("actionlib_msgs.jl")
export actionlib_msgs
include("diagnostic_msgs.jl")
export diagnostic_msgs
include("nav_msgs.jl")
export nav_msgs
include("sensor_msgs.jl")
export sensor_msgs
include("shape_msgs.jl")
export shape_msgs
include("stereo_msgs.jl")
export stereo_msgs
include("trajectory_msgs.jl")
export trajectory_msgs
include("visualization_msgs.jl")
export visualization_msgs
end