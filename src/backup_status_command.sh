
# Get basic status
if ! device.luks_mapper_found "${BACKUP_MAPPER}"; then
    _info "No backup device mounted" && return
fi

# Device is mounted, show read-write permissions and mount points.
_info "Backup device mounts:"
print "$(mount | grep "^/dev/mapper/${BACKUP_MAPPER}")"

if identity.active; then 
    identity.set && echo && _info "Identity backup graveyard status:" 

    backup_graveyard="${BACKUP_MOUNT_DIR}/graveyard"
    identity_dir=$(crypt.filename "$IDENTITY")
    identity_graveyard_backup="${backup_graveyard}/${identity_dir}"

    sudo fscrypt status "$identity_graveyard_backup"
fi
