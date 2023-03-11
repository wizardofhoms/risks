
# Files that are registered for cleanup wipe on exit.
typeset -ga cleanup_directories
typeset -ga cleanup_files
typeset -ga cleanup_mounts
typeset -ga cleanup_luks

# cleanup.add_directory is used to register one or more directories
# to be deleted of their contents (but not the directory root itself).
# $@ - Directories to register for cleanup.
function cleanup.add_directory ()
{
    [[ -z "$*" ]] && return
    cleanup_directories+=( "$@" )
    read -rA cleanup_directories < <(printf "%s\n" "${cleanup_directories[@]}" | sort -u | tr '\n' ' ')
}

# cleanup.rm_directory is used to deregister some
# directories previously registered for cleanup.
# $@ - Directories to deregister.
function cleanup.rm_directory ()
{
    [[ -z "$*" ]] && return
    read -rA cleanup_directories < <(printf "%s\n" "${cleanup_directories[@]}" "$@" | uniq -u)
}

# cleanup.add_file registers one or more files to be wiped on exit.
# $@ - Files to register for wipe.
function cleanup.add_file ()
{
    [[ -z "$*" ]] && return
    read -rA cleanup_files <<< "$@"
    read -rA cleanup_files < <(printf "%s\n" "${cleanup_files[@]}" | sort -u | tr '\n' ' ')
}

# cleanup.rm_file deregisters some files
# previously registered for cleanup.
# $@ - Files to deregister.
function cleanup.rm_file ()
{
    [[ -z "$*" ]] && return
    read -rA cleanup_files < <(printf "%s\n" "${cleanup_files[@]}" "$@" | uniq -u)
}

# cleanup.add_mount_point registers one or more mount points (paths)
# which should be unmounted on exit. For any of those directoreis that
# are also registered with cleanup.add_directory, they will be cleaned
# up from their contents before being unmounted.
# $@ - Mounts points to register.
function cleanup.add_mount_point ()
{
    [[ -z "$*" ]] && return
    read -rA cleanup_mounts <<< "$@"
    read -rA cleanup_mounts < <(printf "%s\n" "${cleanup_mounts[@]}" | sort -u | tr '\n' ' ')
}

# cleanup.rm_mount_point deregisters mount points
# previously registered for unmounting on exit.
# $@ - Mounts points to deregister.
function cleanup.rm_mount_point ()
{
    [[ -z "$*" ]] && return
    read -rA cleanup_mounts < <(printf "%s\n" "${cleanup_mounts[@]}" "$@" | uniq -u)
}

# cleanup.add_luks registers a luks device name (/dev/mapper/<name>)
# to be closed on cleanup execute. The mapper will first be checked
# on the list of mount points, and if any are found, they will be
# unmounted first before being cryptsetup closed.
# $@ - Luks mappers to register.
function cleanup.add_luks ()
{
    [[ -z "$*" ]] && return
    cleanup_luks+=( "$@" )
    read -rA cleanup_luks < <(printf "%s\n" "${cleanup_luks[@]}" | sort -u | tr '\n' ' ')
}

# cleanup.rm_luks deregisters luks mapper names
# previously registered for closing on exit.
# $@ - Luks mappers to deregister.
function cleanup.rm_luks ()
{
    [[ -z "$*" ]] && return
    read -rA cleanup_luks < <(printf "%s\n" "${cleanup_luks[@]}" "$@" | uniq -u)
}

# cleanup.execute will perform cleanup and unmounting of
# all previously/currently registered files/directories,
# and overwrites/clears all sensitive script variables.
# Originally copied from tomb code.
function cleanup.execute()
{
    # Cleanup all registered files and directories
    [[ -n "${cleanup_files[*]}" ]] && _info "Cleaning up files"
    for file in "${cleanup_files[@]}"; do
        [[ -z "$file" ]] && continue

        sudo chattr -i "${file}"
        _run sudo wipe -rf "${file}"
    done

    [[ -n "${cleanup_directories[*]}" ]] && _info "Cleaning up directories"
    for dir in "${cleanup_directories[@]}"; do
        [[ -z "$dir" ]] && continue

        sudo chattr -i "${dir}"/**/*
        _run sudo wipe -rf "${dir}"/*
    done

    # Unmount all mount points.
    [[ -n "${cleanup_mounts[*]}" ]] && _info "Cleaning up mount points"
    for mount in "${cleanup_mounts[@]}"; do
        [[ -z "$mount" ]] && continue

        device.unmount "${mount}"
    done

    # Unmount and close LUKS devices
    [[ -n "${cleanup_luks[*]}" ]] && _info "Closing LUKS devices"
    for luks in "${cleanup_luks[@]}"; do
        [[ -z "$luks" ]] && continue

        device.unmount "${luks}"
        sudo cryptsetup close "${luks}"
    done

    # Prepare some random material to overwrite vars
    local rr="$RANDOM"
    while [[ ${#rr} -lt 500 ]]; do
        rr+="$RANDOM"
    done

    # Ensure no information is left in unallocated memory
    IDENTITY="$rr";		        unset IDENTITY
    FILE_ENCRYPTION_KEY="$rr";  unset FILE_ENCRYPTION_KEY
    GPG_PASS="$rr";		        unset GPG_PASS
}

# Trap functions for the cleanup.execute event
TRAPINT()  { cleanup.execute INT;	}
TRAPEXIT() { cleanup.execute EXIT;	}
TRAPHUP()  { cleanup.execute HUP;	}
TRAPQUIT() { cleanup.execute QUIT;	}
TRAPABRT() { cleanup.execute ABORT; }
TRAPKILL() { cleanup.execute KILL;	}
TRAPPIPE() { cleanup.execute PIPE;	}
TRAPTERM() { cleanup.execute TERM;	}
TRAPSTOP() { cleanup.execute STOP;	}

