
# Get basic status
local attached mounted

attached=$(device.luks_mapper_found "${SDCARD_ENC_PART_MAPPER}")
mounted=$(device.hush_is_mounted)

[[ ! $attached -eq 0 ]] && _info "Hush device is not attached to vault qube" && return
[[ ! $mounted -eq 0 ]] && _info "No hush device mounted" && return

# Device is mounted, show read-write permissions and mount points.
_info "Hush device mounts:"
print "$(mount | grep "^/dev/mapper/${SDCARD_ENC_PART_MAPPER}")"
