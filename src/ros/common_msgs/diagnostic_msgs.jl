# !! auto-generated code, do not edit !!
module diagnostic_msgs
using RobotOSData.Messages
using RobotOSData.StdMsgs
using RobotOSData.CommonMsgs
struct KeyValue <: Readable
    key::String
    value::String
end
struct DiagnosticStatus <: Readable
    level::UInt8
    name::String
    message::String
    hardware_id::String
    values::Vector{KeyValue}
end
struct DiagnosticArray <: Readable
    header::Header
    status::Vector{DiagnosticStatus}
end
end
