-record(parse_error, {
    kind :: glexml:error_kind(),
    line :: integer(),
    column :: integer(),
    offset :: integer()
}).
