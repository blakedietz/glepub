{application, glepub, [
    {vsn, "0.1.0"},
    {applications, [gleam_stdlib,
                    gleeunit,
                    glexml]},
    {description, "An EPUB toolkit for the Erlang and JavaScript targets, built on glexml"},
    {modules, [glepub_test]},
    {registered, []}
]}.
