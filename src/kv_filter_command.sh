
local key
local -a values
local all_values

key="${args['key']}"
values+=("${args['value']}")

# More than one value means we are setting an array.
# Join them with newlines.
if [[ -n "${other_args[*]}" ]]; then
    values+=( "${other_args[@]}" )
    old="$IFS"
    IFS=$'\n'
    all_values="${values[*]}"
    IFS=$old
else
    all_values="${values[*]}"
fi

kv.filter "${key}" "${all_values}"
