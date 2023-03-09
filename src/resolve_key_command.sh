
local tomb_key tomb_label

identity.set "${args['identity']}" 

resource="${args['tomb_name']}"
tomb_label="${IDENTITY}-${resource}"

tomb_key=$(crypt.filename "$tomb_label.key")
print "${HUSH_DIR}/${tomb_key}"
