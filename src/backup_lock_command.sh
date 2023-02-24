
local backup_graveyard          # Where the graveyard root directory is in the backup drive
local identity_graveyard_backup # Full path to identity graveyard backup
local identity_dir              # The encrypted graveyard directory for the identity

backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"

# Ensure a backup is mounted
if ! is_luks_mapper_present "$BACKUP_MAPPER" ; then
    _failure "No mounted backup medium found. Mount one with 'risks backup mount </dev/device>'"
fi

# Ensure we have an active identity, which will be detected in this call
_set_identity 

if ! _identity_active ; then
    _failure "This command requires an identity to be active"
fi

identity_dir=$(_encrypt_filename "$IDENTITY")
identity_graveyard_backup="${backup_graveyard}/${identity_dir}"

# If the identity has no backup, exit.
if [[ ! -e "$identity_graveyard_backup" ]]; then
    _failure "This identity has no graveyard on the backup medium"
fi

_info "Locking identity graveyard backup"
_run sudo fscrypt lock "${identity_graveyard_backup}"
