# !! auto-generated code, do not edit !!
module shape_msgs
using RobotOSData.Messages
using RobotOSData.StdMsgs
using RobotOSData.CommonMsgs
struct MeshTriangle <: Readable
    vertex_indices::SVector{3, UInt32}
end
struct SolidPrimitive <: Readable
    type_::UInt8
    dimensions::Vector{Float64}
end
struct Plane <: Readable
    coef::SVector{4, Float64}
end
struct Mesh <: Readable
    triangles::Vector{MeshTriangle}
    vertices::Vector{geometry_msgs.Point}
end
end
