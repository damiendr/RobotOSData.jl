
abstract type Record end

const HeaderDict = Dict{Symbol,Vector{UInt8}}

function Base.read(io::IO, ::Type{Record})
    header_len = read_field(io, UInt32)
    header = read_dict(io, header_len)
    data_len = read_field(io, UInt32)

    op = header[:op][1]
    Record(io, op, header, data_len)
end

function Record(io, op, header, data_len)
    if op == 0x02 MessageData(header, io, data_len)
    elseif op == 0x03 BagHeader(header, io, data_len)
    elseif op == 0x04 IndexData(header, io, data_len)
    elseif op == 0x05 Chunk(header, io, data_len)
    elseif op == 0x06 ChunkInfo(header, io, data_len)
    elseif op == 0x07 Connection(header, io, data_len)
    else Raw(header, io, data_len)
    end
end

function read_keyvalue(io)
    pair_len = read_field(io, Int32)
    key_name = readuntil(io, "=")
    length(key_name) >= pair_len && error("Malformed field: $key_name, $pair_len")
    value_len = pair_len - length(key_name) - 1
    key = Symbol(key_name)
    value = read(io, value_len)
    return key, value
end

function read_dict(io, header_len)
    header_end = position(io) + header_len
    fields = HeaderDict()
    while position(io) < header_end
        key, value = read_keyvalue(io)
        fields[key] = value
    end
    position(io) != header_end && error("Malformed header")
    fields
end

struct Raw <: Record
    header::Dict{Symbol,Vector{UInt8}}
    data::Vector{UInt8}
end
Raw(header, io::IO, data_len) = Raw(header, read(io, data_len))


struct BagHeader <: Record
    index_pos::Int64
    conn_count::Int32
    chunk_count::Int32
    data_len::UInt32
end

function BagHeader(header::HeaderDict, io::IO, data_len)
    index_pos = read_field(header[:index_pos], Int64)
    conn_count = read_field(header[:conn_count], Int32)
    chunk_count = read_field(header[:chunk_count], Int32)
    skip(io, data_len)
    BagHeader(index_pos, conn_count, chunk_count, data_len)
end


struct Chunk{C} <: Record
    size::UInt32
    data_len::UInt32
end

compression(::Chunk{C}) where {C} = C

function Chunk(header::HeaderDict, io::IO, data_len)
    compression = Symbol(String(header[:compression]))
    size = read_field(header[:size], Int32)
    Chunk{compression}(size, data_len)
end

struct MsgIndex <: Readable
    time::ROSTime
    offset::UInt32
end

struct IndexData <: Record
    ver::Int32
    conn::Int32
    msgs::Vector{MsgIndex}
end

function IndexData(header::HeaderDict, io::IO, data_len)
    ver = read_field(header[:ver], Int32)
    conn = read_field(header[:conn], Int32)
    count = read_field(header[:count], Int32)
    msgs = Vector{MsgIndex}(undef, count)
    read_array!(io, msgs)
    IndexData(ver, conn, msgs)
end


struct Connection <: Record
    conn::Int32
    topic::String
    header::Dict{Symbol,String}
end

function Connection(header::HeaderDict, io::IO, data_len)
    conn = read_field(header[:conn], Int32)
    topic = String(header[:topic])
    infos = read_dict(io, data_len)
    Connection(conn, topic, Dict(k=>String(v) for (k,v) in pairs(infos)))
end


struct MsgCount <: Readable
    conn::Int32
    count::UInt32
end

struct ChunkInfo <: Record
    ver::Int32
    chunk_pos::UInt64
    start_time::ROSTime
    end_time::ROSTime
    counts::Vector{MsgCount}
end

function ChunkInfo(header::HeaderDict, io::IO, data_len)
    ver = read_field(header[:ver], Int32)
    chunk_pos = read_field(header[:chunk_pos], Int64)
    start_time = read_field(header[:start_time], ROSTime)
    end_time = read_field(header[:end_time], ROSTime)
    count = read_field(header[:count], Int32)
    counts = Vector{MsgCount}(undef, count)
    read_array!(io, counts)
    ChunkInfo(ver, chunk_pos, start_time, end_time, counts)
end


struct MessageData{T} <: Record
    conn::Int32
    time::ROSTime
    data::T
end

function MessageData(header::HeaderDict, io::IO, data_len)
    conn = read_field(header[:conn], Int32)
    time = read_field(header[:time], ROSTime)
    MessageData(conn, time, data_len)
end


# ==================================================================


struct MessageV1
    topic::String
    md5sum::String
    msg_type::String
    time_s::UInt32
    time_ns::UInt32
    data::Vector{UInt8}
end

function Base.read(io::IO, ::Type{MessageV1})
    topic = readuntil(io, "\n")
    md5sum = readuntil(io, "\n")
    msg_type = readuntil(io, "\n")
    time_s = read_field(io, UInt32)
    time_ns = read_field(io, UInt32)
    data_len = read_field(io, UInt32)
    data = read(io, data_len)
    MessageV1(topic, md5sum, msg_type, time_s, time_ns, data)
end

# struct Fields
#     names::Vector{Symbol}
#     values::Vector{Vector{UInt8}}
# end

# function Fields()
#     f = Fields(Symbol[], Vector{UInt8}[])
#     sizehint!(f.names, 8)
#     sizehint!(f.values, 8)
#     f
# end

# function Base.getindex(f::Fields, s::Symbol)
#     @inbounds for i in eachindex(f.names)
#         if f.names[i] == s
#             return f.values[i]
#         end
#     end
#     throw(KeyError(s))
# end

# function Base.setindex!(f::Fields, v, s::Symbol)
#     push!(f.names, s)
#     push!(f.values, v)
# end

# function Base.pairs(f::Fields)
#     [k=>v for (k,v) in zip(f.names, f.values)]
# end