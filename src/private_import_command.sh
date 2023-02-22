
local keygrip keypath

_set_identity "${args[identity]}"

# Hush and identity checks
if ! is_hush_mounted ; then
    _failure "The hush device is not mounted. Mount it first and rerun the command."
fi

if ! is_luks_mapper_present "$BACKUP_MAPPER" ; then
    _failure "No mounted backup medium found. Mount one with 'risks backup mount </dev/device>'"
fi

if ! _identity_active ; then
    _failure "This command requires an identity to be active"
fi

# 1 - Open the GPG tomb in the backup, and verify target files are here.
_run open_tomb_backup "$GPG_TOMB_LABEL"

keygrip="$(gpg -K | grep Keygrip | head -n 1 | cut -d= -f 2 | sed 's/ //g').key"
_verbose "Keygrip: $keygrip"
keypath="${HOME}/.tomb/${GPG_TOMB_LABEL}/${keygrip}"

if [[ ! -e "${keypath}" ]]; then
    close_tomb "${GPG_TOMB_LABEL}"
    _failure "Private key ${keygrip} not found in ${GPG_TOMB_LABEL} tomb"
fi

# 2 - Set the hush partition read-write and import the corresponding key
risks_hush_rw_command

_message "Importing GPG private key in keyring"
cp "${keypath}" "${RAMDISK}"/private-keys-v1.d/"${keygrip}" 

_run close_tomb "${GPG_TOMB_LABEL}"
