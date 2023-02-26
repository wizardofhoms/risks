
# Get basic status
if ! is_luks_mapper_present "${BACKUP_MAPPER}"; then
    _info "No backup device mounted" && return
fi

# Device is mounted, show read-write permissions and mount points.
_info "Backup device mounts:"
print "$(mount | grep "^/dev/mapper/${BACKUP_MAPPER}")"

if _identity_active; then 
    _set_identity && echo && _info "Identity backup graveyard status:" 

    
    backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"
    identity_dir=$(_encrypt_filename "$IDENTITY")
    identity_graveyard_backup="${backup_graveyard}/${identity_dir}"

    ## First make sure the backup directory for the identity is unlocked
    ## We won't lock it, since after that function runs it won't exist anymore.
    sudo fscrypt status "$identity_graveyard_backup"
fi
