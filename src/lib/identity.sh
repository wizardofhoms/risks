
# identity.set is used to propagate our various IDENTITY related variables
# so that all functions that will be subsequently called can access them.
# This function also takes care of checking if there is already an active
# identity that should be used, in case the argument is empty or none.
#
# $1 - The identity to use.
function identity.set ()
{
    local identity="$1"

    # This will throw an error if we don't have an identity from any source.
    IDENTITY=$(identity.active_or_specified "$identity")
    _catch "Command requires either an identity to be active or given as argument"

    # Then set the file encryption key for for it.
    FILE_ENCRYPTION_KEY=$(crypt.set_file_obfs_key "$IDENTITY")
}

# identity.set_active sets the name as an ENV variable that we can use in further functions and commands.
# This function slightly differs from identity.set in that it does not set the active identity and its
# values in the script run itself: it only populates stuff that is to be used in other calls of risks.
#
# $1 - The name to use. If empty, just resets the identity.
function identity.set_active ()
{
    # If the identity is empty, wipe the identity file
    if [[ -z ${1} ]] && [[ -e ${RISKS_IDENTITY_FILE} ]]; then
        identity=$(cat "${RISKS_IDENTITY_FILE}")
        _run wipe -s -f -P 10 "${RISKS_IDENTITY_FILE}" || _warning "Failed to wipe identity file !"

        _verbose "Identity '${identity}' is now inactive, (name file deleted)"
        _info "Identity '${identity}' is now INACTIVE"
        return
    fi

    # If we don't have a file containing the
    # identity name, populate it.
    if [[ ! -e ${RISKS_IDENTITY_FILE} ]]; then
        print "$1" > "${RISKS_IDENTITY_FILE}"
    fi

    _verbose "Identity '${1}' is now active (name file written)"
    _info "Identity '${1}' is now ACTIVE"
}

# identity.active returns 0 if an identity is unlocked, 1 if not.
function identity.active ()
{
    [[ ! -e "${RISKS_IDENTITY_FILE}" ]] && return 1
    [[ -z "$(cat "${RISKS_IDENTITY_FILE}")" ]] && return 1
    return 0
}

# identity.fail_none_active exits the program if there is no identity active or specified with args.
function identity.fail_none_active ()
{
    if ! identity.active ; then
        _failure "This command requires an identity to be active"
    fi
}

# identity.active_or_specified checks that either an identity is active,
# or that the passed argument is not empty. If the identity is not empty
# it is echoed back to the caller.
#
# $1 - An identity name
#
# Returns:
# 0 - Identity is non-nil, provided either from arg or by the active
# 1 - None have been given
function identity.active_or_specified ()
{
    [[ -z "${1}" ]] && ! identity.active && return 1
    [[ -n "${1}" ]] && print "${1}" && return 0

    print "$(cat "${RISKS_IDENTITY_FILE}")"
}

# identity.get_args_name either returns the name given as parameter, or
# generates a random (burner) one and prints it to the screen.
function identity.get_args_name ()
{
    local name

    if [[ -z "${1}" ]] && [[ "${args['--burner']}" -eq 0 ]]; then
        _failure "Either an identity name is required, or the --burner flag"
    fi

    # Either use the provided one
    if [[ -n "${1}" ]]; then
        name="${1}"
    elif [[ "${args['--burner']}" -eq 1 ]]; then
        name="$(rig -m | head -n 1)"
        name="${name// /_}"
    fi

    print "${name}"
}

# identity.get_args_mail returns a correctly formatted mail given either a fully specified
# one as positional, or a generated/concatenated one from the username argument.
function identity.get_args_mail ()
{
    local name="$1"
    local email="$2"

    [[ -n "${email}" ]] && print "${email}" && return

    email="${args['--mail']}"

    # Return either the mail flag with the name
    [[ -n "${email}" ]] && print "${name}@${email}"
    # Or the lowercase name without spaces
    print "${name// /_}"
}

# identity.get_args_expiry returns a correctly formatted expiry date for a GPG key.
# If no arguments are passed to the call, the expiry date is never.
function identity.get_args_expiry ()
{
    local expiry

    if [[ -n "${1}" ]]; then
        expiry="${1}"
        expiry_date="$(date +"%Y-%m-%d" --date="${expiry}")"
    else
        expiry_date="never"
    fi

    print "${expiry_date}"
}
