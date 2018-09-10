
using Tokenize
using DataStructures

const builtin_types = Dict{Symbol,Symbol}(
    :time => :ROSTime,
    :duration => :ROSDuration,
    :Header=>:Header,
    :char=>:UInt8,
    :byte=>:UInt8
)

const types_to_map = DataType[
    Bool, String, Float32, Float64,
    UInt8, UInt16, UInt32, UInt64,
    Int8, Int16, Int32, Int64
]
for T in types_to_map
    builtin_types[Symbol(lowercase(String(nameof(T))))] = nameof(T)
end

function parse_msg(io::IO)
    defs = []
    for line in eachline(io)
        parts = Tokenize.Tokens.Token[]
        for token in tokenize(line)
            if token.kind in (Tokenize.Tokens.COMMENT, Tokenize.Tokens.ENDMARKER)
                break
            elseif token.kind == Tokenize.Tokens.WHITESPACE
                continue
            else
                push!(parts, token)
            end
        end
        if length(parts) > 0
            push!(defs, parts)
        end
    end
    defs
end

function julia_sym(token)
    val = Tokenize.untokenize(token)
    if Tokenize.Tokens.kind(token) == Tokenize.Tokens.KEYWORD
        # escape keywords:
        Symbol("$(val)_")
    else
        Symbol(val)
    end
end

function make_struct(parent_pkg::Symbol, name::Symbol, lines)

    fields = Expr[]
    deps = Set{Tuple{Symbol,Symbol}}()
    
    for tokens in lines
        i = 0
        next() = if i >= length(tokens) nothing
                 else tokens[(i+=1)]
                 end
        t = next()

        decl = julia_sym(t)
        t = next()

        if t.kind == Tokenize.Tokens.FWD_SLASH
            typ = julia_sym(next())
            push!(deps, (decl, typ))
            decl = Expr(:(.), decl, QuoteNode(typ))
            t = next()
        else
            decl = get(builtin_types, decl) do
                push!(deps, (parent_pkg, decl))
                decl
            end
        end
        
        if t.kind == Tokenize.Tokens.LSQUARE
            t = next()
            if t.kind == Tokenize.Tokens.INTEGER
                N = parse(Int,t.val)
                decl = Expr(:curly, :SVector, N, decl)
                t = next()
            elseif t.kind == Tokenize.Tokens.RSQUARE
                decl = Expr(:curly, :Vector, decl)
            end
            t.kind != Tokenize.Tokens.RSQUARE && error("mismatched brakets")
            t = next()
        end
        
        decl = Expr(:(::), julia_sym(t), decl)
        t = next()
        
        if t == nothing
            push!(fields, decl)
        elseif t.kind == Tokenize.Tokens.EQ
            # TODO constant
        end
    end
    
    Expr(:struct, false, Expr(:<:, name, :Readable), Expr(:block, fields...)), deps
end

function add_struct!(out::OrderedDict, pkg::Symbol, lib, name::Symbol)
    if haskey(out, name)
        return
    end
    expr, deps = lib[name]
    for (modname, sym) in deps
        if modname == pkg
            add_struct!(out, pkg, lib, sym)
        end
    end
    out[name] = expr
    nothing
end

function gen_package(package::Symbol, msg_dir::String, deps)
    structs = Dict()
    for msg_file in readdir(msg_dir)
        base, ext = splitext(msg_file)
        typename = Symbol(base)
        if typename in nameof.(types_to_map)
            println("Skipping built-in $typename")
            continue
        end
        tokens = open(parse_msg, joinpath(msg_dir, msg_file), "r")
        structs[typename] = make_struct(package, typename, tokens)
    end

    # depends = Set{Symbol}()
    decls = OrderedDict{Symbol,Expr}()
    for (sname, (expr, _)) in pairs(structs)
        add_struct!(decls, package, structs, sname)
        # for (pkg, item) in deps
        #     if pkg != package
        #         push!(depends, pkg)
        #     end
        # end
    end

    imports = [:(using $m) for m in deps]
    definitions = [expr for (_, expr) in decls]
    code = Expr(:block,
        :(using RobotOSData.Messages),
        imports...,
        definitions...)
    Expr(:module, true, package, code)
end

function gen_package(package::Symbol, msg_dir::String, io::IO, deps)
    code = gen_package(package, msg_dir, deps)
    println(io, "# !! auto-generated code, do not edit !!")
    println(io, code)
end

function gen_package_file(src::String, dst::String, deps...)
    fname = basename(src)
    msg_dir = joinpath(src, "msg")
    if !isdir(msg_dir) return end
    println("Processing $msg_dir")
    pkg = Symbol(fname)
    pkg_file = "$fname.jl"
    pkg_path = joinpath(dst, pkg_file)
    println("Writing to $pkg_path")
    open(pkg_path, "w") do io
        gen_package(pkg, msg_dir, io, deps)
    end
    pkg_file, pkg
end

function gen_module(mod_name::Symbol, ros_pkg_roots::Vector{String}, dst_dir::String, deps...)
    statements = Expr[]
    for src_dir in ros_pkg_roots
        filename, pkg_name = gen_package_file(src_dir, dst_dir, deps...)
        push!(statements, :(include($filename)))
        push!(statements, :(export $pkg_name))        
    end

    mod_code = Expr(:module, true, mod_name, Expr(:block, statements...))

    mod_path = joinpath(dst_dir, "$mod_name.jl")    
    open(mod_path, "w") do io
        print(io, mod_code)
    end
end
