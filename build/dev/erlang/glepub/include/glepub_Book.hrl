-record(book, {
    version :: binary(),
    metadata :: glepub:metadata(),
    manifest :: list(glepub:manifest_item()),
    spine :: list(glepub:spine_item()),
    toc :: list(glepub:toc_entry()),
    page_list :: list(glepub:toc_entry()),
    landmarks :: list(glepub:toc_entry()),
    direction :: glepub:direction(),
    rendition :: glepub:rendition(),
    cover :: gleam@option:option(glepub:manifest_item()),
    loader :: fun((binary()) -> {ok, bitstring()} | {error, nil})
}).
