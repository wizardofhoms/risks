
# graveyard.create generates a private directory in the
# graveyard for a given identity, with fscrypt support.
function graveyard.create ()
{
    local identity_dir identity_graveyard

    # Always make sure the root graveyard directory exists
    if [[ ! -d ${GRAVEYARD} ]]; then
        _verbose "Creating directory $GRAVEYARD"
        mkdir -p "$GRAVEYARD"
    fi

    # The directory name in cleartext is simply the identity name
    identity_dir=$(crypt.filename "$IDENTITY")
    identity_graveyard="${GRAVEYARD}/${identity_dir}"

    # Make the directory
    _verbose "Creating identity graveyard directory"
    mkdir -p "$identity_graveyard"

    # And setup fscrypt protectors on it.
    _verbose "Setting up fscrypt protectors on directory"
    echo "$FILE_ENCRYPTION_KEY" | sudo fscrypt encrypt "$identity_graveyard" \
        --quiet --source=custom_passphrase --name="$identity_dir"
    }

# graveyard.delete wipes the graveyard directory of an identity.
function graveyard.delete ()
{
    local identity_graveyard fscrypt_policy

    identity_graveyard=$(graveyard.identity_directory "$IDENTITY")

    # First make sure the backup directory for the identity is unlocked
    # We won't lock it, since after that function runs it won't exist anymore.
    echo "$FILE_ENCRYPTION_KEY" | _run sudo fscrypt unlock "$identity_graveyard" --quiet
    _catch "Failed to unlock graveyard"

    # After unlocking, destroy the fscrypt policy for this directory.
    fscrypt_policy="$(sudo fscrypt status "${identity_graveyard}" | grep Policy | awk '{print $2}')"
    _run sudo fscrypt metadata destroy --force --policy=/rw:"${fscrypt_policy}"

    sudo chattr -i "${identity_graveyard}"/*
    _run wipe -f -r "$identity_graveyard"
}

# graveyard.identity_directory returns the path to an identity's graveyard directory,
# and decrypts (gives access to) this directory, since this function was called
# because we need some resource stored within.
function graveyard.identity_directory ()
{
    local identity="$1"

    local identity_dir identity_graveyard

    # Compute the directory names and absolute paths
    identity_dir=$(crypt.filename "${identity}")
    identity_graveyard="${GRAVEYARD}/${identity_dir}"

    print "${identity_graveyard}"
}
