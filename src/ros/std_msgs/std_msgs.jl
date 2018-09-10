# !! auto-generated code, do not edit !!
module std_msgs
using RobotOSData.Messages
struct MultiArrayDimension <: Readable
    label::String
    size::UInt32
    stride::UInt32
end
struct MultiArrayLayout <: Readable
    dim::Vector{MultiArrayDimension}
    data_offset::UInt32
end
struct UInt32MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{UInt32}
end
struct UInt16MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{UInt16}
end
struct ByteMultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{UInt8}
end
struct UInt64MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{UInt64}
end
struct Char <: Readable
    data::UInt8
end
struct UInt8MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{UInt8}
end
struct Int8MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{Int8}
end
struct ColorRGBA <: Readable
    r::Float32
    g::Float32
    b::Float32
    a::Float32
end
struct Duration <: Readable
    data::ROSDuration
end
struct Int64MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{Int64}
end
struct Time <: Readable
    data::ROSTime
end
struct Int32MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{Int32}
end
struct Header <: Readable
    seq::UInt32
    stamp::ROSTime
    frame_id::String
end
struct Float32MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{Float32}
end
struct Float64MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{Float64}
end
struct Empty <: Readable
end
struct Int16MultiArray <: Readable
    layout::MultiArrayLayout
    data::Vector{Int16}
end
struct Byte <: Readable
    data::UInt8
end
end
