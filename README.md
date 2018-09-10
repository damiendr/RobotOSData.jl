# RobotOSData

[![Build Status](https://travis-ci.org/damiendr/RobotOSData.jl.svg?branch=master)](https://travis-ci.org/damiendr/RobotOSData.jl) [![codecov.io](http://codecov.io/github/damiendr/RobotOSData.jl/coverage.svg?branch=master)](http://codecov.io/github/damiendr/RobotOSData.jl?branch=master)

A library to read data from [ROS bags](http://wiki.ros.org/Bags/) and [messages](http://wiki.ros.org/Messages) in Julia.

This package has no dependencies on the ROS codebase: you can use it without a working ROS install.

Only ROS bags v2.0 are supported at the moment. If you'd like support for earlier versions, do open an issue and submit a sample bag file or a pull request (I have been unable to find any older bags in the wild).

Reading from uncompressed bags is pretty fast (600 MB/s on my laptop). Bags with BZip2 compression are supported, but reading these is currently about two orders of magnitude slower; this seems to be an issue with `libbzip2` itself.

## Basic Usage

Load a bag file through FileIO:
```julia
using FileIO
bag = load("indoor_flying1_data.bag")
```

This parses the index structure and shows a summary of the contents:
```
ROS Bag v2.0 at indoor_flying1_data.bag
1437 uncompressed chunks with 1.2 GiB of message data
154942 messages in 9 topics:
 └─/davis/right/imu:                sensor_msgs/Imu => RobotOSData.CommonMsgs.sensor_msgs.Imu
 └─/davis/left/imu:                 sensor_msgs/Imu => RobotOSData.CommonMsgs.sensor_msgs.Imu
 └─/davis/right/events:         dvs_msgs/EventArray => Array{UInt8,1}
 └─/davis/left/events:          dvs_msgs/EventArray => Array{UInt8,1}
 └─/davis/left/camera_info:  sensor_msgs/CameraInfo => RobotOSData.CommonMsgs.sensor_msgs.CameraInfo
 └─/davis/left/image_raw:         sensor_msgs/Image => RobotOSData.CommonMsgs.sensor_msgs.Image
 └─/velodyne_point_cloud:   sensor_msgs/PointCloud2 => RobotOSData.CommonMsgs.sensor_msgs.PointCloud2
 └─/davis/right/camera_info: sensor_msgs/CameraInfo => RobotOSData.CommonMsgs.sensor_msgs.CameraInfo
 └─/davis/right/image_raw:        sensor_msgs/Image => RobotOSData.CommonMsgs.sensor_msgs.Image
```
Note how the standard ROS messages are resolved to a Julia type, while topics with the non-standard type "dvs_msgs/EventArray" will be parsed as raw `Array{UInt8,1}`. See below to add support non-standard types.

To read the message data, use one of the following:
```julia
using RobotOSData
bag[:] # read all messages
bag[1:4] # read chunks 1 to 4
bag["/davis/right/imu"]
bag[ROSTime("2017-09-05T20:59:40"):ROSTime("2017-09-05T21:00:00")]
```

## Message Types

RobotOSData comes with parsers for the message types in the ROS packages `std_msgs` and `common_msgs`, and these are enabled by default. To disable them, use the following:
```julia
bag = load("indoor_flying1_data.bag"; std_types=[])
```
In the absence of a suitable parser, the message data will be read as raw bytes.

## Writing new message types

If you want to support a new message type, for instance `my_ros_pkg/NewMsgType`, you can do so as follows:

```julia
bag = load("recording.bag", ExtraMessages)
```

```julia
module ExtraMessages
    module my_ros_pkg
        using RobotOSData.Messages # imports Readable, Header
        using RobotOSData.StdMsgs
        using RobotOSData.CommonMsgs # for sensor_msgs
        using OtherMessages # imports another_pkg
        struct NewMsgType <: Readable
            header::Header
            imu::sensor_msgs.Imu
        end
        # Readable already handles the parsing for you.        
        # You could also write your own parser:
        #    read(io::IO, ::Type{NewMsgType})
        # Have a look at the read_field() methods.
    end
end
```

## Auto-generating message types

RobotOSData provides a tool that lets you generate modules like the one above from the `.msg` files in a ROS package. To keep things simple, this tool does not try to resolve the dependencies between packages — it is up to you to indicate them. It will, however, handle dependencies between message files in the same package.

```julia
RobotOSData.gen_module(:ExtraMessages, ["path/to/my_ros_pkg"], "path/to/dest/dir", :(RobotOSData.StdMsgs), :(RobotOSData.CommonMsgs))
```
