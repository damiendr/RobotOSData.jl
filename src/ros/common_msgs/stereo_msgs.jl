# !! auto-generated code, do not edit !!
module stereo_msgs
using RobotOSData.Messages
using RobotOSData.StdMsgs
using RobotOSData.CommonMsgs
struct DisparityImage <: Readable
    header::Header
    image::sensor_msgs.Image
    f::Float32
    T::Float32
    valid_window::sensor_msgs.RegionOfInterest
    min_disparity::Float32
    max_disparity::Float32
    delta_d::Float32
end
end
