# !! auto-generated code, do not edit !!
module visualization_msgs
using RobotOSData.Messages
using RobotOSData.StdMsgs
using RobotOSData.CommonMsgs
struct Marker <: Readable
    header::Header
    ns::String
    id::Int32
    type_::Int32
    action::Int32
    pose::geometry_msgs.Pose
    scale::geometry_msgs.Vector3
    color::std_msgs.ColorRGBA
    lifetime::ROSDuration
    frame_locked::Bool
    points::Vector{geometry_msgs.Point}
    colors::Vector{std_msgs.ColorRGBA}
    text::String
    mesh_resource::String
    mesh_use_embedded_materials::Bool
end
struct InteractiveMarkerControl <: Readable
    name::String
    orientation::geometry_msgs.Quaternion
    orientation_mode::UInt8
    interaction_mode::UInt8
    always_visible::Bool
    markers::Vector{Marker}
    independent_marker_orientation::Bool
    description::String
end
struct MenuEntry <: Readable
    id::UInt32
    parent_id::UInt32
    title::String
    command::String
    command_type::UInt8
end
struct InteractiveMarker <: Readable
    header::Header
    pose::geometry_msgs.Pose
    name::String
    description::String
    scale::Float32
    menu_entries::Vector{MenuEntry}
    controls::Vector{InteractiveMarkerControl}
end
struct InteractiveMarkerInit <: Readable
    server_id::String
    seq_num::UInt64
    markers::Vector{InteractiveMarker}
end
struct InteractiveMarkerPose <: Readable
    header::Header
    pose::geometry_msgs.Pose
    name::String
end
struct InteractiveMarkerUpdate <: Readable
    server_id::String
    seq_num::UInt64
    type_::UInt8
    markers::Vector{InteractiveMarker}
    poses::Vector{InteractiveMarkerPose}
    erases::Vector{String}
end
struct MarkerArray <: Readable
    markers::Vector{Marker}
end
struct ImageMarker <: Readable
    header::Header
    ns::String
    id::Int32
    type_::Int32
    action::Int32
    position::geometry_msgs.Point
    scale::Float32
    outline_color::std_msgs.ColorRGBA
    filled::UInt8
    fill_color::std_msgs.ColorRGBA
    lifetime::ROSDuration
    points::Vector{geometry_msgs.Point}
    outline_colors::Vector{std_msgs.ColorRGBA}
end
struct InteractiveMarkerFeedback <: Readable
    header::Header
    client_id::String
    marker_name::String
    control_name::String
    event_type::UInt8
    pose::geometry_msgs.Pose
    menu_entry_id::UInt32
    mouse_point::geometry_msgs.Point
    mouse_point_valid::Bool
end
end
