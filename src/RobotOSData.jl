
module RobotOSData

using FileIO
using UUIDs

function __init__()
    # Register the format with FileIO when the module is loaded:
    add_format(format"ROSBAG", "#ROSBAG V", ".bag", [:RobotOSData => UUID("ec174be4-a9f3-11e8-3a81-af157eca82e9")])
end

include("messages.jl")
using .Messages
include("ros/std_msgs/StdMsgs.jl")
include("ros/common_msgs/CommonMsgs.jl")

include("records.jl")
include("bag.jl")
include("gen_msgs.jl")

export ROSTime, ROSDuration, MessageData


end # module
