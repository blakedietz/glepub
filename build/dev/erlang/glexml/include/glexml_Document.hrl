-record(document, {
    version :: binary(),
    encoding :: gleam@option:option(binary()),
    standalone :: boolean(),
    doctype :: gleam@option:option(glexml:doctype()),
    prolog :: list(glexml:node_()),
    root :: glexml:element(),
    epilogue :: list(glexml:node_())
}).
