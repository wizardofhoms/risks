
local backup_graveyard          # Where the graveyard root directory is in the backup drive
local identity_graveyard_backup # Full path to identity graveyard backup
local identity_dir              # The encrypted graveyard directory for the identity

if ! is_luks_mapper_present "$BACKUP_MAPPER" ; then
    _info "No mounted backup medium found."
    return
fi

_set_identity 
check_identity_active

backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"
identity_dir=$(_encrypt_filename "$IDENTITY")
identity_graveyard_backup="${backup_graveyard}/${identity_dir}"

# If the identity has no backup, exit.
if [[ ! -e "$identity_graveyard_backup" ]]; then
    _info "This identity has no graveyard on the backup medium" 
    return
fi

_info "Locking identity graveyard backup"
lock_directory "${identity_graveyard_backup}"
