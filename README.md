# HDFTables

A simple library for reading HDF5 tables (including those created by PyTables) more efficiently than using the built-in methods from HDF5.jl.

[![Build Status](https://travis-ci.org/damiendr/HDFTables.jl.svg?branch=master)](https://travis-ci.org/damiendr/HDFTables.jl)

[![Coverage Status](https://coveralls.io/repos/damiendr/HDFTables.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/damiendr/HDFTables.jl?branch=master)

[![codecov.io](http://codecov.io/github/damiendr/HDFTables.jl/coverage.svg?branch=master)](http://codecov.io/github/damiendr/HDFTables.jl?branch=master)

## Usage

Locate your dataset using `HDF5.jl`:

```julia
using HDF5
file = h5open("outdoors_walking.h5", "r")
dset = file["events"]
```
```
HDF5 dataset: /events (file: outdoors_walking.h5xfer_mode: 0 )
```

Read the data as a vector of Tuples:
```julia
@time events = read_table(dset)
```
```
0.307447 seconds (113.14 k allocations: 21.429 MiB, 2.57% gc time)
HDFTables.Table{Tuple{Float64,Int16,Int16,Int8},4}((:timestamp, :x, :y, :polarity), Tuple{Float64,Int16,Int16,Int8}[(0.0, 43, 140, 1), (8.2999e-5, 43, 141, 1), (0.000149999, 43, 139, 1), (0.000157, 40, 141, 1), (0.000161999, 44, 141, 1), (0.000174, 44, 144, 1), (0.000272, 47, 7, 1), (0.000281999, 164, 170, 1), (0.000371999, 44, 139, 1), (0.000379, 40, 139, 1)  …  (4.89413, 158, 91, 1), (4.89413, 96, 21, 1), (4.89414, 78, 168, 1), (4.89414, 219, 163, 0), (4.89414, 11, 177, 0), (4.89416, 37, 107, 0), (4.89416, 98, 73, 1), (4.89416, 84, 5, 0), (4.89416, 103, 20, 1), (4.89416, 8, 76, 1)])
```

Convert to a DataFrame:
```julia
df = convert(DataFrame, events)
```
```
1000000×4 DataFrames.DataFrame
│ Row     │ timestamp │ x   │ y   │ polarity │
├─────────┼───────────┼─────┼─────┼──────────┤
│ 1       │ 0.0       │ 43  │ 140 │ 1        │
│ 2       │ 8.2999e-5 │ 43  │ 141 │ 1        │
⋮
│ 999998  │ 4.89416   │ 84  │ 5   │ 0        │
│ 999999  │ 4.89416   │ 103 │ 20  │ 1        │
│ 1000000 │ 4.89416   │ 8   │ 76  │ 1        │
```

In comparison, the built-in `read()` is slow:
```julia
@time read(dset)
```
```
4.676015 seconds (17.00 M allocations: 486.796 MiB, 14.54% gc time)
1000000-element Array{HDF5.HDF5Compound{4},1}:
 HDF5.HDF5Compound{4}((0.0, 43, 140, 1), ("timestamp", "x", "y", "polarity"), (Float64, Int16, Int16, Int8))         
 HDF5.HDF5Compound{4}((8.2999e-5, 43, 141, 1), ("timestamp", "x", "y", "polarity"), (Float64, Int16, Int16, Int8))
 ...   
```


