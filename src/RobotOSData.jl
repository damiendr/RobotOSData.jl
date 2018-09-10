
module RobotOSData

using FileIO

function __init__()
    # Register the format with FileIO when the module is loaded:
    add_format(format"ROSBAG", "#ROSBAG V", ".bag")
    add_loader(format"ROSBAG", :RobotOSData)
end

include("messages.jl")
using .Messages
include("ros/std_msgs/StdMsgs.jl")
include("ros/common_msgs/CommonMsgs.jl")

include("records.jl")
include("bag.jl")
include("gen_msgs.jl")

export ROSTime, MessageData


end # module
