-record(toc_entry, {
    label :: binary(),
    href :: gleam@option:option(binary()),
    children :: list(glepub:toc_entry())
}).
