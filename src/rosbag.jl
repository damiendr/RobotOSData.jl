
using CodecBzip2

struct Bag{X,Y,I<:IO}
    io::I
end

export Bag

const HEADER_RE = r"#ROSBAG V(\d)\.(\d)\n"
const HEADER_BYTES = 13

function Bag(io::IO)
    head_str = convert(String, read(io, HEADER_BYTES))
    head_match = match(HEADER_RE, head_str)
    if head_match != nothing
        # Found a header. Let's parse the version
        # number:
        X = parse(head_match.captures[1])::Int
        Y = parse(head_match.captures[2])::Int
        return Bag{X,Y,typeof(io)}(io)
    else
        error("Couldn't find a ROSBAG header")
    end
end

struct RawRecord
    header::Vector{UInt8}
    data::Vector{UInt8}
end

function Base.read(io::IO, ::Type{RawRecord})
    header_len = ltoh(read(io, UInt32))
    header = read(io, header_len)
    data_len = ltoh(read(io, UInt32))
    data = read(io, data_len)
    RawRecord(header, data)
end

struct BagHeader
    index_pos::Int64
    conn_count::Int32
    chunk_count::Int32
end

function BagHeader(fields::Dict{Symbol,Vector{UInt8}})
    index_pos = ltoh(reinterpret(Int64, fields[:index_pos])[1])
    conn_count = ltoh(reinterpret(Int32, fields[:conn_count])[1])
    chunk_count = ltoh(reinterpret(Int32, fields[:chunk_count])[1])
    BagHeader(index_pos, conn_count, chunk_count)
end

struct Chunk{C}
    size::Int32
end

function Chunk(fields::Dict{Symbol,Vector{UInt8}})
    compression = Symbol(convert(String, fields[:compression]))
    size = ltoh(reinterpret(Int32, fields[:size])[1])
    Chunk{compression}(size)
end

struct IndexData
    ver::Int32
    conn::Int32
    count::Int32
end

function IndexData(fields::Dict{Symbol,Vector{UInt8}})
    ver = ltoh(reinterpret(Int32, fields[:ver])[1])
    conn = ltoh(reinterpret(Int32, fields[:conn])[1])
    count = ltoh(reinterpret(Int32, fields[:count])[1])
    IndexData(ver, conn, count)
end


struct MessageData
    conn::Int32
    time::Int64
end

function MessageData(fields::Dict{Symbol,Vector{UInt8}})
    conn = ltoh(reinterpret(Int32, fields[:conn])[1])
    time = ltoh(reinterpret(Int64, fields[:time])[1])
    MessageData(conn, time)
end


struct Connection
    conn::Int32
    topic::String
end

function Connection(fields::Dict{Symbol,Vector{UInt8}})
    conn = ltoh(reinterpret(Int32, fields[:conn])[1])
    topic = convert(String, fields[:topic])
    Connection(conn, topic)
end

function parse_record_header(header::Vector{UInt8})
    fields = Dict{Symbol,Vector{UInt8}}()
    io = IOBuffer(header)
    while !eof(io)
        field_len = ltoh(read(io, UInt32))
        field_name = readuntil(io, "=")
        value_len = field_len - length(field_name)
        @assert value_len > 0
        field_value = read(io, value_len)
        fields[Symbol(field_name[1:end-1])] = field_value
    end
    fields
end

""" Creates an IO stream from the record's data """
decode(header, data) = IOBuffer(data)
decode(header::Chunk{:bz2}, data) = Bzip2DecompressorStream(IOBuffer(data))


""" A subscription to a topic. """
mutable struct Subscription{F<:Function}
    topic::String   # topic name eg. /data/events
    conn::Int32     # connection ID, once known
    on_msg::F       # callback to process messages
end

""" Subscribe to the given topic, processing each message with `f(io)`. """
Subscription(f::Function, topic::String) = Subscription(topic, Int32(-1), f)

""" Reads a bag and dispatches messages that match the requested topic. """
read_topic(bag::Bag, sub::Subscription) = read(bag.io, sub)

# Read a stream of raw records:
function Base.read(io::IO, sub::Subscription)
    while !eof(io)
        rec = read(io, RawRecord)
        parse_record!(rec, sub)
    end
end

""" Parses a raw record and dispatches it according to its type. """
function parse_record!(rec::RawRecord, dest)
    fields = parse_record_header(rec.header)
    op = fields[:op][1]
    if op == 0x03 read_record!(BagHeader(fields), rec.data, dest)
    elseif op == 0x05 read_record!(Chunk(fields), rec.data, dest)
    elseif op == 0x07 read_record!(Connection(fields), rec.data, dest)
    elseif op == 0x02 read_record!(MessageData(fields), rec.data, dest)
    elseif op == 0x04 read_record!(IndexData(fields), rec.data, dest)
    end
end

# Ignore records we don't know how to handle:
read_record!(header, data, sub::Subscription) = nothing

# Recurse into Chunks:
function read_record!(header::Chunk, data, sub::Subscription)
    io = decode(header, data)
    read(io, sub)
end

# Get a connection ID for our topic:
function read_record!(header::Connection, data, sub::Subscription)
    if header.topic == sub.topic
        sub.conn = header.conn
    end
end

# Decode messages that match our topic:
function read_record!(header::MessageData, data, sub::Subscription)
    if header.conn == sub.conn
        sub.on_msg(decode(header, data))
    end
end

