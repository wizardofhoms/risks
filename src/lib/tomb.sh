
get_tomb_mapper()
{
    if ls -1 /dev/mapper/tomb.* &> /dev/null ;  then
        ls -1 /dev/mapper/tomb.* | grep "${1}"
    else
        echo "none"
    fi
}

# Generates a new tomb for a given identity
new_tomb()
{
    local name="$1"
    local size="$2"

    local tomb_label        # Cleartext identifier name of the tomb
    local tomb_file         # Encrypted name of the tomb, for the tomb file itself
    local tomb_file_path    # Absolute path to the tomb file
    local tomb_key          # Encrypted name of the tomb key file
    local tomb_key_path     # Absolute path to the tomb key file
    local uid recipient     # Used to get the email address of the identity with GPG.

    # Filenames
    tomb_label="${IDENTITY}-${name}"
    tomb_file=$(_encrypt_filename "$tomb_label")

    tomb_key=$(_encrypt_filename "${tomb_label}.key")
    tomb_key_path="${HUSH_DIR}/${tomb_key}"

    identity_graveyard=$(get_identity_graveyard "$IDENTITY")
    tomb_file_path="${identity_graveyard}/${tomb_file}.tomb"

    # First make sure GPG keyring is accessible
    _verbose "Opening identity $IDENTITY"
    open_coffin

    # And get the email recipient
    uid=$(gpg -K | grep uid | head -n 1)
    recipient=$(echo "$uid" | grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")

    # Then dig
    _verbose "Digging tomb in $tomb_file_path"
    tomb dig -s "$size" "$tomb_file_path" 
    _catch "Failed to dig tomb. Aborting"
    _run risks_hush_rw_command 
    _verbose "Forging tomb key and making it immutable"
    tomb forge -g -r "$recipient" "$tomb_key_path" 
    _catch "Failed to forge keys. Aborting"
    sudo chattr +i "$tomb_key_path" 
    _verbose "Locking tomb with key"
    tomb lock -g -k "$tomb_key_path" "$tomb_file_path" 
    _catch "Failed to lock tomb. Aborting"
    _run risks_hush_ro_command
}

# Deletes a tomb and its associated key in the hush device.
delete_tomb()
{
    local name="$1"

    local tomb_label        # Cleartext identifier name of the tomb
    local tomb_file         # Encrypted name of the tomb, for the tomb file itself
    local tomb_file_path    # Absolute path to the tomb file
    local tomb_key          # Encrypted name of the tomb key file
    local tomb_key_path     # Absolute path to the tomb key file
    local uid recipient     # Used to get the email address of the identity with GPG.

    # Prepare filenames
    tomb_label="${IDENTITY}-${name}"
    tomb_file=$(_encrypt_filename "$tomb_label")

    tomb_key=$(_encrypt_filename "${tomb_label}.key")
    tomb_key_path="${HUSH_DIR}/${tomb_key}"

    identity_graveyard=$(get_identity_graveyard "$IDENTITY")
    tomb_file_path="${identity_graveyard}/${tomb_file}.tomb"

    # A few special cases need confirmation from the user, 
    # like GPG, which stores the identity' private keys
    case ${name} in
        GPG)
            _warning "The tomb 'GPG' holds the private keys for this identity !"
            printf >&2 '%s ' 'Do you really want delete this tomb ? (YES/n)'
            read ans

            if [[ "$ans" != 'YES' ]]; then
                _message "Aborting deletion of tomb 'GPG'. Exiting"
                exit 0
            fi
    esac

    # Else we are good to go and delete, even if some files will not be found.
    _message "Deleting tomb $name"

    if [[ -e "$tomb_file_path" ]]; then
        _run wipe -f -r "$tomb_file_path"
    else
        _warning "Tomb file path does not exists, skipping."
    fi

    if [[ -e "$tomb_key_path" ]]; then
        sudo chattr -i "$tomb_key_path"
        _run wipe -f -r -P 10 "$tomb_key_path"
    else 
        _warning "Tomb key path does not exists, skipping."
    fi 
}

