
local backup_graveyard          # Where the graveyard root directory is in the backup drive
local identity_graveyard_backup # Full path to identity graveyard backup
local identity_dir              # The encrypted graveyard directory for the identity

if ! device.luks_mapper_found "$BACKUP_MAPPER" ; then
    _info "No mounted backup medium found."
    return
fi

identity.set 
identity.fail_none_active

backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"
identity_dir=$(crypt.filename "$IDENTITY")
identity_graveyard_backup="${backup_graveyard}/${identity_dir}"

# If the identity has no backup, exit.
if [[ ! -e "$identity_graveyard_backup" ]]; then
    _info "This identity has no graveyard on the backup medium" 
    return
fi

_info "Locking identity graveyard backup"
crypt.lock_directory "${identity_graveyard_backup}"
