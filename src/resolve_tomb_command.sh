
local tomb_file tomb_label resource

_set_identity "" 

resource="${args[tomb_name]}"
tomb_label="${IDENTITY}-${resource}"

tomb_file=$(_encrypt_filename "$tomb_label")
print "${tomb_file}.tomb"
