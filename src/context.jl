"""
$(TYPEDSIGNATURES)
Create a context with the provided container.
"""
function Context(id::UInt, container::T) where {T}
    verbose_log(id, "creating new context $id with container $T")
    history = Stack{T}()
    push!(history, container)
    return Context(id, history)
end

"""
$(TYPEDSIGNATURES)
Save the current context to history.
"""
function save(c::Context)
    # verbose_log(c, "saving context")
    push!(getfield(c, :history), deepcopy(c.data))
end

"""
$(TYPEDSIGNATURES)
Restore to the last saved context.
"""
function restore(c::Context)
    # verbose_log(c, "restoring context")
    pop!(getfield(c, :history))
end

# Extensions to Base functions

function Base.show(io::IO, c::Context)
    print(io, "Context(id=", c.hex_id, ",generations=", c.generations, ")")
end

# Standard context management

function Base.push!(c::Context, entry)
    verbose_log(c, "Appending to context ", c.hex_id, " with ", entry)
    push!(c.data, entry)
end

Base.getindex(c::Context, index) = c.data[index]

Base.empty!(c::Context) = empty!(c.data)

Base.length(c::Context) = length(c.data)

# Property interface

Base.propertynames(c::Context) = (:id, :data, :generations)

function Base.getproperty(c::Context, s::Symbol)
    s === :id && return getfield(c, :id)
    s === :data && return first(getfield(c, :history))
    s === :generations && return length(getfield(c, :history))
    s === :hex_id && return string("0x", string(getfield(c, :id); base = 16))
    throw(UndefVarError("$s is not a valid property name."))
end

