
import Dates: DateTime, Period, Second, Nanosecond, unix2datetime, datetime2unix

struct ROSTime <: Readable
    secs::UInt32
    nsecs::UInt32
end
ROSTime(d::DateTime) = convert(ROSTime, d)
ROSTime(s::String) = begin
    # We could just call ROSTime(DateTime(s)), but
    # let's be extra nice and parse nanoseconds.
    point = findlast(".", s)
    if point != nothing
        frac = parse(Float64, s[first(point):end])
        nsecs = 1000000000*frac
        secs = datetime2unix(DateTime(s[1:first(point)-1]))
    else
        nsecs = 0.0
        secs = datetime2unix(DateTime(s))
    end
    ROSTime(trunc(UInt32, secs), trunc(UInt32, nsecs))
end
Base.convert(::Type{UInt64},   t::ROSTime) = UInt64(t.secs) << 32 + t.nsecs
Base.convert(::Type{DateTime}, t::ROSTime) = unix2datetime(t.secs) + Nanosecond(t.nsecs)
# Note: converting ROSTime to DateTime will truncate to millisecond precision
Base.convert(::Type{ROSTime},  d::DateTime) = begin
    ms = round(Int64, datetime2unix(d) * 1000)
    ROSTime(ms ÷ 1000, (ms % 1000) * 1000000)
end

Base.isequal(t1::ROSTime, t2::ROSTime) = convert(UInt64, t1) == convert(UInt64, t2)
Base.isless(t1::ROSTime, t2::ROSTime) = convert(UInt64, t1) < convert(UInt64, t2)

function Base.show(io::IO, t::ROSTime)
    dt = unix2datetime(t.secs)
    print(io, typeof(t), "(\"", dt, ".", lpad(string(t.nsecs), 9, '0'), "\")")
end


struct ROSDuration <: Readable
    secs::Int32
    nsecs::Int32
end
Base.convert(::Type{Period}, t::ROSDuration) = Second(t.secs) + Nanosecond(t.nsecs)

import Base: -, +
time_normed(T, secs, nsecs) = T(secs + nsecs ÷ 1000000000, nsecs % 1000000000)
time_op(T, op, t1, t2) = time_normed(T, op(t1.secs, t2.secs), op(t1.nsecs, t2.nsecs))
-(t1::ROSDuration, t2::ROSDuration) = time_op(ROSDuration, -, t1, t2)
+(t1::ROSDuration, t2::ROSDuration) = time_op(ROSDuration, +, t1, t2)
-(t1::ROSTime,     t2::ROSDuration) = time_op(ROSTime, -, t1, t2)
+(t1::ROSTime,     t2::ROSDuration) = time_op(ROSTime, +, t1, t2)
-(t1::ROSTime,     t2::ROSTime)     = time_op(ROSDuration, (a,b)->Int64(a)-Int64(b), t1, t2)


struct ROSTimespan
    start_time::ROSTime
    end_time::ROSTime
end
(::Colon)(t1::ROSTime, t2::ROSTime) = ROSTimespan(t1, t2)
Base.in(t, span::ROSTimespan) = t.start_time <= ROSTime(t) <= t.end_time


struct Header <: Readable
    seq::UInt32
    time::ROSTime
    frame_id::String
end
