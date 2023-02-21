# validate_file_exists just checks that
validate_file_exists () {
    [[ -e "$1" ]] || echo "Invalid file $1: no such file or directory"
}

# Checks that a partition size given in absolute terms has a valid unit
validate_partition_size () {
    case "$1" in *K|*M|*G|*T|*P) return ;; esac
    echo "Absolute size must comprise a valid unit (K/M/G/T/P, eg. 100M)"
}

# Checks a given device path is encrypted.
validate_is_luks_device () {
    if ! is_encrypted_block  "$1" ; then
        echo "Path $1 seems not to be a LUKS filesystem."
    fi
}

# validate_device is general purpose validator that calls on many of the
# other validations above, because some commands will need all of the
# conditions above to be fulfilled.
validate_device () {

    # Check device file exists
    if [[ ! -e $1 ]]; then
        echo "Device path $1 does not exist: no such file."
    fi
}

