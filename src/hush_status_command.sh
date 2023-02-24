
# Get basic status
local attached mounted

attached=$(is_luks_mapper_present "${SDCARD_ENC_PART_MAPPER}")
mounted=$(is_hush_mounted)

[[ ! $attached -eq 0 ]] && _message "Hush device is not attached to vault qube" && return
[[ ! $mounted -eq 0 ]] && _message "No hush device mounted" && return

# Device is mounted, show read-write permissions and mount points.
_message "Hush device mounts:"
print "$(mount | grep "^/dev/mapper/${SDCARD_ENC_PART_MAPPER}")"
