-module(glexml@selector).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/glexml/selector.gleam").
-export([parse/1, 'query'/2, query_first/2, select/2, matches/2, error_to_string/1]).
-export_type([selector/0, selector_error/0, complex/0, combinator/0, simple/0, name_test/0, attr_test/0, context/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " CSS selectors for glexml documents.\n"
    "\n"
    " ```gleam\n"
    " import glexml\n"
    " import glexml/selector\n"
    "\n"
    " let assert Ok(document) = glexml.parse(opf_source)\n"
    " selector.select(document.root, \"manifest > item[properties~=nav]\")\n"
    " // -> Ok([the nav item])\n"
    " ```\n"
    "\n"
    " Supported syntax:\n"
    "\n"
    " - Type selectors and the universal selector: `item`, `*`\n"
    " - Attribute selectors: `[href]`, `[rel=next]`, `[properties~=nav]`,\n"
    "   `[lang|=en]`, `[href^=http]`, `[href$=.xhtml]`, `[href*=chapter]`\n"
    " - Class and ID shorthands, by the usual XML convention: `.title` means\n"
    "   `[class~=title]` and `#toc` means `[id=toc]`\n"
    " - Combinators: descendant (`nav a`), child (`spine > itemref`),\n"
    "   adjacent sibling (`h1 + p`), general sibling (`h1 ~ p`)\n"
    " - Selector lists: `metadata, manifest`\n"
    " - Pseudo-classes: `:first-child`, `:last-child`, `:only-child`,\n"
    "   `:empty`, `:root`, `:nth-child(2)` / `(odd)` / `(even)` / `(2n+1)`,\n"
    "   and `:not(...)` with a list of compound selectors\n"
    "\n"
    " XML-specific behaviour, since names here are literal strings rather\n"
    " than resolved namespaces:\n"
    "\n"
    " - Matching is case-sensitive throughout, as XML requires.\n"
    " - A plain name matches exactly, prefix included: `title` does not match\n"
    "   `dc:title`.\n"
    " - `dc|title` matches the literal qualified name `dc:title` (the prefix\n"
    "   as written in the document, not a namespace URI).\n"
    " - `|title` and `*|title` match any element with local name `title`,\n"
    "   whatever its prefix.\n"
    " - The same applies to attribute names, where a literal colon is also\n"
    "   accepted: `[epub|type=toc]` and `[epub:type=toc]` are equivalent.\n"
).

-opaque selector() :: {selector, list(complex())}.

-type selector_error() :: empty_selector |
    unexpected_end_of_selector |
    {unexpected_character, binary()} |
    {unknown_pseudo_class, binary()} |
    {invalid_nth, binary()}.

-type complex() :: {complex,
        list(simple()),
        list({combinator(), list(simple())})}.

-type combinator() :: descendant | child | next_sibling | subsequent_sibling.

-type simple() :: {tag, name_test()} |
    {class, binary()} |
    {id, binary()} |
    {attr, name_test(), attr_test()} |
    first_child |
    last_child |
    only_child |
    empty |
    root |
    {nth_child, integer(), integer()} |
    {'not', list(list(simple()))}.

-type name_test() :: {exact_name, binary()} | {local_name, binary()} | any_name.

-type attr_test() :: present |
    {equals, binary()} |
    {includes, binary()} |
    {dash_match, binary()} |
    {starts_with, binary()} |
    {ends_with, binary()} |
    {contains, binary()}.

-type context() :: {context,
        glexml:element(),
        gleam@option:option(context()),
        list(glexml:element()),
        list(glexml:element())}.

-file("src/glexml/selector.gleam", 731).
-spec unexpected(binary()) -> {ok, any()} | {error, selector_error()}.
unexpected(Input) ->
    case gleam_stdlib:string_pop_grapheme(Input) of
        {ok, {Grapheme, _}} ->
            {error, {unexpected_character, Grapheme}};

        {error, nil} ->
            {error, unexpected_end_of_selector}
    end.

-file("src/glexml/selector.gleam", 719).
-spec skip_space(binary()) -> binary().
skip_space(Input) ->
    case Input of
        <<" "/utf8, Rest/binary>> ->
            skip_space(Rest);

        <<"\t"/utf8, Rest/binary>> ->
            skip_space(Rest);

        <<"\n"/utf8, Rest/binary>> ->
            skip_space(Rest);

        _ ->
            Input
    end.

-file("src/glexml/selector.gleam", 633).
?DOC(" Parse the `an+b` argument of `:nth-child()`.\n").
-spec parse_nth(binary()) -> {ok, {integer(), integer()}} |
    {error, selector_error()}.
parse_nth(Argument) ->
    Cleaned = begin
        _pipe = Argument,
        _pipe@1 = gleam@string:replace(_pipe, <<" "/utf8>>, <<""/utf8>>),
        string:lowercase(_pipe@1)
    end,
    case Cleaned of
        <<"odd"/utf8>> ->
            {ok, {2, 1}};

        <<"even"/utf8>> ->
            {ok, {2, 0}};

        _ ->
            case gleam@string:split_once(Cleaned, <<"n"/utf8>>) of
                {error, nil} ->
                    case gleam_stdlib:parse_int(Cleaned) of
                        {ok, B} ->
                            {ok, {0, B}};

                        {error, nil} ->
                            {error, {invalid_nth, Argument}}
                    end;

                {ok, {A_part, B_part}} ->
                    A = case A_part of
                        <<""/utf8>> ->
                            {ok, 1};

                        <<"+"/utf8>> ->
                            {ok, 1};

                        <<"-"/utf8>> ->
                            {ok, -1};

                        <<"+"/utf8, Digits/binary>> ->
                            gleam_stdlib:parse_int(Digits);

                        _ ->
                            gleam_stdlib:parse_int(A_part)
                    end,
                    B@1 = case B_part of
                        <<""/utf8>> ->
                            {ok, 0};

                        <<"+"/utf8, Digits@1/binary>> ->
                            gleam_stdlib:parse_int(Digits@1);

                        _ ->
                            gleam_stdlib:parse_int(B_part)
                    end,
                    case {A, B@1} of
                        {{ok, A@1}, {ok, B@2}} ->
                            {ok, {A@1, B@2}};

                        {_, _} ->
                            {error, {invalid_nth, Argument}}
                    end
            end
    end.

-file("src/glexml/selector.gleam", 700).
-spec is_ident_grapheme(binary(), boolean()) -> boolean().
is_ident_grapheme(Grapheme, Allow_colon) ->
    case Grapheme of
        <<"-"/utf8>> ->
            true;

        <<"_"/utf8>> ->
            true;

        <<":"/utf8>> ->
            Allow_colon;

        _ ->
            case gleam@string:to_utf_codepoints(Grapheme) of
                [Codepoint] ->
                    Code = gleam_stdlib:identity(Codepoint),
                    ((((Code >= 48) andalso (Code =< 57)) orelse ((Code >= 65)
                    andalso (Code =< 90)))
                    orelse ((Code >= 97) andalso (Code =< 122)))
                    orelse (Code > 127);

                _ ->
                    true
            end
    end.

-file("src/glexml/selector.gleam", 685).
-spec do_parse_ident(binary(), boolean(), list(binary())) -> {binary(),
    binary()}.
do_parse_ident(Input, Allow_colon, Acc) ->
    case gleam_stdlib:string_pop_grapheme(Input) of
        {ok, {Grapheme, Rest}} ->
            case is_ident_grapheme(Grapheme, Allow_colon) of
                true ->
                    do_parse_ident(Rest, Allow_colon, [Grapheme | Acc]);

                false ->
                    {erlang:list_to_binary(lists:reverse(Acc)), Input}
            end;

        {error, nil} ->
            {erlang:list_to_binary(lists:reverse(Acc)), Input}
    end.

-file("src/glexml/selector.gleam", 681).
-spec parse_ident(binary(), boolean()) -> {binary(), binary()}.
parse_ident(Input, Allow_colon) ->
    do_parse_ident(Input, Allow_colon, []).

-file("src/glexml/selector.gleam", 671).
-spec expect_ident(binary(), boolean()) -> {ok, {binary(), binary()}} |
    {error, selector_error()}.
expect_ident(Input, Allow_colon) ->
    case parse_ident(Input, Allow_colon) of
        {<<""/utf8>>, _} ->
            unexpected(Input);

        {Name, Rest} ->
            {ok, {Name, Rest}}
    end.

-file("src/glexml/selector.gleam", 572).
-spec parse_unquoted_value(binary(), list(binary())) -> {binary(), binary()}.
parse_unquoted_value(Input, Acc) ->
    case gleam_stdlib:string_pop_grapheme(Input) of
        {ok, {Grapheme, Rest}} ->
            case Grapheme of
                <<"]"/utf8>> ->
                    {erlang:list_to_binary(lists:reverse(Acc)), Input};

                <<" "/utf8>> ->
                    {erlang:list_to_binary(lists:reverse(Acc)), Input};

                <<"\t"/utf8>> ->
                    {erlang:list_to_binary(lists:reverse(Acc)), Input};

                <<"\n"/utf8>> ->
                    {erlang:list_to_binary(lists:reverse(Acc)), Input};

                <<"\""/utf8>> ->
                    {erlang:list_to_binary(lists:reverse(Acc)), Input};

                <<"'"/utf8>> ->
                    {erlang:list_to_binary(lists:reverse(Acc)), Input};

                _ ->
                    parse_unquoted_value(Rest, [Grapheme | Acc])
            end;

        {error, nil} ->
            {erlang:list_to_binary(lists:reverse(Acc)), Input}
    end.

-file("src/glexml/selector.gleam", 548).
-spec parse_attribute_value(binary()) -> {ok, {binary(), binary()}} |
    {error, selector_error()}.
parse_attribute_value(Input) ->
    case Input of
        <<"\""/utf8, Rest/binary>> ->
            case gleam@string:split_once(Rest, <<"\""/utf8>>) of
                {ok, {Value, Rest@1}} ->
                    {ok, {Value, Rest@1}};

                {error, nil} ->
                    {error, unexpected_end_of_selector}
            end;

        <<"'"/utf8, Rest@2/binary>> ->
            case gleam@string:split_once(Rest@2, <<"'"/utf8>>) of
                {ok, {Value@1, Rest@3}} ->
                    {ok, {Value@1, Rest@3}};

                {error, nil} ->
                    {error, unexpected_end_of_selector}
            end;

        _ ->
            {Value@2, Rest@4} = parse_unquoted_value(Input, []),
            case Value@2 of
                <<""/utf8>> ->
                    unexpected(Input);

                _ ->
                    {ok, {Value@2, Rest@4}}
            end
    end.

-file("src/glexml/selector.gleam", 535).
-spec finish_attribute(binary(), name_test(), fun((binary()) -> attr_test())) -> {ok,
        {simple(), binary()}} |
    {error, selector_error()}.
finish_attribute(Input, Name, Value_test) ->
    gleam@result:'try'(
        parse_attribute_value(skip_space(Input)),
        fun(_use0) ->
            {Value, Input@1} = _use0,
            Input@2 = skip_space(Input@1),
            case Input@2 of
                <<"]"/utf8, Rest/binary>> ->
                    {ok, {{attr, Name, Value_test(Value)}, Rest}};

                _ ->
                    unexpected(Input@2)
            end
        end
    ).

-file("src/glexml/selector.gleam", 506).
-spec parse_attribute_name(binary()) -> {ok, {name_test(), binary()}} |
    {error, selector_error()}.
parse_attribute_name(Input) ->
    case Input of
        <<"*|"/utf8, Rest/binary>> ->
            gleam@result:'try'(
                expect_ident(Rest, false),
                fun(_use0) ->
                    {Name, Rest@1} = _use0,
                    {ok, {{local_name, Name}, Rest@1}}
                end
            );

        <<"|"/utf8, Rest@2/binary>> ->
            gleam@result:'try'(
                expect_ident(Rest@2, false),
                fun(_use0@1) ->
                    {Name@1, Rest@3} = _use0@1,
                    {ok, {{local_name, Name@1}, Rest@3}}
                end
            );

        _ ->
            gleam@result:'try'(
                expect_ident(Input, true),
                fun(_use0@2) ->
                    {Name@2, Rest@4} = _use0@2,
                    case Rest@4 of
                        <<"|="/utf8, _/binary>> ->
                            {ok, {{exact_name, Name@2}, Rest@4}};

                        <<"|"/utf8, After/binary>> ->
                            gleam@result:'try'(
                                expect_ident(After, false),
                                fun(_use0@3) ->
                                    {Local, After@1} = _use0@3,
                                    {ok,
                                        {{exact_name,
                                                <<<<Name@2/binary, ":"/utf8>>/binary,
                                                    Local/binary>>},
                                            After@1}}
                                end
                            );

                        _ ->
                            {ok, {{exact_name, Name@2}, Rest@4}}
                    end
                end
            )
    end.

-file("src/glexml/selector.gleam", 488).
?DOC(" Parse an attribute selector. The input begins after the `[`.\n").
-spec parse_attribute_selector(binary()) -> {ok, {simple(), binary()}} |
    {error, selector_error()}.
parse_attribute_selector(Input) ->
    Input@1 = skip_space(Input),
    gleam@result:'try'(
        parse_attribute_name(Input@1),
        fun(_use0) ->
            {Name, Input@2} = _use0,
            Input@3 = skip_space(Input@2),
            case Input@3 of
                <<"]"/utf8, Rest/binary>> ->
                    {ok, {{attr, Name, present}, Rest}};

                <<"~="/utf8, Rest@1/binary>> ->
                    finish_attribute(
                        Rest@1,
                        Name,
                        fun(Field@0) -> {includes, Field@0} end
                    );

                <<"|="/utf8, Rest@2/binary>> ->
                    finish_attribute(
                        Rest@2,
                        Name,
                        fun(Field@0) -> {dash_match, Field@0} end
                    );

                <<"^="/utf8, Rest@3/binary>> ->
                    finish_attribute(
                        Rest@3,
                        Name,
                        fun(Field@0) -> {starts_with, Field@0} end
                    );

                <<"$="/utf8, Rest@4/binary>> ->
                    finish_attribute(
                        Rest@4,
                        Name,
                        fun(Field@0) -> {ends_with, Field@0} end
                    );

                <<"*="/utf8, Rest@5/binary>> ->
                    finish_attribute(
                        Rest@5,
                        Name,
                        fun(Field@0) -> {contains, Field@0} end
                    );

                <<"="/utf8, Rest@6/binary>> ->
                    finish_attribute(
                        Rest@6,
                        Name,
                        fun(Field@0) -> {equals, Field@0} end
                    );

                _ ->
                    unexpected(Input@3)
            end
        end
    ).

-file("src/glexml/selector.gleam", 431).
-spec parse_type_selector(binary()) -> {ok, {list(simple()), binary()}} |
    {error, selector_error()}.
parse_type_selector(Input) ->
    case Input of
        <<"*|*"/utf8, Rest/binary>> ->
            {ok, {[{tag, any_name}], Rest}};

        <<"*|"/utf8, Rest@1/binary>> ->
            gleam@result:'try'(
                expect_ident(Rest@1, false),
                fun(_use0) ->
                    {Name, Rest@2} = _use0,
                    {ok, {[{tag, {local_name, Name}}], Rest@2}}
                end
            );

        <<"*"/utf8, Rest@3/binary>> ->
            {ok, {[{tag, any_name}], Rest@3}};

        <<"|"/utf8, Rest@4/binary>> ->
            gleam@result:'try'(
                expect_ident(Rest@4, false),
                fun(_use0@1) ->
                    {Name@1, Rest@5} = _use0@1,
                    {ok, {[{tag, {local_name, Name@1}}], Rest@5}}
                end
            );

        _ ->
            {Name@2, Rest@6} = parse_ident(Input, false),
            case Name@2 of
                <<""/utf8>> ->
                    {ok, {[], Input}};

                _ ->
                    case Rest@6 of
                        <<"|"/utf8, After/binary>> ->
                            gleam@result:'try'(
                                expect_ident(After, false),
                                fun(_use0@2) ->
                                    {Local, After@1} = _use0@2,
                                    {ok,
                                        {[{tag,
                                                    {exact_name,
                                                        <<<<Name@2/binary,
                                                                ":"/utf8>>/binary,
                                                            Local/binary>>}}],
                                            After@1}}
                                end
                            );

                        _ ->
                            {ok, {[{tag, {exact_name, Name@2}}], Rest@6}}
                    end
            end
    end.

-file("src/glexml/selector.gleam", 618).
-spec parse_not_list(binary(), list(list(simple()))) -> {ok,
        {simple(), binary()}} |
    {error, selector_error()}.
parse_not_list(Input, Acc) ->
    Input@1 = skip_space(Input),
    gleam@result:'try'(
        parse_compound(Input@1),
        fun(_use0) ->
            {Compound, Input@2} = _use0,
            Input@3 = skip_space(Input@2),
            case Input@3 of
                <<")"/utf8, Rest/binary>> ->
                    {ok, {{'not', lists:reverse([Compound | Acc])}, Rest}};

                <<","/utf8, Rest@1/binary>> ->
                    parse_not_list(Rest@1, [Compound | Acc]);

                _ ->
                    unexpected(Input@3)
            end
        end
    ).

-file("src/glexml/selector.gleam", 587).
?DOC(" Parse a pseudo-class. The input begins after the `:`.\n").
-spec parse_pseudo_class(binary()) -> {ok, {simple(), binary()}} |
    {error, selector_error()}.
parse_pseudo_class(Input) ->
    gleam@result:'try'(
        expect_ident(Input, false),
        fun(_use0) ->
            {Name, Input@1} = _use0,
            case Name of
                <<"first-child"/utf8>> ->
                    {ok, {first_child, Input@1}};

                <<"last-child"/utf8>> ->
                    {ok, {last_child, Input@1}};

                <<"only-child"/utf8>> ->
                    {ok, {only_child, Input@1}};

                <<"empty"/utf8>> ->
                    {ok, {empty, Input@1}};

                <<"root"/utf8>> ->
                    {ok, {root, Input@1}};

                <<"nth-child"/utf8>> ->
                    case Input@1 of
                        <<"("/utf8, Rest/binary>> ->
                            case gleam@string:split_once(Rest, <<")"/utf8>>) of
                                {error, nil} ->
                                    {error, unexpected_end_of_selector};

                                {ok, {Argument, Rest@1}} ->
                                    gleam@result:'try'(
                                        parse_nth(Argument),
                                        fun(_use0@1) ->
                                            {A, B} = _use0@1,
                                            {ok, {{nth_child, A, B}, Rest@1}}
                                        end
                                    )
                            end;

                        _ ->
                            unexpected(Input@1)
                    end;

                <<"not"/utf8>> ->
                    case Input@1 of
                        <<"("/utf8, Rest@2/binary>> ->
                            parse_not_list(Rest@2, []);

                        _ ->
                            unexpected(Input@1)
                    end;

                _ ->
                    {error, {unknown_pseudo_class, Name}}
            end
        end
    ).

-file("src/glexml/selector.gleam", 462).
-spec parse_simple_suffixes(binary(), list(simple())) -> {ok,
        {list(simple()), binary()}} |
    {error, selector_error()}.
parse_simple_suffixes(Input, Acc) ->
    case Input of
        <<"."/utf8, Rest/binary>> ->
            gleam@result:'try'(
                expect_ident(Rest, false),
                fun(_use0) ->
                    {Name, Rest@1} = _use0,
                    parse_simple_suffixes(Rest@1, [{class, Name} | Acc])
                end
            );

        <<"#"/utf8, Rest@2/binary>> ->
            gleam@result:'try'(
                expect_ident(Rest@2, false),
                fun(_use0@1) ->
                    {Name@1, Rest@3} = _use0@1,
                    parse_simple_suffixes(Rest@3, [{id, Name@1} | Acc])
                end
            );

        <<"["/utf8, Rest@4/binary>> ->
            gleam@result:'try'(
                parse_attribute_selector(Rest@4),
                fun(_use0@2) ->
                    {Part, Rest@5} = _use0@2,
                    parse_simple_suffixes(Rest@5, [Part | Acc])
                end
            );

        <<":"/utf8, Rest@6/binary>> ->
            gleam@result:'try'(
                parse_pseudo_class(Rest@6),
                fun(_use0@3) ->
                    {Part@1, Rest@7} = _use0@3,
                    parse_simple_suffixes(Rest@7, [Part@1 | Acc])
                end
            );

        _ ->
            {ok, {Acc, Input}}
    end.

-file("src/glexml/selector.gleam", 420).
-spec parse_compound(binary()) -> {ok, {list(simple()), binary()}} |
    {error, selector_error()}.
parse_compound(Input) ->
    gleam@result:'try'(
        parse_type_selector(Input),
        fun(_use0) ->
            {Parts, Rest} = _use0,
            gleam@result:'try'(
                parse_simple_suffixes(Rest, Parts),
                fun(_use0@1) ->
                    {Parts@1, Rest@1} = _use0@1,
                    case Parts@1 of
                        [] ->
                            unexpected(Input);

                        _ ->
                            {ok, {lists:reverse(Parts@1), Rest@1}}
                    end
                end
            )
        end
    ).

-file("src/glexml/selector.gleam", 726).
-spec skip_space_counted(binary()) -> {boolean(), binary()}.
skip_space_counted(Input) ->
    Rest = skip_space(Input),
    {Rest /= Input, Rest}.

-file("src/glexml/selector.gleam", 409).
-spec parse_combined(
    binary(),
    combinator(),
    list(simple()),
    list({combinator(), list(simple())})
) -> {ok, {complex(), binary()}} | {error, selector_error()}.
parse_combined(Input, Combinator, Key, Trail) ->
    Input@1 = skip_space(Input),
    gleam@result:'try'(
        parse_compound(Input@1),
        fun(_use0) ->
            {Compound, Input@2} = _use0,
            parse_trail(Input@2, Compound, [{Combinator, Key} | Trail])
        end
    ).

-file("src/glexml/selector.gleam", 389).
-spec parse_trail(
    binary(),
    list(simple()),
    list({combinator(), list(simple())})
) -> {ok, {complex(), binary()}} | {error, selector_error()}.
parse_trail(Input, Key, Trail) ->
    {Spaced, Rest} = skip_space_counted(Input),
    case Rest of
        <<""/utf8>> ->
            {ok, {{complex, Key, Trail}, Rest}};

        <<","/utf8, _/binary>> ->
            {ok, {{complex, Key, Trail}, Rest}};

        <<">"/utf8, Next/binary>> ->
            parse_combined(Next, child, Key, Trail);

        <<"+"/utf8, Next@1/binary>> ->
            parse_combined(Next@1, next_sibling, Key, Trail);

        <<"~"/utf8, Next@2/binary>> ->
            parse_combined(Next@2, subsequent_sibling, Key, Trail);

        _ ->
            case Spaced of
                true ->
                    parse_combined(Rest, descendant, Key, Trail);

                false ->
                    unexpected(Rest)
            end
    end.

-file("src/glexml/selector.gleam", 384).
-spec parse_complex(binary()) -> {ok, {complex(), binary()}} |
    {error, selector_error()}.
parse_complex(Input) ->
    gleam@result:'try'(
        parse_compound(Input),
        fun(_use0) ->
            {Compound, Input@1} = _use0,
            parse_trail(Input@1, Compound, [])
        end
    ).

-file("src/glexml/selector.gleam", 370).
-spec parse_alternatives(binary(), list(complex())) -> {ok, selector()} |
    {error, selector_error()}.
parse_alternatives(Input, Acc) ->
    Input@1 = skip_space(Input),
    gleam@result:'try'(
        parse_complex(Input@1),
        fun(_use0) ->
            {Complex, Input@2} = _use0,
            Input@3 = skip_space(Input@2),
            case Input@3 of
                <<""/utf8>> ->
                    {ok, {selector, lists:reverse([Complex | Acc])}};

                <<","/utf8, Rest/binary>> ->
                    parse_alternatives(Rest, [Complex | Acc]);

                _ ->
                    unexpected(Input@3)
            end
        end
    ).

-file("src/glexml/selector.gleam", 121).
?DOC(" Parse a selector string.\n").
-spec parse(binary()) -> {ok, selector()} | {error, selector_error()}.
parse(Input) ->
    case gleam@string:trim(Input) of
        <<""/utf8>> ->
            {error, empty_selector};

        Input@1 ->
            parse_alternatives(Input@1, [])
    end.

-file("src/glexml/selector.gleam", 174).
-spec root_context(glexml:element()) -> context().
root_context(Element) ->
    {context, Element, none, [], []}.

-file("src/glexml/selector.gleam", 360).
?DOC(
    " Whether a 1-based child index satisfies an `an+b` pattern for some\n"
    " non-negative integer n.\n"
).
-spec nth_matches(integer(), integer(), integer()) -> boolean().
nth_matches(A, B, Index) ->
    Distance = Index - B,
    case A of
        0 ->
            Distance =:= 0;

        _ ->
            ((case A of
                0 -> 0;
                Gleam@denominator -> Distance rem Gleam@denominator
            end) =:= 0) andalso ((case A of
                0 -> 0;
                Gleam@denominator@1 -> Distance div Gleam@denominator@1
            end) >= 0)
    end.

-file("src/glexml/selector.gleam", 352).
-spec includes_word(binary(), binary()) -> boolean().
includes_word(Value, Word) ->
    _pipe = Value,
    _pipe@1 = gleam@string:split(_pipe, <<" "/utf8>>),
    gleam@list:any(
        _pipe@1,
        fun(Candidate) ->
            (Candidate /= <<""/utf8>>) andalso (Candidate =:= Word)
        end
    ).

-file("src/glexml/selector.gleam", 339).
-spec matches_attribute(binary(), attr_test()) -> boolean().
matches_attribute(Value, Value_test) ->
    case Value_test of
        present ->
            true;

        {equals, Expected} ->
            Value =:= Expected;

        {includes, Word} ->
            includes_word(Value, Word);

        {dash_match, Expected@1} ->
            (Value =:= Expected@1) orelse gleam_stdlib:string_starts_with(
                Value,
                <<Expected@1/binary, "-"/utf8>>
            );

        {starts_with, Prefix} ->
            (Prefix /= <<""/utf8>>) andalso gleam_stdlib:string_starts_with(
                Value,
                Prefix
            );

        {ends_with, Suffix} ->
            (Suffix /= <<""/utf8>>) andalso gleam_stdlib:string_ends_with(
                Value,
                Suffix
            );

        {contains, Inner} ->
            (Inner /= <<""/utf8>>) andalso gleam_stdlib:contains_string(
                Value,
                Inner
            )
    end.

-file("src/glexml/selector.gleam", 331).
-spec matches_name(binary(), name_test()) -> boolean().
matches_name(Name, Name_test) ->
    case Name_test of
        any_name ->
            true;

        {exact_name, Expected} ->
            Name =:= Expected;

        {local_name, Expected@1} ->
            glexml:local_name(Name) =:= Expected@1
    end.

-file("src/glexml/selector.gleam", 293).
-spec matches_simple(context(), simple()) -> boolean().
matches_simple(Context, Simple) ->
    Element = erlang:element(2, Context),
    case Simple of
        {tag, Name_test} ->
            matches_name(erlang:element(2, Element), Name_test);

        {class, Class} ->
            case glexml:attribute(Element, <<"class"/utf8>>) of
                {ok, Value} ->
                    includes_word(Value, Class);

                {error, nil} ->
                    false
            end;

        {id, Id} ->
            glexml:attribute(Element, <<"id"/utf8>>) =:= {ok, Id};

        {attr, Name_test@1, Value_test} ->
            gleam@list:any(
                erlang:element(3, Element),
                fun(Attribute) ->
                    matches_name(erlang:element(2, Attribute), Name_test@1)
                    andalso matches_attribute(
                        erlang:element(3, Attribute),
                        Value_test
                    )
                end
            );

        first_child ->
            erlang:element(4, Context) =:= [];

        last_child ->
            erlang:element(5, Context) =:= [];

        only_child ->
            (erlang:element(4, Context) =:= []) andalso (erlang:element(
                5,
                Context
            )
            =:= []);

        empty ->
            not gleam@list:any(
                erlang:element(4, Element),
                fun(Node) -> case Node of
                        {element_node, _} ->
                            true;

                        {text_node, _, _} ->
                            true;

                        {entity_reference_node, _} ->
                            true;

                        _ ->
                            false
                    end end
            );

        root ->
            case erlang:element(3, Context) of
                none ->
                    true;

                {some, _} ->
                    false
            end;

        {nth_child, A, B} ->
            nth_matches(A, B, erlang:length(erlang:element(4, Context)) + 1);

        {'not', Compounds} ->
            not gleam@list:any(
                Compounds,
                fun(Compound) -> matches_compound(Context, Compound) end
            )
    end.

-file("src/glexml/selector.gleam", 289).
-spec matches_compound(context(), list(simple())) -> boolean().
matches_compound(Context, Compound) ->
    gleam@list:all(Compound, fun(Simple) -> matches_simple(Context, Simple) end).

-file("src/glexml/selector.gleam", 274).
-spec previous_sibling(context()) -> gleam@option:option(context()).
previous_sibling(Context) ->
    case erlang:element(4, Context) of
        [] ->
            none;

        [Previous | Older] ->
            {some,
                {context,
                    Previous,
                    erlang:element(3, Context),
                    Older,
                    [erlang:element(2, Context) | erlang:element(5, Context)]}}
    end.

-file("src/glexml/selector.gleam", 261).
-spec matches_some_preceding_sibling(
    context(),
    list(simple()),
    list({combinator(), list(simple())})
) -> boolean().
matches_some_preceding_sibling(Context, Compound, Rest) ->
    case previous_sibling(Context) of
        none ->
            false;

        {some, Previous} ->
            (matches_compound(Previous, Compound) andalso matches_trail(
                Previous,
                Rest
            ))
            orelse matches_some_preceding_sibling(Previous, Compound, Rest)
    end.

-file("src/glexml/selector.gleam", 248).
-spec matches_some_ancestor(
    context(),
    list(simple()),
    list({combinator(), list(simple())})
) -> boolean().
matches_some_ancestor(Context, Compound, Rest) ->
    case erlang:element(3, Context) of
        none ->
            false;

        {some, Parent} ->
            (matches_compound(Parent, Compound) andalso matches_trail(
                Parent,
                Rest
            ))
            orelse matches_some_ancestor(Parent, Compound, Rest)
    end.

-file("src/glexml/selector.gleam", 223).
-spec matches_trail(context(), list({combinator(), list(simple())})) -> boolean().
matches_trail(Context, Trail) ->
    case Trail of
        [] ->
            true;

        [{child, Compound} | Rest] ->
            case erlang:element(3, Context) of
                {some, Parent} ->
                    matches_compound(Parent, Compound) andalso matches_trail(
                        Parent,
                        Rest
                    );

                none ->
                    false
            end;

        [{descendant, Compound@1} | Rest@1] ->
            matches_some_ancestor(Context, Compound@1, Rest@1);

        [{next_sibling, Compound@2} | Rest@2] ->
            case previous_sibling(Context) of
                {some, Previous} ->
                    matches_compound(Previous, Compound@2) andalso matches_trail(
                        Previous,
                        Rest@2
                    );

                none ->
                    false
            end;

        [{subsequent_sibling, Compound@3} | Rest@3] ->
            matches_some_preceding_sibling(Context, Compound@3, Rest@3)
    end.

-file("src/glexml/selector.gleam", 218).
-spec matches_complex(context(), complex()) -> boolean().
matches_complex(Context, Complex) ->
    matches_compound(Context, erlang:element(2, Complex)) andalso matches_trail(
        Context,
        erlang:element(3, Complex)
    ).

-file("src/glexml/selector.gleam", 213).
-spec matches_context(context(), selector()) -> boolean().
matches_context(Context, Selector) ->
    {selector, Alternatives} = Selector,
    gleam@list:any(
        Alternatives,
        fun(Complex) -> matches_complex(Context, Complex) end
    ).

-file("src/glexml/selector.gleam", 196).
-spec walk_children(
    list(glexml:element()),
    context(),
    list(glexml:element()),
    selector(),
    list(glexml:element())
) -> list(glexml:element()).
walk_children(Children, Parent, Preceding, Selector, Acc) ->
    case Children of
        [] ->
            Acc;

        [Child | Rest] ->
            Context = {context, Child, {some, Parent}, Preceding, Rest},
            Acc@1 = walk(Context, Selector, Acc),
            walk_children(Rest, Parent, [Child | Preceding], Selector, Acc@1)
    end.

-file("src/glexml/selector.gleam", 178).
-spec walk(context(), selector(), list(glexml:element())) -> list(glexml:element()).
walk(Context, Selector, Acc) ->
    Acc@1 = case matches_context(Context, Selector) of
        true ->
            [erlang:element(2, Context) | Acc];

        false ->
            Acc
    end,
    walk_children(
        glexml:child_elements(erlang:element(2, Context)),
        Context,
        [],
        Selector,
        Acc@1
    ).

-file("src/glexml/selector.gleam", 131).
?DOC(
    " Find every element in the tree matching the selector, in document order.\n"
    " The given element is part of the tree being searched, so `query(root,\n"
    " \":root\")` returns the root itself.\n"
).
-spec 'query'(glexml:element(), selector()) -> list(glexml:element()).
'query'(Element, Selector) ->
    _pipe = walk(root_context(Element), Selector, []),
    lists:reverse(_pipe).

-file("src/glexml/selector.gleam", 137).
?DOC(" Find the first element in document order matching the selector.\n").
-spec query_first(glexml:element(), selector()) -> {ok, glexml:element()} |
    {error, nil}.
query_first(Element, Selector) ->
    _pipe = 'query'(Element, Selector),
    gleam@list:first(_pipe).

-file("src/glexml/selector.gleam", 146).
?DOC(
    " Parse and run a selector in one step. Prefer `parse` + `query` when the\n"
    " same selector is used repeatedly.\n"
).
-spec select(glexml:element(), binary()) -> {ok, list(glexml:element())} |
    {error, selector_error()}.
select(Element, Selector) ->
    gleam@result:'try'(
        parse(Selector),
        fun(Selector@1) -> {ok, 'query'(Element, Selector@1)} end
    ).

-file("src/glexml/selector.gleam", 156).
?DOC(
    " Whether the element itself matches the selector, treating it as the root\n"
    " of its own tree.\n"
).
-spec matches(glexml:element(), selector()) -> boolean().
matches(Element, Selector) ->
    matches_context(root_context(Element), Selector).

-file("src/glexml/selector.gleam", 161).
?DOC(" Convert a `SelectorError` into a human readable message.\n").
-spec error_to_string(selector_error()) -> binary().
error_to_string(Error) ->
    case Error of
        empty_selector ->
            <<"the selector is empty"/utf8>>;

        unexpected_end_of_selector ->
            <<"the selector ended unexpectedly"/utf8>>;

        {unexpected_character, Character} ->
            <<<<"unexpected \""/utf8, Character/binary>>/binary,
                "\" in selector"/utf8>>;

        {unknown_pseudo_class, Name} ->
            <<<<"unknown pseudo-class \":"/utf8, Name/binary>>/binary,
                "\""/utf8>>;

        {invalid_nth, Argument} ->
            <<<<"invalid :nth-child argument \""/utf8, Argument/binary>>/binary,
                "\""/utf8>>
    end.
