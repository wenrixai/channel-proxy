local cjson = require 'cjson'

function load_config()
    local file = io.open('tf_config.json', 'r')
    local content = file:read('*all')
    file:close()
    return cjson.decode(content)
end

function build_supplier_labels(supplier, supplier_config)
  local xml = ''
  for key, value in pairs(supplier_config) do
    xml = xml .. '<CustomSupplierParameter><Supplier>' .. supplier ..'</Supplier><Name>' .. key .. '</Name><Value>' .. value .. '</Value></CustomSupplierParameter>'
  end
  return xml
end