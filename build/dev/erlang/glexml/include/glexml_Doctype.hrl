-record(doctype, {
    root_name :: binary(),
    external_id :: gleam@option:option(glexml:external_id()),
    declarations :: glexml:dtd()
}).
