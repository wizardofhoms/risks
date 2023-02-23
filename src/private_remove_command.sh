
local keygrip keypath

_set_identity "${args[identity]}"

# Hush and identity checks
if ! is_hush_mounted ; then
    _failure "The hush device is not mounted. Mount it first and rerun the command."
fi

if ! _identity_active ; then
    _failure "This command requires an identity to be active"
fi

# 2 - Set the partition read-write and remove from the gpg keyring
risks_hush_rw_command

_message "Wiping private GPG key ${keygrip} from keyring"
_run wipe -rf "${keyring_path}" \
    || _warning "Failed to delete master private key from keyring !"

risks_hush_ro_command

_message "Removed private key from keyring"
