using PyCall
using Conda
using Pkg: Pkg

const SNOWPAT_NAME = "snowpat"
const SNOWPAT_MIN_VERSION = "0.4.7"
const SNOWPAT_MAX_VERSION = "1.0.0"
const snowpat = PyNULL()
const pd = PyNULL()

struct RestartRequired <: Exception
    message::String
end

function check_snowpat_version(sp)
    version = sp.__version__
    if version < SNOWPAT_MIN_VERSION || version >= SNOWPAT_MAX_VERSION
        @warn "Installed snowpat version $version is not compatible. Required: >=$(SNOWPAT_MIN_VERSION) and <$(SNOWPAT_MAX_VERSION)"
        return false
    end
    return true
end

function check_dependencies()
    missing_deps = false
    
    # Check PyCall-Conda alignment
    try
        conda_python = joinpath(Conda.PYTHONDIR, "python")
        if PyCall.python != conda_python
            @warn "PyCall is not using Conda's Python. Please rebuild PyCall using: ENV[\"PYTHON\"]=\"\"; using Pkg; Pkg.build(\"PyCall\")"
            missing_deps = true
        end
    catch e
        @warn "Error checking PyCall-Conda alignment: $e"
        missing_deps = true
    end

    # Check snowpat
    try
        copy!(snowpat, pyimport(SNOWPAT_NAME))
        if !check_snowpat_version(snowpat)
            @warn "Please install compatible snowpat version: pip install $(SNOWPAT_NAME)>=$(SNOWPAT_MIN_VERSION),<$(SNOWPAT_MAX_VERSION)"
            missing_deps = true
        end
    catch e
        @warn "snowpat package not found or error importing: $e\nPlease install: pip install $(SNOWPAT_NAME)>=$(SNOWPAT_MIN_VERSION)"
        missing_deps = true
    end

    # Check pandas
    try
        copy!(pd, pyimport("pandas"))
    catch e
        @warn "pandas package not found or error importing: $e\nPlease install: pip install pandas"
        missing_deps = true
    end

    return !missing_deps
end

function install_dependencies()
    # Align PyCall with Conda's Python
    ENV["PYTHON"] = ""
    conda_python = joinpath(Conda.PYTHONDIR, "python")
    if PyCall.python != conda_python
        @info "PyCall is not using Conda's Python. Rebuilding PyCall..."
        Pkg.build("PyCall")
        throw(RestartRequired("PyCall rebuilt to use Conda's Python. Please restart Julia and try again."))
    end

    # Install/upgrade snowpat if needed
    try
        copy!(snowpat, pyimport(SNOWPAT_NAME))
        if !check_snowpat_version(snowpat)
            @info "Installing compatible snowpat version..."
            Conda.pip_interop(true)
            Conda.pip("install", "$(SNOWPAT_NAME)==$(SNOWPAT_MIN_VERSION)")
            throw(RestartRequired("snowpat installed/upgraded. Please restart Julia and try again."))
        end
    catch e
        if !isa(e, RestartRequired)
            @info "Installing snowpat..."
            Conda.pip_interop(true)
            Conda.pip("install", SNOWPAT_NAME)
            throw(RestartRequired("snowpat installed. Please restart Julia and try again."))
        else
            rethrow(e)
        end
    end

    # Install pandas if needed
    try
        copy!(pd, pyimport("pandas"))
    catch e
        @info "Installing pandas..."
        Conda.add("pandas")
        throw(RestartRequired("pandas installed. Please restart Julia and try again."))
    end

    return true
end

function __init__()
    check_dependencies()
end
