
read_ltoh(io::IO, T) = read(io, T)
read_ltoh(io::IO, T::Type{<:Union{Signed,Unsigned,Float32,Float64}}) = ltoh(read(io, T))

""" The standard ROS message header """
struct Header
    seq::UInt32
    time_s::UInt32
    time_ns::UInt32
    frame_id::String
end

function Base.read(io::IO, ::Type{Header})
    seq = read_ltoh(io, UInt32)
    time_s = read_ltoh(io, UInt32)
    time_ns = read_ltoh(io, UInt32)
    frame_id = read_string(io)
    Header(seq, time_s, time_ns, frame_id)
end

function read_array(io::IO, ::Type{E}) where {E}
    len = ltoh(read(io, UInt32))
    E[read_ltoh(io, E)::E for _ in 1:len]
end

function read_array!(out::Vector{E}, io::IO, ::Type{E}) where {E}
    len = read_ltoh(io, UInt32)
    for _ in 1:len
        push!(out, read_ltoh(io,E)::E)
    end
end

function read_string(io::IO)
    len = read_ltoh(io, UInt32)
    String(read(io, len))
end

