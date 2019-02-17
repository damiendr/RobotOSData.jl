
using FastIOBuffers: FastReadBuffer
using DataStructures: counter
using RobotOS

""" A ROS Bag version X.Y """
abstract type Bag{X,Y} end

""" A chunked ROS bag V2.0+ """
struct ChunkedBag{X,Y,F} <: Bag{X,Y}
    file::F
    header::BagHeader
    indices::Vector{IndexData}
    chunkinfos::Vector{ChunkInfo}
    chunks::Vector{Chunk}
    connections::Vector{Connection}
    type_map::Dict{Int,DataType}
    topic_map::Dict{Int,String}
end
ChunkedBag(X, Y, file, header) = ChunkedBag{X,Y,typeof(file)}(file, header, [], [], [], [], Dict(), Dict())

Base.length(bag::ChunkedBag) = length(bag.chunks)

index!(bag::ChunkedBag, io::IO, rec::Record) = nothing
index!(bag::ChunkedBag, io::IO, rec::IndexData) = push!(bag.indices, rec)
index!(bag::ChunkedBag, io::IO, rec::ChunkInfo) = push!(bag.chunkinfos, rec)
index!(bag::ChunkedBag, io::IO, rec::Connection) = push!(bag.connections, rec)
index!(bag::ChunkedBag, io::IO, rec::Chunk) = begin
    push!(bag.chunks, rec)
    skip(io, rec.data_len)
end

function _attempt_lookup(pkgstr, typstr, msg_types)
    pkg, typ = Symbol(pkgstr), Symbol(typstr)
    for type_mod in msg_types
        return try
            package = getproperty(type_mod, pkg)
            getproperty(package, typ)
        catch
            continue
        end
    end
    nothing
end

function setup_maps!(bag::ChunkedBag, msg_types...)
    # we only want to call rostypegen() from RobotOS once...so keep
    # track of the types we didn't find in "missing"
    missing = Dict()
    for conn in bag.connections
        # (a) map connection id -> topic
        bag.topic_map[conn.conn] = conn.topic

        # (b) map connection id -> message type
        type_str = conn.header[:type] # eg. "sensor_msgs/Imu"
        pkgstr, typstr = string.(split(type_str, '/'))

        # Do we have a module that implements this message type?
        # Look for eg. type_mod.sensor_msgs.Imu
        dtype = _attempt_lookup(pkgstr, typstr, msg_types)
        if dtype != nothing
            bag.type_map[conn.conn] = dtype # found it
        else
            # mark it for RobotOS to generate
            missing[conn.conn] = (pkgstr, typstr)
        end
    end

    # try to find the missing types and mark them in
    # "found" if successful. Fails if the message definition
    # isn't found in PYTHONPATH.
    found = Dict()
    for conn in keys(missing)
        try
            pkgstr, typstr = missing[conn]
            RobotOS._rosimport(pkgstr, true, typstr)
            found[conn] = missing[conn]
        catch
            continue
        end
    end

    # at this point
    # 1) the type was not in "msg_types"
    # 2) "found" contains all the types that
    #    RobotOS can generate, so generate them.
    rostypegen(@__MODULE__) # causes reimport warnings, how to just build a single type?
    for conn in keys(found)
        try
            pkgstr, typstr = found[conn]
            # "found" may contain duplicate type that were generated
            # in this loop, so first we see if the type exists,
            # otherwise import it
            mod = try
                eval(Meta.parse("$pkgstr.msg.$typstr"))
            catch
                eval(Meta.parse("import .$pkgstr.msg"))
                eval(Meta.parse("$pkgstr.msg.$typstr"))
            end
            bag.type_map[conn] = mod
        catch
            continue
        end
    end
    bag
end

""" FileIO loader """
function load(f::File{format"ROSBAG"}, msg_types::Vararg{Module}; std_types=(RobotOSData.StdMsgs, RobotOSData.CommonMsgs))
    open(f) do s
        skipmagic(s)  # skip over the magic bytes
        version_str = readuntil(s.io, "\n")
        X,Y = parse.(Int, split(version_str, "."))
        if X == 2
            header = read(s.io, Record)::BagHeader
            bag = ChunkedBag(X, Y, f, header)
            load_bag!(bag, s.io, std_types..., msg_types...)
        else
            error("Bag version $X.$Y is not yet supported")
        end
    end
end

function load_bag!(bag::ChunkedBag, io::IO, msg_types...)
    # Skim through the first-level records (not recursing into chunks)
    # to build an inventory of the bag contents:
    while !eof(io)
        rec = read(io, Record)
        index!(bag, io, rec)
    end
    # Match connections to topics and messages to message types:
    setup_maps!(bag, msg_types...)
    if length(bag.chunks) != length(bag.chunkinfos)
        warn("Bad bag index: ChunkInfos do not match Chunks")
    end
    bag
end

function Base.show(io::IO, bag::ChunkedBag{X,Y}) where {X,Y}
    println(io, "ROS Bag v$X.$Y at $(bag.file.filename)")

    chunk_counter = counter(Symbol)
    chunksize = 0
    for chunk in bag.chunks
        chunksize += chunk.size
        comp = compression(chunk)
        push!(chunk_counter, comp == :none ? :uncompressed : comp)
    end
    unit = ""
    for outer unit in ("bytes", "kiB", "MiB", "GiB", "TiB")
        chunksize < 1024 && break
        chunksize /= 1024
    end
    print(io, join(["$c $k chunks" for (k,c) in chunk_counter], " / "))
    println(io, " with $(round(chunksize; digits=1)) $unit of message data")

    num_msgs = sum(length(index.msgs) for index in bag.indices)
    println(io, "$(num_msgs) messages in $(length(bag.connections)) topics:")
    rows = []
    for conn in bag.connections
        dtype = get(bag.type_map, conn.conn, Vector{UInt8})
        push!(rows, (" └─", conn.topic, ": ", conn.header[:type], " => ", dtype))
    end
    widths = [sum(length.(row[1:4])) for row in rows]
    pads = maximum(widths) .- widths
    for (row, pad) in zip(rows, pads)
        print(io, row[1])
        printstyled(io, row[2], color=:green)
        print(io, row[3])
        print(io, lpad("", pad))
        print(io, row[4])
        print(io, row[5])
        if row[6]==Vector{UInt8}
            printstyled(io, row[6], color=:red)
        else
            print(io, row[6])
        end
        println(io)
    end
