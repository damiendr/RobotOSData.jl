
# Test creating ROS times from strings:
t1 = ROSTime("2017-09-05T20:59:37.436169304")
t2 = ROSTime("2017-09-05T20:59:39.1234")
t3 = ROSTime("2017-09-05T20:59:40.123401")

# Time comparison:
@assert t2 > t1

# Time arithmetics:
@assert t3 - t2 == ROSDuration(1, 1000)

# Roundtrip through repr and parse:
@assert eval(Meta.parse(repr(t1))) == t1
@assert eval(Meta.parse(repr(t2))) == t2
