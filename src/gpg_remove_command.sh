
local keygrip keypath

identity.set "${args['identity']}"

# Backup/hush and identity checks
hush.fail_device_unmounted

# Copy/check the private key and revoc certificate, check correcly copied, close GPG tomb
keygrip="$(gpg -K | grep Keygrip | head -n 1 | cut -d= -f 2 | sed 's/ //g').key"
_verbose "Keygrip: $keygrip"
keyring_path="${RAMDISK}/private-keys-v1.d/${keygrip}"

_info "Wiping private GPG key ${keygrip} from keyring"
_run wipe -rf "${keyring_path}" \
    || _warning "Failed to delete master private key from keyring !"

_info "Removed private key from keyring"
