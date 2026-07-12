-record(dtd, {
    elements :: gleam@dict:dict(binary(), glexml:content_model()),
    attribute_lists :: gleam@dict:dict(binary(), list(glexml:attribute_declaration())),
    entities :: gleam@dict:dict(binary(), glexml:entity()),
    parameter_entities :: gleam@dict:dict(binary(), binary()),
    notations :: list(binary()),
    duplicate_elements :: list(binary()),
    pe_nesting_violations :: list(binary())
}).
