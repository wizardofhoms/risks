
local keygrip keypath

identity.set "${args['identity']}"

# Hush/backup and identity checks
hush.fail_device_unmounted
backup.fail_device_unmounted
backup.device_unlocked || risks_backup_unlock_command

# Open the GPG tomb in the backup, and verify target files are here.
_run tomb.open_backup "$GPG_TOMB_LABEL"

keygrip="$(gpg -K | grep Keygrip | head -n 1 | cut -d= -f 2 | sed 's/ //g').key"
_verbose "Keygrip: $keygrip"
keypath="${HOME}/.tomb/${GPG_TOMB_LABEL}/${keygrip}"

if [[ ! -e "${keypath}" ]]; then
    tomb.close "${GPG_TOMB_LABEL}"
    _failure "Private key ${keygrip} not found in ${GPG_TOMB_LABEL} tomb"
fi

_info "Importing GPG private key in keyring"
cp "${keypath}" "${RAMDISK}"/private-keys-v1.d/"${keygrip}"

_run tomb.close "${GPG_TOMB_LABEL}"
