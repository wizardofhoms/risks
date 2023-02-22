
local tomb_file tomb_label resource

_set_identity "" 

resource="${args[tomb_name]}"
tomb_label="${IDENTITY}-${resource}"

identity_graveyard=$(get_identity_graveyard "$IDENTITY")
tomb_file=$(_encrypt_filename "$tomb_label")

print "${identity_graveyard}/${tomb_file}.tomb"
