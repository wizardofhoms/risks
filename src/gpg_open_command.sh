
identity.set "${args['identity']}"

# Whatever we need to open, we need the hush device for a key.
hush.fail_device_unmounted

_info "Opening coffin and mounting GPG keyring"
gpg.open_coffin
