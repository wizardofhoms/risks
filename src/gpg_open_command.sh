
_set_identity "${args['identity']}"

# Whatever we need to open, we need the hush device for a key.
check_hush_mounted

_info "Opening coffin and mounting GPG keyring"
open_coffin
