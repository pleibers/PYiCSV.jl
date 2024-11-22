# iCSV

This is a wrapper for the iCSV python library used to read and write [iCSV](https://envidat.gitlab-pages.wsl.ch/icsv/) files.
It wraps the library, since it is maintained to follow changes in the iCSV format. And to avoid to maintain a second library, we just wrap it.

## Usage

There are two main functions in this library: `read` and `save`.
And the main structure is the ICSV. Containing Metadata and Fields, both provide a constructor that facilitates easy creation.

### Example

```julia
file = iCSV.read("path/to/file.icsv")

file.metadata.field_delimiter = "," # Change the field delimiter to a comma

iCSV.save("path/to/file.icsv", file; overwrite=true)
```
