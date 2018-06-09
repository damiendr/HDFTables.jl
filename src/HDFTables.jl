module HDFTables

using HDF5
using DataFrames


struct Table{T,N}
    columns::NTuple{N,Symbol}
    rows::Vector{T}
end
export Table


function table_type(obj::HDF5Dataset)
    objtype = HDF5.datatype(obj)
    class_id = HDF5.h5t_get_class(objtype.id)
    if class_id == HDF5.H5T_COMPOUND
        n = Int(HDF5.h5t_get_nmembers(objtype.id))
        field_names = Symbol[]
        field_types = DataType[]
        for i in 0:n-1
            field_tid = HDF5.h5t_get_member_type(objtype.id, i)
            field_type = HDF5.hdf5_to_julia_eltype(HDF5Datatype(field_tid))
            field_name = HDF5.h5t_get_member_name(objtype.id, i)
            push!(field_names, Symbol(field_name))
            push!(field_types, field_type)
        end
        T = Tuple{field_types...}
        return T, tuple(field_names...)
    else
        error("Dataset is not a table")
    end
end


function make_memtype(T::Type{<:Tuple}, field_names)
    memtype_id = HDF5.h5t_create(HDF5.H5T_COMPOUND, sizeof(T))
    for (i, ftype) in enumerate(T.types)
        HDF5.h5t_insert(memtype_id, string(field_names[i]), fieldoffset(T,i), HDF5.datatype(ftype))
    end
    memtype_id
end

# Read compound type
function read_table(obj::HDF5Dataset)
    T, field_names = table_type(obj)

    # Build a datatype that reflects the memory layout of the Julia type:
    memtype_id = make_memtype(T, field_names)
    
    # Allocate the destination array:
    space = HDF5.dataspace(obj);
    dims, maxdims = HDF5.get_dims(space)
    data = Array{T}(dims...)

    # Read the data using HDF5's built-in data layout conversion:
    status = HDF5.readarray(obj, memtype_id, data)
    status < 0 && error("Couldn't read table: $status")

    Table(field_names, data)
end
export read_table

column(table::Table, i::Int) = collect(row[i] for row in table.rows)

function Base.convert(::Type{DataFrame}, t::Table)
    cols = [column(t, i) for i in eachindex(t.columns)]
    DataFrame(cols, Symbol[t.columns...])
end

end # module
