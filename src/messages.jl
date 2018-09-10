
module Messages

using StaticArrays: SVector
using FastIOBuffers: FastReadBuffer


"""
Marks compound types that can be deserialised from a ROS datastream.
All fields must be Readable or Bits, or Vectors/SVectors of these.
"""
abstract type Readable end

@generated function Base.read(io::IO, ::Type{T}) where {T<:Readable}
    statements = Expr[]
    for (name, E) in zip(fieldnames(T), T.types)
        push!(statements, :($name = read_field(io, $E)))
    end
    code = quote
        $(statements...)
        $T($(fieldnames(T)...))
    end
    code
end

""" Readable values can be read with Base.read(). """
read_field(io::IO, ::Type{T}) where {T<:Readable} = read(io, T)

const Bits = Union{Bool,Signed,Unsigned,Float32,Float64}

""" Reads a scalar field, taking care of endianness. """
read_field(io::IO, ::Type{T}) where {T<:Bits} = ltoh(read(io, T))

""" Reads a variable-length string. """
function read_field(io::IO, ::Type{String})
    len = read_field(io, UInt32)
    String(read(io, len))
end

""" Reads a variable-length array. """
function read_field(io::IO, ::Type{<:Vector{E}}) where {E}
    N = read_field(io, UInt32)
    arr = Vector{E}(undef, N)
    read_array!(io, arr)
    arr
end

""" Reads a fixed-length array. """
function read_field(io::IO, ::Type{<:SVector{N,E}}) where {N,E}
    arr = Vector{E}(undef, N)
    read_array!(io, arr)
    SVector{N,E}(arr)
end

read_field(arr::Vector{UInt8}, ::Type{T}) where {T} = read_field(FastReadBuffer(arr), T)

function read_array!(io::IO, out::Vector{T}) where T
    # Generic array reading: read each element separately,
    # which includes swapping bytes as needed.
    @inbounds for i in eachindex(out)
        out[i] = read_field(io, T)
    end
    out
end

if ltoh(0xcafe) == 0xcafe
    # On little-endian hosts we can read whole Bits array in one go:
    function read_array!(io::IO, out::Vector{<:Bits})
        read!(io, out)
    end
end
export Readable, read_field, read_array!, SVector

include("ros/builtin_msgs.jl")
export Header, ROSTime, ROSTimespan, ROSDuration

end
