# ROSData

[![Build Status](https://travis-ci.org/damiendr/ROSData.jl.svg?branch=master)](https://travis-ci.org/damiendr/ROSData.jl) [![codecov.io](http://codecov.io/github/damiendr/ROSData.jl/coverage.svg?branch=master)](http://codecov.io/github/damiendr/ROSData.jl?branch=master)

A collection of tools to read data from [ROS bags](http://wiki.ros.org/Bags/) and [messages](http://wiki.ros.org/Messages) in Julia.

This package has no dependencies on the ROS codebase: you can use it without a working ROS install.

Only ROS bags v2.0 are supported at the moment.

## Usage

First define the topic we're interested in and what to do with the raw messages:
```julia
sub = Subscription("/davis/left/events") do io
    # Read the standard message Header:
    header = read(io, ROSData.Header)
    # Read some values:
    value = ltoh(read(io, UInt32))
    array = read_array(io, Float32)
    text = read_string(io)
    ... do something with these values
end
```

Now open the bag and process the subscription:
```julia
open("indoor_flying1_data.bag") do io
    bag = Bag(io)
    read_topics(bag, sub)
end
```

To process multiple topics at once, pass more than one subscription object: `read_topics(bag, sub1, sub2, ...)`.

To read custom message types and arrays thereof, define: `Base.read(io::IO, ::Type{MyType}) = ...`. Remember that ROS bags are little-endian, so liberal use of `ltoh()` is needed to ensure that your code will work on a big-endian host.

