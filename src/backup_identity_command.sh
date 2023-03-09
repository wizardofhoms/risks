
local backup_graveyard          # Where the graveyard root directory is in the backup drive
local identity_graveyard        # The full path to the identity system graveyard.
local identity_graveyard_backup # Full path to identity graveyard backup
local identity_dir              # The encrypted graveyard directory for the identity

identity.set 
backup.fail_device_unmounted

backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"
identity_dir=$(crypt.filename "$IDENTITY")
identity_graveyard="${GRAVEYARD}/${identity_dir}"
identity_graveyard_backup="${backup_graveyard}/${identity_dir}"

# Always check that the identity has its own backup directory set up,
# because backup is not mandatory at identity creation time.
if [[ ! -e "$identity_graveyard_backup" ]]; then
    _info "Setting graveyard backup for this identity"
    _run backup.setup_identity
    _catch "Failed to setup identity backup graveyard"
fi

_info "Backing up current identity data and hush partition"

## First make sure the backup directory for the identity is unlocked
echo "$FILE_ENCRYPTION_KEY" | _run sudo fscrypt unlock "$identity_graveyard_backup" --quiet

# Backup the GPG coffin for this identity
_verbose "Backing GPG" 
_run backup.write_gpg "${BACKUP_MOUNT_DIR}/graveyard" 

# Graveyard backup for this identity.
_verbose "Backing graveyard files"
_run sudo chattr -i "${identity_graveyard_backup}"/* \
    || _verbose "No files in backup/graveyard for which to change immutability properties"

_run cp -fR "${identity_graveyard}"/* "${identity_graveyard_backup}"
_catch "Failed to copy graveyard files to backup medium"

_verbose "Making graveyard backup files immutable"
_run sudo chattr +i "${identity_graveyard_backup}"/* \
    || _verbose "No files in backup/graveyard for which to change immutability properties"

# Remove the GPG tomb containing master private and revoc
backup.move_gpg_master_key

# Testing the full backup 
_verbose "Printing directory tree in identity backup graveyard"
_verbose "$(tree "$identity_graveyard_backup")"

# We don't need the identity backup graveyard anymore, lock it
_run sudo fscrypt lock "${identity_graveyard_backup}"

# And backup hush, since it has new content
risks_backup_hush_command

_info "Done backing current identity and hush device"

