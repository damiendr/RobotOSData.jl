

t1 = ROSTime("2017-09-05T20:59:37.436169304")
t2 = ROSTime("2017-09-05T20:59:39.1234")

# Test time comparison:
@assert t2 > t1

# Test roundtrip through repr:
@assert eval(Meta.parse(repr(t1))) == t1
@assert eval(Meta.parse(repr(t2))) == t2
