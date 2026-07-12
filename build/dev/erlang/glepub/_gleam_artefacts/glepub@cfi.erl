-module(glepub@cfi).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/glepub/cfi.gleam").
-export([parse/1, path_to_string/1, to_string/1, locate/1, spine_item/2]).
-export_type([step/0, cfi/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " EPUB Canonical Fragment Identifiers — `epubcfi(/6/4!/4/10/2:3)` — the\n"
    " standard way to address a point inside a publication.\n"
    "\n"
    " A CFI is a path of child steps. Even indices address element children\n"
    " (`/2` is the first element child, `/4` the second, …), odd indices the\n"
    " text between them, and `!` steps out of the package document into the\n"
    " content document the itemref references. The part before the first `!`\n"
    " identifies the spine item — `SpineItem.cfi` holds exactly that path —\n"
    " and the rest addresses a node inside the chapter, optionally ending in\n"
    " a `:n` character offset into a text node. A step may carry an\n"
    " `[assertion]`, usually the id the addressed element is expected to\n"
    " have.\n"
    "\n"
    " This module parses and prints point CFIs and locates them in a book's\n"
    " spine. Range CFIs (`epubcfi(/6/4!/4,/10/2:1,/10/2:5)`) and the\n"
    " temporal/spatial offsets used for audio and images are not supported.\n"
).

-type step() :: {step, integer(), gleam@option:option(binary())}.

-type cfi() :: {cfi, list(list(step())), gleam@option:option(integer())}.

-file("src/glepub/cfi.gleam", 86).
-spec finish(list(list(step())), list(step()), gleam@option:option(integer())) -> {ok,
        cfi()} |
    {error, nil}.
finish(Parts, Steps, Offset) ->
    case {Parts, Steps} of
        {[], []} ->
            {error, nil};

        {_, []} ->
            {error, nil};

        {_, _} ->
            {ok, {cfi, lists:reverse([lists:reverse(Steps) | Parts]), Offset}}
    end.

-file("src/glepub/cfi.gleam", 104).
-spec span_digits(binary(), binary()) -> {binary(), binary()}.
span_digits(Text, Taken) ->
    case gleam_stdlib:string_pop_grapheme(Text) of
        {ok, {Grapheme, Rest}} ->
            case Grapheme of
                <<"0"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                <<"1"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                <<"2"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                <<"3"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                <<"4"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                <<"5"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                <<"6"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                <<"7"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                <<"8"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                <<"9"/utf8>> ->
                    span_digits(Rest, <<Taken/binary, Grapheme/binary>>);

                _ ->
                    {Taken, Text}
            end;

        {error, nil} ->
            {Taken, Text}
    end.

-file("src/glepub/cfi.gleam", 98).
-spec take_int(binary()) -> {ok, {integer(), binary()}} | {error, nil}.
take_int(Text) ->
    {Digits, Rest} = span_digits(Text, <<""/utf8>>),
    gleam@result:'try'(
        gleam_stdlib:parse_int(Digits),
        fun(Number) -> {ok, {Number, Rest}} end
    ).

-file("src/glepub/cfi.gleam", 126).
-spec span_assertion(binary(), binary()) -> {ok, {binary(), binary()}} |
    {error, nil}.
span_assertion(Text, Taken) ->
    case gleam_stdlib:string_pop_grapheme(Text) of
        {ok, {<<"]"/utf8>>, Rest}} ->
            {ok, {Taken, Rest}};

        {ok, {<<"^"/utf8>>, Rest@1}} ->
            case gleam_stdlib:string_pop_grapheme(Rest@1) of
                {ok, {Escaped, Rest@2}} ->
                    span_assertion(Rest@2, <<Taken/binary, Escaped/binary>>);

                {error, nil} ->
                    {error, nil}
            end;

        {ok, {Grapheme, Rest@3}} ->
            span_assertion(Rest@3, <<Taken/binary, Grapheme/binary>>);

        {error, nil} ->
            {error, nil}
    end.

-file("src/glepub/cfi.gleam", 116).
-spec take_assertion(binary()) -> {ok,
        {gleam@option:option(binary()), binary()}} |
    {error, nil}.
take_assertion(Text) ->
    case Text of
        <<"["/utf8, Rest/binary>> ->
            gleam@result:'try'(
                span_assertion(Rest, <<""/utf8>>),
                fun(_use0) ->
                    {Assertion, Rest@1} = _use0,
                    {ok, {{some, Assertion}, Rest@1}}
                end
            );

        _ ->
            {ok, {none, Text}}
    end.

-file("src/glepub/cfi.gleam", 58).
-spec parse_parts(binary(), list(list(step())), list(step())) -> {ok, cfi()} |
    {error, nil}.
parse_parts(Text, Parts, Steps) ->
    case Text of
        <<""/utf8>> ->
            finish(Parts, Steps, none);

        <<"!"/utf8, Rest/binary>> ->
            case Steps of
                [] ->
                    {error, nil};

                Steps@1 ->
                    parse_parts(Rest, [lists:reverse(Steps@1) | Parts], [])
            end;

        <<"/"/utf8, Rest@1/binary>> ->
            gleam@result:'try'(
                take_int(Rest@1),
                fun(_use0) ->
                    {Index, Rest@2} = _use0,
                    gleam@result:'try'(
                        take_assertion(Rest@2),
                        fun(_use0@1) ->
                            {Assertion, Rest@3} = _use0@1,
                            parse_parts(
                                Rest@3,
                                Parts,
                                [{step, Index, Assertion} | Steps]
                            )
                        end
                    )
                end
            );

        <<":"/utf8, Rest@4/binary>> ->
            gleam@result:'try'(
                take_int(Rest@4),
                fun(_use0@2) ->
                    {Offset, Rest@5} = _use0@2,
                    case Rest@5 of
                        <<""/utf8>> ->
                            finish(Parts, Steps, {some, Offset});

                        _ ->
                            {error, nil}
                    end
                end
            );

        _ ->
            {error, nil}
    end.

-file("src/glepub/cfi.gleam", 47).
?DOC(" Parse an `epubcfi(...)` string.\n").
-spec parse(binary()) -> {ok, cfi()} | {error, nil}.
parse(Text) ->
    case {gleam_stdlib:string_starts_with(Text, <<"epubcfi("/utf8>>),
        gleam_stdlib:string_ends_with(Text, <<")"/utf8>>)} of
        {true, true} ->
            _pipe = Text,
            _pipe@1 = gleam@string:drop_start(_pipe, 8),
            _pipe@2 = gleam@string:drop_end(_pipe@1, 1),
            parse_parts(_pipe@2, [], []);

        {_, _} ->
            {error, nil}
    end.

-file("src/glepub/cfi.gleam", 171).
-spec escape_assertion(binary()) -> binary().
escape_assertion(Assertion) ->
    _pipe = [<<"^"/utf8>>,
        <<"["/utf8>>,
        <<"]"/utf8>>,
        <<"("/utf8>>,
        <<")"/utf8>>,
        <<","/utf8>>,
        <<";"/utf8>>,
        <<"="/utf8>>],
    gleam@list:fold(
        _pipe,
        Assertion,
        fun(Text, Special) ->
            gleam@string:replace(Text, Special, <<"^"/utf8, Special/binary>>)
        end
    ).

-file("src/glepub/cfi.gleam", 163).
-spec step_to_string(step()) -> binary().
step_to_string(Step) ->
    Assertion@1 = case erlang:element(3, Step) of
        {some, Assertion} ->
            <<<<"["/utf8, (escape_assertion(Assertion))/binary>>/binary,
                "]"/utf8>>;

        none ->
            <<""/utf8>>
    end,
    <<<<"/"/utf8, (erlang:integer_to_binary(erlang:element(2, Step)))/binary>>/binary,
        Assertion@1/binary>>.

-file("src/glepub/cfi.gleam", 151).
?DOC(
    " The CFI path without the `epubcfi(...)` wrapper — the form used for\n"
    " the intra-document part of a fragment, and for joining onto a spine\n"
    " item's base path with `!`.\n"
).
-spec path_to_string(cfi()) -> binary().
path_to_string(Cfi) ->
    Path = begin
        _pipe = erlang:element(2, Cfi),
        _pipe@3 = gleam@list:map(_pipe, fun(Steps) -> _pipe@1 = Steps,
                _pipe@2 = gleam@list:map(_pipe@1, fun step_to_string/1),
                erlang:list_to_binary(_pipe@2) end),
        gleam@string:join(_pipe@3, <<"!"/utf8>>)
    end,
    Offset@1 = case erlang:element(3, Cfi) of
        {some, Offset} ->
            <<":"/utf8, (erlang:integer_to_binary(Offset))/binary>>;

        none ->
            <<""/utf8>>
    end,
    <<Path/binary, Offset@1/binary>>.

-file("src/glepub/cfi.gleam", 144).
?DOC(" Print a CFI back out as an `epubcfi(...)` string.\n").
-spec to_string(cfi()) -> binary().
to_string(Cfi) ->
    <<<<"epubcfi("/utf8, (path_to_string(Cfi))/binary>>/binary, ")"/utf8>>.

-file("src/glepub/cfi.gleam", 205).
-spec spine_position(integer()) -> {ok, integer()} | {error, nil}.
spine_position(Index) ->
    case (Index >= 2) andalso ((Index rem 2) =:= 0) of
        true ->
            {ok, (Index div 2) - 1};

        false ->
            {error, nil}
    end.

-file("src/glepub/cfi.gleam", 180).
?DOC(
    " Split a publication-level CFI into the spine position it addresses and\n"
    " the remainder pointing within that chapter's document, if any.\n"
).
-spec locate(cfi()) -> {ok, {integer(), gleam@option:option(cfi())}} |
    {error, nil}.
locate(Cfi) ->
    case erlang:element(2, Cfi) of
        [Package_steps | Rest] ->
            gleam@result:'try'(
                gleam@list:last(Package_steps),
                fun(Last) ->
                    gleam@result:'try'(
                        spine_position(erlang:element(2, Last)),
                        fun(Index) -> case Rest of
                                [] ->
                                    {ok, {Index, none}};

                                Parts ->
                                    {ok,
                                        {Index,
                                            {some,
                                                {cfi,
                                                    Parts,
                                                    erlang:element(3, Cfi)}}}}
                            end end
                    )
                end
            );

        [] ->
            {error, nil}
    end.

-file("src/glepub/cfi.gleam", 196).
?DOC(
    " The spine item a CFI addresses, with the remainder of the CFI pointing\n"
    " within that chapter's document, if any.\n"
).
-spec spine_item(glepub:book(), cfi()) -> {ok,
        {glepub:spine_item(), gleam@option:option(cfi())}} |
    {error, nil}.
spine_item(Book, Cfi) ->
    gleam@result:'try'(
        locate(Cfi),
        fun(_use0) ->
            {Index, Rest} = _use0,
            gleam@result:'try'(
                begin
                    _pipe = erlang:element(5, Book),
                    _pipe@1 = gleam@list:drop(_pipe, Index),
                    gleam@list:first(_pipe@1)
                end,
                fun(Item) -> {ok, {Item, Rest}} end
            )
        end
    ).
