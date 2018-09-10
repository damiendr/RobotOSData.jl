# !! auto-generated code, do not edit !!
module nav_msgs
using RobotOSData.Messages
using RobotOSData.StdMsgs
using RobotOSData.CommonMsgs
struct MapMetaData <: Readable
    map_load_time::ROSTime
    resolution::Float32
    width::UInt32
    height::UInt32
    origin::geometry_msgs.Pose
end
struct GridCells <: Readable
    header::Header
    cell_width::Float32
    cell_height::Float32
    cells::Vector{geometry_msgs.Point}
end
struct Odometry <: Readable
    header::Header
    child_frame_id::String
    pose::geometry_msgs.PoseWithCovariance
    twist::geometry_msgs.TwistWithCovariance
end
struct OccupancyGrid <: Readable
    header::Header
    info::MapMetaData
    data::Vector{Int8}
end
struct Path <: Readable
    header::Header
    poses::Vector{geometry_msgs.PoseStamped}
end
end
