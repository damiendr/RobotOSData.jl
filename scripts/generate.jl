
# Usage:
# julia scripts/generate.jl /path/to/dir/containing/ros/repos

include("../src/gen_msgs.jl")

if !isdir("src")
    error("Please run this in the RobotOSData root directory")
end

mkpath("src/ros")
src_std = "$(ARGS[1])/std_msgs"
common_root = "$(ARGS[1])/common_msgs"

if !isdir(joinpath(src_std, "msg"))
    error("Wrong root directory: message files not found")
end

mkpath("src/ros/std_msgs/")
gen_module(:StdMsgs, [src_std], "src/ros/std_msgs/")

# Order these according to mutual dependencies:
src_common = [
    "$common_root/geometry_msgs",
    "$common_root/actionlib_msgs",
    "$common_root/diagnostic_msgs",
    "$common_root/nav_msgs",
    "$common_root/sensor_msgs",
    "$common_root/shape_msgs",
    "$common_root/stereo_msgs",
    "$common_root/trajectory_msgs",
    "$common_root/visualization_msgs",
]

mkpath("src/ros/common_msgs/")
gen_module(:CommonMsgs, src_common, "src/ros/common_msgs/", :(RobotOSData.StdMsgs), :(RobotOSData.CommonMsgs))

