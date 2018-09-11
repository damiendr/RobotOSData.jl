module TestTypes
    module test_rosbag
        using RobotOSData.Messages
        struct SimpleMigrated <: Readable
            data::Int32
        end
        struct Convergent <: Readable
            field1_a::Float32
            field1_b::Float32
            field1_c::Float32
            field1_d::Float32
            field2_a::SimpleMigrated
            field2_b::SimpleMigrated
            field2_c::SimpleMigrated
            field2_d::SimpleMigrated            
        end
    end
end

