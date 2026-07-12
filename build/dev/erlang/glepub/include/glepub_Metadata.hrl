-record(metadata, {
    identifier :: binary(),
    title :: binary(),
    language :: binary(),
    creators :: list(glepub:contributor()),
    contributors :: list(glepub:contributor()),
    publisher :: gleam@option:option(binary()),
    description :: gleam@option:option(binary()),
    published :: gleam@option:option(binary()),
    modified :: gleam@option:option(binary()),
    subjects :: list(binary()),
    rights :: gleam@option:option(binary())
}).
