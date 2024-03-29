
label="${args['tomb_name']}"
size="${args['size']}"

hush.fail_device_unmounted
identity.set "${args["identity"]}"

_info "Creating tomb $label with size ${size}M"

# This new key is also the one provided when using gpgpass command.
GPG_PASS=$(crypt.passphrase "$GPG_TOMB_LABEL")
echo -n "$GPG_PASS" | xclip -loops 1 -selection clipboard
_warning "GPG passphrase copied to clipboard with one-time use only"
_info -n "Copy it in the coming GPG prompt when creating the tomb.\n"

_run tomb.create "$label" "$size"
_catch "Failed to create tomb"

_info "Done creating tomb."
