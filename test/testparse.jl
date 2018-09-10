using FileIO
using RobotOSData
bag = load("/Users/plantagenet/Code/phd/papers/spikingdendrites/experiments/indoor_flying1_data.bag")
s = open(bag.file)
seek(s.io, bag.offset)
read(s.io, RobotOSData.Record)
read(s.io, RobotOSData.Record)
read(s.io, RobotOSData.Record)
read(s.io, RobotOSData.Record)
read(s.io, RobotOSData.Record)
read(s.io, RobotOSData.Record)
r = read(s.io, RobotOSData.Record)
println(r)
