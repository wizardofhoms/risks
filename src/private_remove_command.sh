
local keygrip keypath

_set_identity "${args[identity]}"

# Backup/hush and identity checks
if ! is_luks_mapper_present "$BACKUP_MAPPER" ; then
    _failure "No mounted backup medium found. Mount one with 'risks backup mount </dev/device>'"
fi

if ! is_hush_mounted ; then
    _failure "The hush device is not mounted. Mount it first and rerun the command."
fi

if ! _identity_active ; then
    _failure "This command requires an identity to be active"
fi

# 2 - Set the partition read-write and remove from the gpg keyring
risks_hush_rw_command

# 3 - Copy/check the private key and revoc certificate, check correcly copied, close GPG tomb
keygrip="$(gpg -K | grep Keygrip | head -n 1 | cut -d= -f 2 | sed 's/ //g').key"
_verbose "Keygrip: $keygrip"
keyring_path="${RAMDISK}/private-keys-v1.d/${keygrip}" 

_message "Wiping private GPG key ${keygrip} from keyring"
_run wipe -rf "${keyring_path}" \
    || _warning "Failed to delete master private key from keyring !"

risks_hush_ro_command

_message "Removed private key from keyring"
