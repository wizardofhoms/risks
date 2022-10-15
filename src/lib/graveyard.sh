
# new_graveyard generates a private directory in the
# graveyard for a given identity, with fscrypt support.
new_graveyard ()
{
    local identity_dir identity_graveyard

    # Always make sure the root graveyard directory exists
    if [[ ! -d ${GRAVEYARD} ]]; then
            _verbose "Creating directory $GRAVEYARD"
            mkdir -p "$GRAVEYARD"
    fi

    # The directory name in cleartext is simply the identity name
    identity_dir=$(_encrypt_filename "$IDENTITY")
    identity_graveyard="${GRAVEYARD}/${identity_dir}"

    # Make the directory
    _verbose "Creating identity graveyard directory"
    mkdir -p "$identity_graveyard"

    # And setup fscrypt protectors on it.
    _verbose "Setting up fscrypt protectors on directory"
    echo "$FILE_ENCRYPTION_KEY" | sudo fscrypt encrypt "$identity_graveyard" \
       --quiet --source=custom_passphrase --name="$identity_dir"
}

# delete_graveyard wipes the graveyard directory of an identity
delete_graveyard()
{
    local identity_graveyard

    identity_graveyard=$(get_identity_graveyard "$IDENTITY")

    ## First make sure the backup directory for the identity is unlocked
    ## We won't lock it, since after that function runs it won't exist anymore.
    echo "$FILE_ENCRYPTION_KEY" | _run sudo fscrypt unlock "$identity_graveyard" --quiet

    sudo chattr -i "${identity_graveyard}"/*
    _run wipe -f -r "$identity_graveyard"
}

# get_identity_graveyard returns the path to an identity's graveyard directory,
# and decrypts (gives access to) this directory, since this function was called
# because we need some resource stored within.
get_identity_graveyard ()
{
    local identity="$1"

    local identity_dir identity_graveyard

    # Compute the directory names and absolute paths
    identity_dir=$(_encrypt_filename "${identity}")
    identity_graveyard="${GRAVEYARD}/${identity_dir}"

    print "${identity_graveyard}"
}
