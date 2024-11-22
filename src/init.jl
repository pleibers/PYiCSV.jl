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

function check_pycall_conda_alignment()
    ENV["PYTHON"] = ""

    # Check if PyCall is using Conda's Python
    conda_python = joinpath(Conda.PYTHONDIR, "python")
    if PyCall.python != conda_python
        @warn "PyCall is not using Conda's Python. Rebuilding PyCall..."
        # Force rebuild of PyCall
        Pkg.build("PyCall")
        throw(InitError(:iCSV, "PyCall rebuilt to use Conda's Python. Please restart Julia and try again."))
    end
    return true
end

function check_snowpat_version(sp)
    @show SNOWPAT_MIN_VERSION
    version = sp.__version__
    @show version
    if version < SNOWPAT_MIN_VERSION
        return false
    elseif version >= SNOWPAT_MAX_VERSION
        return false
    end
    return true
end

function install_snowpat_version()
    Conda.pip_interop(true)
    # Install the minimum version specifically
    Conda.pip("install", "$(SNOWPAT_NAME)==$(SNOWPAT_MIN_VERSION)")
end

function ensure_snowpat()
    try
        # First try to import
        copy!(snowpat, pyimport(SNOWPAT_NAME))
    catch e
        try
            @info "Installing $SNOWPAT_NAME..."
            Conda.pip_interop(true)
            Conda.pip("install", SNOWPAT_NAME)
            # Try importing again after installation
            return false
        catch pip_e
            rethrow(pip_e)
        end
    end
    # Check if version meets requirements
    if !check_snowpat_version(snowpat)
        @warn "Installed snowpat version doesn't meet requirements. Attempting to install version $SNOWPAT_MIN_VERSION..."
        install_snowpat_version()
        return false
    end
    return true
end

function ensure_pandas()
    try
        # First try to import
        copy!(pd, pyimport("pandas"))
    catch e
        # If import fails, install via conda
        try
            Conda.add("pandas")
            # Try importing again after installation
            copy!(pd, pyimport("pandas"))
            return false
        catch conda_e
            rethrow(conda_e)
        end
    end
    return true
end

function __init__()
    check_pycall_conda_alignment()
    installed_sp = ensure_snowpat()
    installed_pd = ensure_pandas()
    if !installed_sp
        throw(InitError(:iCSV, "snowpat installed. Please restart Julia and try again."))
    end
    if !installed_pd
        throw(InitError(:iCSV, "pandas installed. Please restart Julia and try again."))
    end
    return nothing
end