# open_tomb requires a cleartext resource name that the function will encrypt 
# to resolve the correct tomb file. The name is both used as a mount directory, 
# as well as to determine when some special tombs need to be mounted on non-standard 
# mount points, like gpg/ssh.
# $1 - Name of the tomb
# $2 - Identity
open_tomb()
{
    local resource="${1}"

    local tomb_label        # Cleartext identifier name of the tomb
    local tomb_file         # Encrypted name of the tomb, for the tomb file itself
    local tomb_file_path    # Absolute path to the tomb file
    local tomb_key          # Encrypted name of the tomb key file
    local tomb_key_path     # Absolute path to the tomb key file
    local mapper            # Mapper name for tomb LUKS filesystem

    # Filenames
    tomb_label="${IDENTITY}-${resource}"
    tomb_file=$(_encrypt_filename "$tomb_label")

    tomb_key=$(_encrypt_filename "$tomb_label.key")
    tomb_key_path="${HUSH_DIR}/${tomb_key}"

    identity_graveyard=$(get_identity_graveyard "$IDENTITY")
    tomb_file_path="${identity_graveyard}/${tomb_file}.tomb"

    mapper=$(get_tomb_mapper "$tomb_file")

    # Some resources need to have fixed mount points, 
    # like the few below that are not matched by the wildcard.
    case ${resource} in
        gpg)
            local mount_dir="${HOME}/.gnupg"
            ;;
        pass)
            local mount_dir="${HOME}/.password-store"
            ;;
        ssh)
            local mount_dir="${HOME}/.ssh"
            ;;
        mgmt)
            local mount_dir="${HOME}/.tomb/mgmt"
            ;;
        *)
            local mount_dir="${HOME}/.tomb/${resource}"
            ;;
    esac

    # checks if the gpg coffin is mounted, and open it first:
    # this also have for effect to unlock the identity's graveyard.
    local coffin_name
    coffin_name=$(_encrypt_filename "coffin-${IDENTITY}-gpg")
    if ! is_luks_mounted "/dev/mapper/${coffin_name}" ; then
        open_coffin
    fi

    if [[ "${mapper}" != "none" ]]; then
        if is_luks_mounted "/dev/mapper/tomb.${tomb_file}" ; then
            _verbose "Tomb ${tomb_label} is already open and mounted"
            return 0
        fi
    fi

    if [[ ! -f "$tomb_file_path" ]]; then
        _warning "No tomb file $tomb_file_path found"
        return 2
    fi

    if [[ ! -f "$tomb_key_path" ]]; then
        _warning "No key file $tomb_key_path found"
        return 2
    fi

    # Make the mount point directory if needed
    if [[ ! -d ${mount_dir} ]]; then
        mkdir -p "$mount_dir"
    fi

    # And finally open the tomb
    tomb open -g -k "$tomb_key_path" "$tomb_file_path" "$mount_dir"
    _catch "Failed to open tomb"

    # Either add the only SSH key, or all of them if we have a script
    if [[ "$resource" == "ssh" ]]; then
        local ssh_add_script="${HOME}/.ssh/ssh-add"
        if [[ -e ${ssh_add_script} ]]; then
            ${ssh_add_script}
        else
            ssh-add
        fi
    fi
}

close_tomb()
{
    local resource="${1}"

    local tomb_label        # Cleartext identifier name of the tomb
    local tomb_file         # Encrypted name of the tomb, for the tomb file itself

    # Filenames
    tomb_label="${IDENTITY}-${resource}"
    tomb_file=$(_encrypt_filename "${tomb_label}")

    if ! get_tomb_mapper "${tomb_file}" &> /dev/null ; then
        _verbose "Tomb ${IDENTITY}-${resource} is already closed"
        return 0
    fi

    # If the concatenated string is too long, cut it to 16 chars
    if [[ ${#tomb_file} -ge 16 ]]; then
        tomb_file=${tomb_file:0:16}
    fi

    # SSH tombs must all delete all SSH identities from the agent
    if [[ "${resource}" == "ssh" ]]; then
        _run ssh-add -D
    fi

    # Then close it
    tomb close "${tomb_file}"

    # And delete the directory if it's not a builtin
    case ${resource} in
        gpg|pass|ssh|mgmt)
            # Ignore those
            ;;
        *)
            rm -rf "${HOME}/.tomb/${resource}"
            ;;
    esac
}

# Identical to close_tomb, but slamming it, so all processes making use of it are killed
slam_tomb()
{
    local resource="${1}"

    # Filenames
    # local FULL_name="${IDENTITY}-${resource}"
    tomb_label="${IDENTITY}-${resource}"
    tomb_file=$(_encrypt_filename "${tomb_label}")

    if ! get_tomb_mapper "${tomb_file}" &> /dev/null ; then
        _verbose "Tomb ${IDENTITY}-${resource} is already closed"
        return 0
    fi

    # If the concatenated string is too long, cut it to 16 chars
    if [[ ${#tomb_file} -ge 16 ]]; then
        tomb_file=${tomb_file:0:16}
    fi

    # SSH tombs must all delete all SSH identities from the agent
    # before tombs kills the process.
    if [[ "${resource}" == "ssh" ]]; then
        _run ssh-add -D
    fi

    # Then close it
    tomb slam "${tomb_file}"

    # And delete the directory if it's not a builtin
    case ${resource} in
        gpg|pass|ssh|mgmt)
            # Ignore those
            ;;
        *)
            rm -rf "${HOME}/.tomb/${resource}"
            ;;
    esac

}
