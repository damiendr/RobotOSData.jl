# !! auto-generated code, do not edit !!
module trajectory_msgs
using RobotOSData.Messages
using RobotOSData.StdMsgs
using RobotOSData.CommonMsgs
struct MultiDOFJointTrajectoryPoint <: Readable
    transforms::Vector{geometry_msgs.Transform}
    velocities::Vector{geometry_msgs.Twist}
    accelerations::Vector{geometry_msgs.Twist}
    time_from_start::ROSDuration
end
struct MultiDOFJointTrajectory <: Readable
    header::Header
    joint_names::Vector{String}
    points::Vector{MultiDOFJointTrajectoryPoint}
end
struct JointTrajectoryPoint <: Readable
    positions::Vector{Float64}
    velocities::Vector{Float64}
    accelerations::Vector{Float64}
    effort::Vector{Float64}
    time_from_start::ROSDuration
end
struct JointTrajectory <: Readable
    header::Header
    joint_names::Vector{String}
    points::Vector{JointTrajectoryPoint}
end
end
