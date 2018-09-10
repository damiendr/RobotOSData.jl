# !! auto-generated code, do not edit !!
module geometry_msgs
using RobotOSData.Messages
using RobotOSData.StdMsgs
using RobotOSData.CommonMsgs
struct Vector3 <: Readable
    x::Float64
    y::Float64
    z::Float64
end
struct Vector3Stamped <: Readable
    header::Header
    vector::Vector3
end
struct Accel <: Readable
    linear::Vector3
    angular::Vector3
end
struct AccelStamped <: Readable
    header::Header
    accel::Accel
end
struct Point32 <: Readable
    x::Float32
    y::Float32
    z::Float32
end
struct Polygon <: Readable
    points::Vector{Point32}
end
struct PolygonStamped <: Readable
    header::Header
    polygon::Polygon
end
struct Quaternion <: Readable
    x::Float64
    y::Float64
    z::Float64
    w::Float64
end
struct Transform <: Readable
    translation::Vector3
    rotation::Quaternion
end
struct Point <: Readable
    x::Float64
    y::Float64
    z::Float64
end
struct Pose <: Readable
    position::Point
    orientation::Quaternion
end
struct PoseWithCovariance <: Readable
    pose::Pose
    covariance::SVector{36, Float64}
end
struct PoseWithCovarianceStamped <: Readable
    header::Header
    pose::PoseWithCovariance
end
struct AccelWithCovariance <: Readable
    accel::Accel
    covariance::SVector{36, Float64}
end
struct PointStamped <: Readable
    header::Header
    point::Point
end
struct Twist <: Readable
    linear::Vector3
    angular::Vector3
end
struct TwistStamped <: Readable
    header::Header
    twist::Twist
end
struct AccelWithCovarianceStamped <: Readable
    header::Header
    accel::AccelWithCovariance
end
struct TwistWithCovariance <: Readable
    twist::Twist
    covariance::SVector{36, Float64}
end
struct Inertia <: Readable
    m::Float64
    com::geometry_msgs.Vector3
    ixx::Float64
    ixy::Float64
    ixz::Float64
    iyy::Float64
    iyz::Float64
    izz::Float64
end
struct Pose2D <: Readable
    x::Float64
    y::Float64
    theta::Float64
end
struct TwistWithCovarianceStamped <: Readable
    header::Header
    twist::TwistWithCovariance
end
struct PoseArray <: Readable
    header::Header
    poses::Vector{Pose}
end
struct Wrench <: Readable
    force::Vector3
    torque::Vector3
end
struct TransformStamped <: Readable
    header::Header
    child_frame_id::String
    transform::Transform
end
struct WrenchStamped <: Readable
    header::Header
    wrench::Wrench
end
struct PoseStamped <: Readable
    header::Header
    pose::Pose
end
struct InertiaStamped <: Readable
    header::Header
    inertia::Inertia
end
struct QuaternionStamped <: Readable
    header::Header
    quaternion::Quaternion
end
end
