
using FileIO
using RobotOSData

# Load all of the sample bags:
sample_bags = [joinpath("data", name) for name in readdir("data") if endswith(name, ".bag")]
for bagfile in sample_bags
    bag = load(bagfile)
end

# Load a bag with a custom type:
include("test_types.jl")
bag = load("data/convergent_gen1.bag", TestTypes)
msgs = bag["convergent"]
@assert msgs isa Vector{MessageData{TestTypes.test_rosbag.Convergent}}

# TODO:
# - test message filters
# - test for message content
