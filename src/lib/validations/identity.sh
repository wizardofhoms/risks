
# validate_identity_exists simply hashes an identity name and tries to
# find its corresponding coffin file in .graveyard/. If yes, the identity
# exists and is theoretically accessible on this system.
validate_identity_exists () {
    local identity="$1"

    # This might be empty if none have been found, since the _failure
    # call in _identity_active_or_specified is executed in a subshell.
    # We don't care.
    IDENTITY=$(_identity_active_or_specified "$identity")
    FILE_ENCRYPTION_KEY=$(_set_file_encryption_key "$IDENTITY")

    # Stat the coffin
    local coffin_filename coffin_file
    coffin_filename=$(_encrypt_filename "${IDENTITY}-gpg.coffin")
    coffin_file="${GRAVEYARD}/${coffin_filename}"

    if [[ ! -e $coffin_file ]]; then
        echo "Invalid identity $1: no corresponding coffin file found in ~/.graveyard"
    fi
}
