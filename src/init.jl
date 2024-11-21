using PyCall
using Conda
using Pkg: Pkg

const SNOWPAT_NAME = "snowpat"
const snowpat = PyNULL()

function check_pycall_conda_alignment()
    ENV["PYTHON"] = ""

    # Check if PyCall is using Conda's Python
    conda_python = joinpath(Conda.PYTHONDIR, "python")
    if PyCall.python != conda_python
        @warn "PyCall is not using Conda's Python. Rebuilding PyCall..."
        # Force rebuild of PyCall
        Pkg.build("PyCall")
        error("PyCall rebuilt to use Conda's Python. Please restart Julia and try again.")
    end
    return true
end

function ensure_snowpat()
    try
        # First try to import
        copy!(snowpat, pyimport(SNOWPAT_NAME))
        return true
    catch e
        # If import fails, install via pip
        try
            Conda.pip_interop(true)
            Conda.pip("install", SNOWPAT_NAME)
            # Try importing again after installation
            copy!(snowpat, pyimport(SNOWPAT_NAME))
            return true
        catch pip_e
            @error "Failed to install/import $SNOWPAT_NAME" import_error = e pip_error = pip_e
            return false
        end
    end
end

function __init__()
    check_pycall_conda_alignment()
    ensure_snowpat()
    return nothing
end
