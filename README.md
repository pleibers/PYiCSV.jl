# PYiCSV

This is a wrapper for the iCSV python library (from snowpat).
It wraps the library, instead of being a self standing julia implementation, because the Python version is maintained to follow changes in the iCSV format.
To minimize the additional workload, and avoid having conflicting file format implementations, this package is not a complete implementation of the iCSV format, but rather a wrapper for the Python library.

## Usage

There are two main functions in this library: `read` and `save`.
And the main structure is the ICSV. Containing Metadata and Fields, both provide a constructor that facilitates easy creation.

### Example

```julia
file = PYiCSV.read("path/to/file.icsv")

file.metadata.field_delimiter = "," # Change the field delimiter to a comma

PYiCSV.save("path/to/file.icsv", file; overwrite=true)
```