end


""" Calls f(rec) for each record in chunk i. """
function replay(f, bag::ChunkedBag, i::Integer, filters=())
    open(bag.file) do s
        replay(f, bag, s.io, i, filters)
    end
end

""" Calls f(rec) for each record in the specified chunks. """
function replay(f, bag::ChunkedBag, indices::AbstractArray, filters=())
    open(bag.file) do s
        for i in indices
            replay(f, bag, s.io, i, filters)
        end
    end
end

function replay(f, bag::ChunkedBag, io::IO, chunk_idx::Integer, filters)
    infos = bag.chunkinfos[chunk_idx]
    if !select(filters, infos) return end
    seek(io, infos.chunk_pos)
    chunk = read(io, Record)::Chunk
    replay(f, bag, io, chunk, filters)
end

function replay(f, bag::ChunkedBag, io::IO, chunk::Chunk{:none}, filters)
    # Uncompressed chunk: we can simply parse the same io stream.
    replay_stream(f, bag, io, chunk.data_len, filters)
end

function replay(f, bag::ChunkedBag, io::IO, chunk::Chunk{:bz2}, filters)
    # Bzip2-compressed chunk: we need to expand the data first.
    compressed = read(io, chunk.data_len)
    expanded = Vector{UInt8}(undef, chunk.size)
    unbzip2!(compressed, expanded)
    chunk_io = FastReadBuffer(expanded)
    replay_stream(f, bag, chunk_io, chunk.size, filters)
end

function replay_stream(f, bag::ChunkedBag, io::IO, len::Integer, filters)
    # Parse and replay up to `len` bytes of records
    io_end = position(io) + len
    while position(io) < io_end
        rec = read(io, Record)
        replay(f, bag, io, rec, filters)
    end
end

function replay(f, bag::ChunkedBag, io::IO, msg::MessageData, filters)
    data_len = msg.data
    if select(filters, msg) # let's parse the message data then:
        dtype = get(bag.type_map, msg.conn, data_len)
        data = read(io, dtype) # defaults to reading data_len bytes
        f(MessageData(msg.conn, msg.time, data))
    else
        skip(io, data_len)
    end
end

function replay(f, bag::ChunkedBag, io::IO, rec::Record, filters)
    nothing # ignore all other record types
end

function read_messages(bag::ChunkedBag, chunk_indices, args...)
    messages = Dict{Int,Vector}()
    filters = make_filter.(Ref(bag), args)
    replay(bag, chunk_indices, filters) do msg
        out = get!(messages, msg.conn) do
            Vector{typeof(msg)}()
        end
        push!(out, msg)
    end
    for f in filters
        if isa(f, ConnectionFilter)
            return messages[f.conn]
        end
    end
    Dict(bag.topic_map[k] => v for (k,v) in pairs(messages))
end

select(filters::Tuple{}, x) = true # empty filters: include all
select(filters::Tuple, x) = all(f->select(f,x), filters)

struct ConnectionFilter
    conn::Int
end
select(filter::ConnectionFilter, msg::MessageData) = msg.conn == filter.conn
select(filter::ConnectionFilter, _) = true

select(filter::ROSTimespan, infos::ChunkInfo) =
    infos.start_time <= filter.end_time && infos.end_time >= filter.start_time
select(filter::ROSTimespan, msg::MessageData) = msg.time in filter
select(filter::ROSTimespan, _) = true

make_filter(bag, ts::ROSTimespan) = ts
make_filter(bag, s::String) = begin
    for (i,topic) in bag.topic_map
        if topic == s
            return ConnectionFilter(i)
        end
    end
    error("No such topic: $s")
end

Base.getindex(bag::ChunkedBag, i::Integer, filters...) = read_messages(bag, i, filters...)
Base.getindex(bag::ChunkedBag, i::AbstractArray, filters...) = read_messages(bag, i, filters...)
Base.getindex(bag::ChunkedBag, ::Colon, filters...) = read_messages(bag, eachindex(bag.chunkinfos), filters...)
Base.getindex(bag::ChunkedBag, filters...) = getindex(bag, :, filters...)

import TranscodingStreams
import TranscodingStreams: Memory, Error
import CodecBzip2: transcode, Bzip2Decompressor

""" Decode Bzip2 with minimal memory allocations """
function unbzip2!(input::Vector{UInt8}, output::Vector{UInt8})
    err = Error()
    codec = Bzip2Decompressor()
    TranscodingStreams.startproc(codec, :x, err)
    TranscodingStreams.haserror(err) && throw(err[])
    din, dout, status = TranscodingStreams.process(
        codec,
        Memory(pointer(input), length(input)),
        Memory(pointer(output), length(output)),
        err)
    TranscodingStreams.haserror(err) && throw(err[])
    status != :end && error("Bzip2: not the end")
    TranscodingStreams.finalize(codec)
    nothing
end
