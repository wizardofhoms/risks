
# The identity needs its own backup directory.
setup_identity_backup () 
{
    local backup_graveyard          # Where the graveyard root directory is in the backup drive
    local identity_dir              # The encrypted graveyard directory for the identity
    local identity_graveyard_backup # Full path to identity graveyard backup

    backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"

    _verbose "Creating identity graveyard directory on backup"

    # The directory name in cleartext is simply the identity name
    identity_dir=$(_encrypt_filename "$IDENTITY")
    identity_graveyard_backup="${backup_graveyard}/${identity_dir}"

    _verbose "Creating directory $identity_graveyard_backup"
    mkdir -p "$identity_graveyard_backup"

    # And setup fscrypt protectors on it.
    _verbose "Setting up fscrypt protectors on directory"
    echo "$FILE_ENCRYPTION_KEY" | sudo fscrypt encrypt "$identity_graveyard_backup" \
       --quiet --source=custom_passphrase --name="$identity_dir"
    _catch "Failed to encrypt identity graveyard in backup"
}

# backup_identity_gpg simply copies the raw coffin file in the graveyard backup directory root,
# since like on the system graveyard, one must access it without having access to the graveyard in
# the first place.
backup_identity_gpg () 
{
    local backup_graveyard          # Where the graveyard root directory is in the backup drive
    local identity_dir              # The encrypted graveyard directory for the identity
    local coffin_file               # Encrypted name of the coffin file
    local coffin_path               # Full path to the identity coffin in the system graveyard
    local coffin_backup_path        # Full path to the same coffin, in the backup graveyard

    backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"

    # The directory name in cleartext is simply the identity name
    coffin_file=$(_encrypt_filename "${IDENTITY}-gpg.coffin")
    coffin_path="${GRAVEYARD}/${coffin_file}"

    identity_dir=$(_encrypt_filename "$IDENTITY")
    coffin_backup_path="${backup_graveyard}/${identity_dir}/${coffin_file}"

    if [[ -e ${coffin_backup_path} ]]; then
        sudo chattr -i "${coffin_backup_path}" 
    fi

    cp -r "$coffin_path" "$coffin_backup_path"
    sudo chattr +i "${coffin_backup_path}" 
}

# delete_identity_backup wipes all the data stored in a backup medium
# for a given identity. This does not include the associated identity's
# secrets in the raw hush image, if any exists.
delete_identity_backup ()
{
    # Prepare filenames
    local backup_graveyard          # Where the graveyard root directory is in the backup drive
    local identity_graveyard_backup # Full path to identity graveyard backup
    local identity_dir              # The encrypted graveyard directory for the identity

    backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"
    identity_dir=$(_encrypt_filename "$IDENTITY")
    identity_graveyard_backup="${backup_graveyard}/${identity_dir}"

    ## First make sure the backup directory for the identity is unlocked
    ## We won't lock it, since after that function runs it won't exist anymore.
    echo "$FILE_ENCRYPTION_KEY" | _run sudo fscrypt unlock "$identity_graveyard_backup" --quiet

    # Delete the identity graveyard in it, and associated fscrypt policy
    if [[ -e "$identity_graveyard_backup" ]]; then
        _message "Wiping graveyard backup"
        sudo chattr -i "${identity_graveyard_backup}"/*
        _run wipe -f -r "$identity_graveyard_backup"
    else
        _warning "Identity graveyard backup does not exists, skipping."
    fi
}

# delete_tomb_backup wipes a single tomb from the graveyard backup of an identity.
# $1 - Cleartext label/name of the tomb to delete.
delete_tomb_backup ()
{
    # Graveyard paths 
    local backup_graveyard          # Where the graveyard root directory is in the backup drive
    local identity_graveyard_backup # Full path to identity graveyard backup
    local identity_dir              # The encrypted graveyard directory for the identity

    backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"
    identity_dir=$(_encrypt_filename "$IDENTITY")
    identity_graveyard_backup="${backup_graveyard}/${identity_dir}"

    # Tomb file
    local name="$1"

    local tomb_label        # Cleartext identifier name of the tomb
    local tomb_file         # Encrypted name of the tomb, for the tomb file itself
    local tomb_file_path    # Absolute path to the tomb file

    tomb_label="${IDENTITY}-${name}"
    tomb_file=$(_encrypt_filename "$tomb_label")
    tomb_file_path="${identity_graveyard_backup}/${tomb_file}.tomb"

    ## First make sure the backup directory for the identity is unlocked
    echo "$FILE_ENCRYPTION_KEY" | _run sudo fscrypt unlock "$identity_graveyard_backup" --quiet

    if [[ -e "$tomb_file_path" ]]; then
        _run wipe -f -r "$tomb_file_path"
    else 
        _warning "Tomb file backup does not exists, skipping."
    fi

    # And lock the graveyard
    _run sudo fscrypt lock "${identity_graveyard_backup}"
}
