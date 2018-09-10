# !! auto-generated code, do not edit !!
module actionlib_msgs
using RobotOSData.Messages
using RobotOSData.StdMsgs
using RobotOSData.CommonMsgs
struct GoalID <: Readable
    stamp::ROSTime
    id::String
end
struct GoalStatus <: Readable
    goal_id::GoalID
    status::UInt8
    text::String
end
struct GoalStatusArray <: Readable
    header::Header
    status_list::Vector{GoalStatus}
end
end
