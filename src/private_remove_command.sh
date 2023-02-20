
local keygrip keypath

_set_identity "${args[identity]}"

# Hush and identity checks
if ! is_hush_mounted ; then
    _failure "The hush device is not mounted. Mount it first and rerun the command."
fi

if ! _identity_active ; then
    _failure "This command requires an identity to be active"
fi

# 1 - Open the GPG tomb
open_tomb "$GPG_TOMB_LABEL" "$IDENTITY"

# 3 - Copy/check the private key and revoc certificate, check correcly copied, close GPG tomb
keygrip="$(gpg -K | grep Keygrip | head -n 1 | cut -d= -f 2 | sed 's/ //g').key"
_verbose "Keygrip: $keygrip"
keypath="${HOME}/.tomb/${GPG_TOMB_LABEL}/${keygrip}"
keyring_path="${RAMDISK}/private-keys-v1.d/${keygrip}" 

if [[ ! -e "${keypath}" ]]; then
    _message "Copying private key ${keygrip} in $GPG_TOMB_LABEL tomb"
    cp "${keyring_path}" "${keypath}" 
    sudo chattr +i "${keypath}" 
fi

close_tomb "$GPG_TOMB_LABEL"

if [[ ! -e ${keypath} ]]; then
    _failure "Private key file should be found in $GPG_TOMB_LABEL tomb after copy, aborting deletion"
fi

# 2 - Set the partition read-write and remove from the gpg keyring
risks_hush_rw_command

_message "Wiping private GPG key ${keygrip} from keyring"
_run wipe -rf "${keyring_path}" \
    || _warning "Failed to delete master private key from keyring !"

risks_hush_ro_command

_message "Removed private key from keyring"
