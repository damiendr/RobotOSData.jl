# !! auto-generated code, do not edit !!
module sensor_msgs
using RobotOSData.Messages
using RobotOSData.StdMsgs
using RobotOSData.CommonMsgs
struct MagneticField <: Readable
    header::Header
    magnetic_field::geometry_msgs.Vector3
    magnetic_field_covariance::SVector{9, Float64}
end
struct NavSatStatus <: Readable
    status::Int8
    service::UInt16
end
struct LaserScan <: Readable
    header::Header
    angle_min::Float32
    angle_max::Float32
    angle_increment::Float32
    time_increment::Float32
    scan_time::Float32
    range_min::Float32
    range_max::Float32
    ranges::Vector{Float32}
    intensities::Vector{Float32}
end
struct BatteryState <: Readable
    header::Header
    voltage::Float32
    current::Float32
    charge::Float32
    capacity::Float32
    design_capacity::Float32
    percentage::Float32
    power_supply_status::UInt8
    power_supply_health::UInt8
    power_supply_technology::UInt8
    present::Bool
    cell_voltage::Vector{Float32}
    location::String
    serial_number::String
end
struct JoyFeedback <: Readable
    type_::UInt8
    id::UInt8
    intensity::Float32
end
struct JoyFeedbackArray <: Readable
    array::Vector{JoyFeedback}
end
struct Temperature <: Readable
    header::Header
    temperature::Float64
    variance::Float64
end
struct PointField <: Readable
    name::String
    offset::UInt32
    datatype::UInt8
    count::UInt32
end
struct PointCloud2 <: Readable
    header::Header
    height::UInt32
    width::UInt32
    fields::Vector{PointField}
    is_bigendian::Bool
    point_step::UInt32
    row_step::UInt32
    data::Vector{UInt8}
    is_dense::Bool
end
struct Illuminance <: Readable
    header::Header
    illuminance::Float64
    variance::Float64
end
struct LaserEcho <: Readable
    echoes::Vector{Float32}
end
struct MultiEchoLaserScan <: Readable
    header::Header
    angle_min::Float32
    angle_max::Float32
    angle_increment::Float32
    time_increment::Float32
    scan_time::Float32
    range_min::Float32
    range_max::Float32
    ranges::Vector{LaserEcho}
    intensities::Vector{LaserEcho}
end
struct ChannelFloat32 <: Readable
    name::String
    values::Vector{Float32}
end
struct PointCloud <: Readable
    header::Header
    points::Vector{geometry_msgs.Point32}
    channels::Vector{ChannelFloat32}
end
struct NavSatFix <: Readable
    header::Header
    status::NavSatStatus
    latitude::Float64
    longitude::Float64
    altitude::Float64
    position_covariance::SVector{9, Float64}
    position_covariance_type::UInt8
end
struct TimeReference <: Readable
    header::Header
    time_ref::ROSTime
    source::String
end
struct Imu <: Readable
    header::Header
    orientation::geometry_msgs.Quaternion
    orientation_covariance::SVector{9, Float64}
    angular_velocity::geometry_msgs.Vector3
    angular_velocity_covariance::SVector{9, Float64}
    linear_acceleration::geometry_msgs.Vector3
    linear_acceleration_covariance::SVector{9, Float64}
end
struct RegionOfInterest <: Readable
    x_offset::UInt32
    y_offset::UInt32
    height::UInt32
    width::UInt32
    do_rectify::Bool
end
struct CompressedImage <: Readable
    header::Header
    format::String
    data::Vector{UInt8}
end
struct Image <: Readable
    header::Header
    height::UInt32
    width::UInt32
    encoding::String
    is_bigendian::UInt8
    step::UInt32
    data::Vector{UInt8}
end
struct Joy <: Readable
    header::Header
    axes::Vector{Float32}
    buttons::Vector{Int32}
end
struct Range <: Readable
    header::Header
    radiation_type::UInt8
    field_of_view::Float32
    min_range::Float32
    max_range::Float32
    range::Float32
end
struct FluidPressure <: Readable
    header::Header
    fluid_pressure::Float64
    variance::Float64
end
struct JointState <: Readable
    header::Header
    name::Vector{String}
    position::Vector{Float64}
    velocity::Vector{Float64}
    effort::Vector{Float64}
end
struct MultiDOFJointState <: Readable
    header::Header
    joint_names::Vector{String}
    transforms::Vector{geometry_msgs.Transform}
    twist::Vector{geometry_msgs.Twist}
    wrench::Vector{geometry_msgs.Wrench}
end
struct RelativeHumidity <: Readable
    header::Header
    relative_humidity::Float64
    variance::Float64
end
struct CameraInfo <: Readable
    header::Header
    height::UInt32
    width::UInt32
    distortion_model::String
    D::Vector{Float64}
    K::SVector{9, Float64}
    R::SVector{9, Float64}
    P::SVector{12, Float64}
    binning_x::UInt32
    binning_y::UInt32
    roi::RegionOfInterest
end
end
