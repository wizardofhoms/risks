
local email uid ssh_key_name key_algo

_set_identity ""
check_hush_mounted

# Parameters setup
key_algo="${args['--algo']-ed25519}"
uid=$(gpg -K | grep uid | head -n 1)
email=$(echo "$uid" | grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b")
bits="$(get_key_size "${key_algo}" "${args['--bits']}")"

ssh_key_name="${args['--filename']}"
[[ -z ${ssh_key_name} ]] && ssh_key_name="${IDENTITY}-${key_algo}-${RANDOM}"

# Generation
_info "Generating SSH keypair"
_info "Type: ${key_algo}"

_run open_tomb "$SSH_TOMB_LABEL"

# Generate SSH key.
ssh-keygen -t "${key_algo}" "${bits}" -C "$email" -N "" -f "${HOME}"/.ssh/"${ssh_key_name}"
_catch "Failed to generate SSH keys"

_verbose "Making keys immutable"
sudo chattr +i "${HOME}"/.ssh/"${ssh_key_name}"*

_info "Successfully generated new SSH keypair" && return
