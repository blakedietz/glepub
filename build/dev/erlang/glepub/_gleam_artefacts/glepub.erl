-module(glepub).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/glepub.gleam").
-export([error_to_string/1, resolve/2, strip_fragment/1, open/1, resource/2, document_with_dtd/3, document/2, item_for_href/2, is_external/1]).
-export_type([book/0, metadata/0, contributor/0, manifest_item/0, spine_item/0, toc_entry/0, direction/0, layout/0, rendition/0, epub_error/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " An EPUB toolkit for the Erlang and JavaScript targets.\n"
    "\n"
    " glepub is the format layer of an EPUB reader: it opens the container,\n"
    " parses the package document (OPF), navigation (EPUB 3 nav documents and\n"
    " EPUB 2 NCX), and exposes a typed `Book` — metadata, manifest, spine,\n"
    " table of contents, landmarks, and cover.\n"
    "\n"
    " Like `glexml` underneath it, glepub performs no I/O of its own. Opening\n"
    " a book takes a `Loader`: a function from a path inside the container to\n"
    " its bytes. Supply one backed by whatever suits the platform — a zip\n"
    " library on the server, a `JSZip`-style reader in the browser, a\n"
    " directory on disk, or a dictionary in tests.\n"
    "\n"
    " ```gleam\n"
    " let assert Ok(book) = glepub.open(loader)\n"
    " book.metadata.title            // -> \"Moby-Dick; or, The Whale\"\n"
    " list.map(book.spine, fn(s) { s.item.href })\n"
    " book.toc                       // -> nested TocEntry tree\n"
    " ```\n"
).

-type book() :: {book,
        binary(),
        metadata(),
        list(manifest_item()),
        list(spine_item()),
        list(toc_entry()),
        list(toc_entry()),
        list(toc_entry()),
        direction(),
        rendition(),
        gleam@option:option(manifest_item()),
        fun((binary()) -> {ok, bitstring()} | {error, nil})}.

-type metadata() :: {metadata,
        binary(),
        binary(),
        binary(),
        list(contributor()),
        list(contributor()),
        gleam@option:option(binary()),
        gleam@option:option(binary()),
        gleam@option:option(binary()),
        gleam@option:option(binary()),
        list(binary()),
        gleam@option:option(binary())}.

-type contributor() :: {contributor,
        binary(),
        gleam@option:option(binary()),
        gleam@option:option(binary())}.

-type manifest_item() :: {manifest_item,
        binary(),
        binary(),
        binary(),
        list(binary())}.

-type spine_item() :: {spine_item, manifest_item(), boolean(), list(binary())}.

-type toc_entry() :: {toc_entry,
        binary(),
        gleam@option:option(binary()),
        list(toc_entry())}.

-type direction() :: left_to_right | right_to_left | default_direction.

-type layout() :: reflowable | pre_paginated.

-type rendition() :: {rendition,
        layout(),
        gleam@option:option(binary()),
        gleam@option:option(binary())}.

-type epub_error() :: {missing_file, binary()} |
    {invalid_xml, binary(), glexml:parse_error()} |
    {invalid_package, binary()}.

-file("src/glepub.gleam", 151).
?DOC(" Convert an `EpubError` into a human readable message.\n").
-spec error_to_string(epub_error()) -> binary().
error_to_string(Error) ->
    case Error of
        {missing_file, Path} ->
            <<<<"the container has no file at \""/utf8, Path/binary>>/binary,
                "\""/utf8>>;

        {invalid_xml, Path@1, Error@1} ->
            <<<<<<"\""/utf8, Path@1/binary>>/binary,
                    "\" is not well-formed XML: "/utf8>>/binary,
                (glexml:error_to_string(Error@1))/binary>>;

        {invalid_package, Description} ->
            Description
    end.

-file("src/glepub.gleam", 690).
?DOC(
    " Element children matched by local name, so `dc:title` and plain `title`\n"
    " both count regardless of the prefix a book chose.\n"
).
-spec children_local(glexml:element(), binary()) -> list(glexml:element()).
children_local(Element, Name) ->
    _pipe = glexml:child_elements(Element),
    gleam@list:filter(
        _pipe,
        fun(Child) -> glexml:local_name(erlang:element(2, Child)) =:= Name end
    ).

-file("src/glepub.gleam", 438).
-spec find_cover(glexml:element(), list(manifest_item())) -> gleam@option:option(manifest_item()).
find_cover(Metadata, Manifest) ->
    By_property = gleam@list:find(
        Manifest,
        fun(Item) ->
            gleam@list:contains(erlang:element(5, Item), <<"cover-image"/utf8>>)
        end
    ),
    case By_property of
        {ok, Item@1} ->
            {some, Item@1};

        {error, nil} ->
            By_meta = begin
                _pipe = children_local(Metadata, <<"meta"/utf8>>),
                _pipe@1 = gleam@list:find(
                    _pipe,
                    fun(Meta) ->
                        glexml:attribute(Meta, <<"name"/utf8>>) =:= {ok,
                            <<"cover"/utf8>>}
                    end
                ),
                _pipe@2 = gleam@result:'try'(
                    _pipe@1,
                    fun(_capture) ->
                        glexml:attribute(_capture, <<"content"/utf8>>)
                    end
                ),
                gleam@result:'try'(
                    _pipe@2,
                    fun(Id) ->
                        gleam@list:find(
                            Manifest,
                            fun(Item@2) -> erlang:element(2, Item@2) =:= Id end
                        )
                    end
                )
            end,
            case By_meta of
                {ok, Item@3} ->
                    {some, Item@3};

                {error, nil} ->
                    _pipe@3 = gleam@list:find(
                        Manifest,
                        fun(Item@4) ->
                            (erlang:element(2, Item@4) =:= <<"cover-image"/utf8>>)
                            andalso gleam_stdlib:string_starts_with(
                                erlang:element(4, Item@4),
                                <<"image/"/utf8>>
                            )
                        end
                    ),
                    gleam@option:from_result(_pipe@3)
            end
    end.

-file("src/glepub.gleam", 706).
?DOC(" An element's text with whitespace collapsed, for labels and metadata.\n").
-spec text_of(glexml:element()) -> binary().
text_of(Element) ->
    _pipe = glexml:text_content(Element),
    _pipe@1 = gleam@string:replace(_pipe, <<"\n"/utf8>>, <<" "/utf8>>),
    _pipe@2 = gleam@string:replace(_pipe@1, <<"\t"/utf8>>, <<" "/utf8>>),
    _pipe@3 = gleam@string:split(_pipe@2, <<" "/utf8>>),
    _pipe@4 = gleam@list:filter(_pipe@3, fun(Part) -> Part /= <<""/utf8>> end),
    gleam@string:join(_pipe@4, <<" "/utf8>>).

-file("src/glepub.gleam", 419).
-spec parse_rendition(glexml:element()) -> rendition().
parse_rendition(Metadata) ->
    Property = fun(Name) -> _pipe = children_local(Metadata, <<"meta"/utf8>>),
        _pipe@1 = gleam@list:find(
            _pipe,
            fun(Meta) ->
                glexml:attribute(Meta, <<"property"/utf8>>) =:= {ok,
                    <<"rendition:"/utf8, Name/binary>>}
            end
        ),
        _pipe@2 = gleam@result:map(
            _pipe@1,
            fun(Meta@1) -> {some, text_of(Meta@1)} end
        ),
        gleam@result:unwrap(_pipe@2, none) end,
    {rendition, case Property(<<"layout"/utf8>>) of
            {some, <<"pre-paginated"/utf8>>} ->
                pre_paginated;

            _ ->
                reflowable
        end, Property(<<"orientation"/utf8>>), Property(<<"spread"/utf8>>)}.

-file("src/glepub.gleam", 634).
-spec normalise(binary()) -> binary().
normalise(Path) ->
    _pipe = gleam@string:split(Path, <<"/"/utf8>>),
    _pipe@1 = gleam@list:fold(_pipe, [], fun(Acc, Part) -> case Part of
                <<""/utf8>> ->
                    Acc;

                <<"."/utf8>> ->
                    Acc;

                <<".."/utf8>> ->
                    case Acc of
                        [_ | Rest] ->
                            Rest;

                        [] ->
                            []
                    end;

                Part@1 ->
                    [Part@1 | Acc]
            end end),
    _pipe@2 = lists:reverse(_pipe@1),
    gleam@string:join(_pipe@2, <<"/"/utf8>>).

-file("src/glepub.gleam", 662).
-spec do_percent_decode(list(binary()), list(bitstring())) -> list(bitstring()).
do_percent_decode(Graphemes, Acc) ->
    case Graphemes of
        [] ->
            lists:reverse(Acc);

        [<<"%"/utf8>>, A, B | Rest] ->
            case gleam@int:base_parse(<<A/binary, B/binary>>, 16) of
                {ok, Code} ->
                    do_percent_decode(Rest, [<<Code>> | Acc]);

                {error, nil} ->
                    do_percent_decode([A, B | Rest], [<<"%"/utf8>> | Acc])
            end;

        [Grapheme | Rest@1] ->
            do_percent_decode(Rest@1, [gleam_stdlib:identity(Grapheme) | Acc])
    end.

-file("src/glepub.gleam", 651).
-spec percent_decode(binary()) -> binary().
percent_decode(Text) ->
    case gleam_stdlib:contains_string(Text, <<"%"/utf8>>) of
        false ->
            Text;

        true ->
            _pipe = do_percent_decode(gleam@string:to_graphemes(Text), []),
            _pipe@1 = gleam_stdlib:bit_array_concat(_pipe),
            _pipe@2 = gleam@bit_array:to_string(_pipe@1),
            gleam@result:unwrap(_pipe@2, Text)
    end.

-file("src/glepub.gleam", 601).
?DOC(
    " Resolve a reference found in the document at directory `base` to a\n"
    " container path: percent-decoded, `.`/`..` normalised, fragment kept.\n"
).
-spec resolve(binary(), binary()) -> binary().
resolve(Base, Reference) ->
    {Path@1, Fragment@1} = case gleam@string:split_once(Reference, <<"#"/utf8>>) of
        {ok, {Path, Fragment}} ->
            {Path, <<"#"/utf8, Fragment/binary>>};

        {error, nil} ->
            {Reference, <<""/utf8>>}
    end,
    Path@2 = percent_decode(Path@1),
    Resolved = case Path@2 of
        <<""/utf8>> ->
            <<""/utf8>>;

        <<"/"/utf8, Absolute/binary>> ->
            normalise(Absolute);

        _ ->
            case Base of
                <<""/utf8>> ->
                    normalise(Path@2);

                _ ->
                    normalise(
                        <<<<Base/binary, "/"/utf8>>/binary, Path@2/binary>>
                    )
            end
    end,
    <<Resolved/binary, Fragment@1/binary>>.

-file("src/glepub.gleam", 695).
-spec first_local(glexml:element(), binary()) -> {ok, glexml:element()} |
    {error, nil}.
first_local(Element, Name) ->
    _pipe = children_local(Element, Name),
    gleam@list:first(_pipe).

-file("src/glepub.gleam", 579).
?DOC(" EPUB 2 `<guide>` references presented as landmarks.\n").
-spec guide_landmarks(glexml:element(), binary()) -> list(toc_entry()).
guide_landmarks(Package, Base) ->
    case first_local(Package, <<"guide"/utf8>>) of
        {error, nil} ->
            [];

        {ok, Guide} ->
            _pipe = children_local(Guide, <<"reference"/utf8>>),
            gleam@list:filter_map(
                _pipe,
                fun(Reference) ->
                    gleam@result:'try'(
                        glexml:attribute(Reference, <<"href"/utf8>>),
                        fun(Href) ->
                            Label = case glexml:attribute(
                                Reference,
                                <<"title"/utf8>>
                            ) of
                                {ok, Title} ->
                                    Title;

                                {error, nil} ->
                                    _pipe@1 = glexml:attribute(
                                        Reference,
                                        <<"type"/utf8>>
                                    ),
                                    gleam@result:unwrap(_pipe@1, <<""/utf8>>)
                            end,
                            {ok,
                                {toc_entry,
                                    Label,
                                    {some, resolve(Base, Href)},
                                    []}}
                        end
                    )
                end
            )
    end.

-file("src/glepub.gleam", 627).
-spec dirname(binary()) -> binary().
dirname(Path) ->
    case begin
        _pipe = gleam@string:split(Path, <<"/"/utf8>>),
        lists:reverse(_pipe)
    end of
        [_ | Rest] ->
            _pipe@1 = Rest,
            _pipe@2 = lists:reverse(_pipe@1),
            gleam@string:join(_pipe@2, <<"/"/utf8>>);

        [] ->
            <<""/utf8>>
    end.

-file("src/glepub.gleam", 561).
-spec ncx_points(glexml:element(), binary()) -> list(toc_entry()).
ncx_points(Parent, Base) ->
    _pipe = children_local(Parent, <<"navPoint"/utf8>>),
    gleam@list:map(
        _pipe,
        fun(Point) ->
            Label = begin
                _pipe@1 = first_local(Point, <<"navLabel"/utf8>>),
                _pipe@2 = gleam@result:'try'(
                    _pipe@1,
                    fun(_capture) -> first_local(_capture, <<"text"/utf8>>) end
                ),
                _pipe@3 = gleam@result:map(_pipe@2, fun text_of/1),
                gleam@result:unwrap(_pipe@3, <<""/utf8>>)
            end,
            Href = begin
                _pipe@4 = first_local(Point, <<"content"/utf8>>),
                _pipe@5 = gleam@result:'try'(
                    _pipe@4,
                    fun(_capture@1) ->
                        glexml:attribute(_capture@1, <<"src"/utf8>>)
                    end
                ),
                _pipe@6 = gleam@result:map(
                    _pipe@5,
                    fun(Src) -> {some, resolve(Base, Src)} end
                ),
                gleam@result:unwrap(_pipe@6, none)
            end,
            {toc_entry, Label, Href, ncx_points(Point, Base)}
        end
    ).

-file("src/glepub.gleam", 554).
?DOC(" Parse an EPUB 2 NCX `<navMap>` into the same tree shape.\n").
-spec parse_ncx(glexml:element(), binary()) -> list(toc_entry()).
parse_ncx(Root, Base) ->
    case first_local(Root, <<"navMap"/utf8>>) of
        {ok, Nav_map} ->
            ncx_points(Nav_map, Base);

        {error, nil} ->
            []
    end.

-file("src/glepub.gleam", 680).
-spec read_xml(fun((binary()) -> {ok, bitstring()} | {error, nil}), binary()) -> {ok,
        glexml:document()} |
    {error, epub_error()}.
read_xml(Loader, Path) ->
    gleam@result:'try'(
        begin
            _pipe = Loader(Path),
            gleam@result:replace_error(_pipe, {missing_file, Path})
        end,
        fun(Bytes) -> _pipe@1 = glexml:parse_bytes(Bytes),
            gleam@result:map_error(
                _pipe@1,
                fun(_capture) -> {invalid_xml, Path, _capture} end
            ) end
    ).

-file("src/glepub.gleam", 533).
-spec nav_list(glexml:element(), binary()) -> list(toc_entry()).
nav_list(Ol, Base) ->
    _pipe = glexml:children_named(Ol, <<"li"/utf8>>),
    gleam@list:map(
        _pipe,
        fun(Li) ->
            Link = begin
                _pipe@1 = glexml:first_child_named(Li, <<"a"/utf8>>),
                gleam@result:lazy_or(
                    _pipe@1,
                    fun() -> glexml:first_child_named(Li, <<"span"/utf8>>) end
                )
            end,
            Label = begin
                _pipe@2 = Link,
                _pipe@3 = gleam@result:map(_pipe@2, fun text_of/1),
                gleam@result:unwrap(_pipe@3, <<""/utf8>>)
            end,
            Href@1 = begin
                _pipe@4 = Link,
                _pipe@5 = gleam@result:'try'(
                    _pipe@4,
                    fun(_capture) ->
                        glexml:attribute(_capture, <<"href"/utf8>>)
                    end
                ),
                _pipe@6 = gleam@result:map(
                    _pipe@5,
                    fun(Href) -> {some, resolve(Base, Href)} end
                ),
                gleam@result:unwrap(_pipe@6, none)
            end,
            Children = case glexml:first_child_named(Li, <<"ol"/utf8>>) of
                {ok, Ol@1} ->
                    nav_list(Ol@1, Base);

                {error, nil} ->
                    []
            end,
            {toc_entry, Label, Href@1, Children}
        end
    ).

-file("src/glepub.gleam", 715).
-spec selector_all(glexml:element(), binary()) -> list(glexml:element()).
selector_all(Element, Css) ->
    case glexml@selector:select(Element, Css) of
        {ok, Found} ->
            Found;

        {error, _} ->
            []
    end.

-file("src/glepub.gleam", 526).
?DOC(
    " Parse one `<nav epub:type=\"...\">` of an EPUB 3 navigation document into\n"
    " a tree.\n"
).
-spec parse_nav(glexml:element(), binary(), binary()) -> list(toc_entry()).
parse_nav(Root, Base, Kind) ->
    case selector_all(
        Root,
        <<<<"nav[epub|type~="/utf8, Kind/binary>>/binary, "] > ol"/utf8>>
    ) of
        [Ol | _] ->
            nav_list(Ol, Base);

        [] ->
            []
    end.

-file("src/glepub.gleam", 472).
-spec load_navigation(
    fun((binary()) -> {ok, bitstring()} | {error, nil}),
    binary(),
    list(manifest_item()),
    glexml:element(),
    glexml:element()
) -> {list(toc_entry()), list(toc_entry()), list(toc_entry())}.
load_navigation(Loader, Base, Manifest, Spine, Package) ->
    From_nav = begin
        _pipe = gleam@list:find(
            Manifest,
            fun(Item) ->
                gleam@list:contains(erlang:element(5, Item), <<"nav"/utf8>>)
            end
        ),
        gleam@result:'try'(
            _pipe,
            fun(Item@1) ->
                _pipe@1 = read_xml(Loader, erlang:element(3, Item@1)),
                _pipe@2 = gleam@result:map(
                    _pipe@1,
                    fun(Document) -> {erlang:element(3, Item@1), Document} end
                ),
                gleam@result:replace_error(_pipe@2, nil)
            end
        )
    end,
    case From_nav of
        {ok, {Path, Document@1}} ->
            Nav_base = dirname(Path),
            {parse_nav(erlang:element(7, Document@1), Nav_base, <<"toc"/utf8>>),
                parse_nav(
                    erlang:element(7, Document@1),
                    Nav_base,
                    <<"page-list"/utf8>>
                ),
                case parse_nav(
                    erlang:element(7, Document@1),
                    Nav_base,
                    <<"landmarks"/utf8>>
                ) of
                    [] ->
                        guide_landmarks(Package, Base);

                    Landmarks ->
                        Landmarks
                end};

        {error, nil} ->
            Ncx_item = begin
                _pipe@3 = glexml:attribute(Spine, <<"toc"/utf8>>),
                _pipe@4 = gleam@result:'try'(
                    _pipe@3,
                    fun(Id) ->
                        gleam@list:find(
                            Manifest,
                            fun(I) -> erlang:element(2, I) =:= Id end
                        )
                    end
                ),
                gleam@result:lazy_or(
                    _pipe@4,
                    fun() ->
                        gleam@list:find(
                            Manifest,
                            fun(Item@2) ->
                                erlang:element(4, Item@2) =:= <<"application/x-dtbncx+xml"/utf8>>
                            end
                        )
                    end
                )
            end,
            Toc = begin
                _pipe@5 = Ncx_item,
                _pipe@8 = gleam@result:'try'(
                    _pipe@5,
                    fun(Item@3) ->
                        _pipe@6 = read_xml(Loader, erlang:element(3, Item@3)),
                        _pipe@7 = gleam@result:map(
                            _pipe@6,
                            fun(Document@2) ->
                                parse_ncx(
                                    erlang:element(7, Document@2),
                                    dirname(erlang:element(3, Item@3))
                                )
                            end
                        ),
                        gleam@result:replace_error(_pipe@7, nil)
                    end
                ),
                gleam@result:unwrap(_pipe@8, [])
            end,
            {Toc, [], guide_landmarks(Package, Base)}
    end.

-file("src/glepub.gleam", 699).
-spec first_local_text(glexml:element(), binary()) -> gleam@option:option(binary()).
first_local_text(Element, Name) ->
    _pipe = first_local(Element, Name),
    _pipe@1 = gleam@result:map(_pipe, fun(Found) -> {some, text_of(Found)} end),
    gleam@result:unwrap(_pipe@1, none).

-file("src/glepub.gleam", 325).
?DOC(
    " `<meta refines=\"#id\" property=\"p\">value</meta>` associations, by the id\n"
    " they refine.\n"
).
-spec refinements_of(glexml:element()) -> gleam@dict:dict(binary(), list({binary(),
    binary()})).
refinements_of(Metadata) ->
    _pipe = children_local(Metadata, <<"meta"/utf8>>),
    _pipe@1 = gleam@list:filter_map(
        _pipe,
        fun(Meta) ->
            case {glexml:attribute(Meta, <<"refines"/utf8>>),
                glexml:attribute(Meta, <<"property"/utf8>>)} of
                {{ok, <<"#"/utf8, Id/binary>>}, {ok, Property}} ->
                    {ok, {Id, Property, text_of(Meta)}};

                {_, _} ->
                    {error, nil}
            end
        end
    ),
    gleam@list:fold(
        _pipe@1,
        maps:new(),
        fun(Acc, Entry) ->
            {Id@1, Property@1, Value} = Entry,
            gleam@dict:upsert(
                Acc,
                Id@1,
                fun(Existing) ->
                    [{Property@1, Value} | gleam@option:unwrap(Existing, [])]
                end
            )
        end
    ).

-file("src/glepub.gleam", 341).
-spec parse_metadata(glexml:element(), glexml:element()) -> metadata().
parse_metadata(Package, Metadata) ->
    Refinements = refinements_of(Metadata),
    Refinement = fun(Element, Property) ->
        case glexml:attribute(Element, <<"id"/utf8>>) of
            {ok, Id} ->
                _pipe = gleam_stdlib:map_get(Refinements, Id),
                _pipe@1 = gleam@result:unwrap(_pipe, []),
                _pipe@2 = gleam@list:find(
                    _pipe@1,
                    fun(Pair) -> erlang:element(1, Pair) =:= Property end
                ),
                _pipe@3 = gleam@result:map(
                    _pipe@2,
                    fun(Pair@1) -> {some, erlang:element(2, Pair@1)} end
                ),
                gleam@result:unwrap(_pipe@3, none);

            {error, nil} ->
                none
        end
    end,
    Identifiers = children_local(Metadata, <<"identifier"/utf8>>),
    Identifier = case glexml:attribute(Package, <<"unique-identifier"/utf8>>) of
        {ok, Wanted} ->
            _pipe@4 = Identifiers,
            _pipe@5 = gleam@list:find(
                _pipe@4,
                fun(Element@1) ->
                    glexml:attribute(Element@1, <<"id"/utf8>>) =:= {ok, Wanted}
                end
            ),
            gleam@result:map(_pipe@5, fun text_of/1);

        {error, nil} ->
            {error, nil}
    end,
    Identifier@2 = case Identifier of
        {ok, Identifier@1} ->
            Identifier@1;

        {error, nil} ->
            _pipe@6 = Identifiers,
            _pipe@7 = gleam@list:first(_pipe@6),
            _pipe@8 = gleam@result:map(_pipe@7, fun text_of/1),
            gleam@result:unwrap(_pipe@8, <<""/utf8>>)
    end,
    Titles = children_local(Metadata, <<"title"/utf8>>),
    Title = begin
        _pipe@9 = Titles,
        _pipe@10 = gleam@list:find(
            _pipe@9,
            fun(Element@2) ->
                Refinement(Element@2, <<"title-type"/utf8>>) =:= {some,
                    <<"main"/utf8>>}
            end
        ),
        _pipe@11 = gleam@result:lazy_or(
            _pipe@10,
            fun() -> gleam@list:first(Titles) end
        ),
        _pipe@12 = gleam@result:map(_pipe@11, fun text_of/1),
        gleam@result:unwrap(_pipe@12, <<""/utf8>>)
    end,
    Contributor = fun(Element@3) ->
        {contributor,
            text_of(Element@3),
            begin
                _pipe@13 = Refinement(Element@3, <<"role"/utf8>>),
                gleam@option:lazy_or(
                    _pipe@13,
                    fun() ->
                        _pipe@14 = glexml:attribute(
                            Element@3,
                            <<"opf:role"/utf8>>
                        ),
                        gleam@option:from_result(_pipe@14)
                    end
                )
            end,
            begin
                _pipe@15 = Refinement(Element@3, <<"file-as"/utf8>>),
                gleam@option:lazy_or(
                    _pipe@15,
                    fun() ->
                        _pipe@16 = glexml:attribute(
                            Element@3,
                            <<"opf:file-as"/utf8>>
                        ),
                        gleam@option:from_result(_pipe@16)
                    end
                )
            end}
    end,
    Property_meta = fun(Property@1) ->
        _pipe@17 = children_local(Metadata, <<"meta"/utf8>>),
        _pipe@18 = gleam@list:find(
            _pipe@17,
            fun(Meta) ->
                glexml:attribute(Meta, <<"property"/utf8>>) =:= {ok, Property@1}
            end
        ),
        _pipe@19 = gleam@result:map(
            _pipe@18,
            fun(Meta@1) -> {some, text_of(Meta@1)} end
        ),
        gleam@result:unwrap(_pipe@19, none)
    end,
    {metadata,
        Identifier@2,
        Title,
        begin
            _pipe@20 = first_local_text(Metadata, <<"language"/utf8>>),
            gleam@option:unwrap(_pipe@20, <<""/utf8>>)
        end,
        begin
            _pipe@21 = children_local(Metadata, <<"creator"/utf8>>),
            gleam@list:map(_pipe@21, Contributor)
        end,
        begin
            _pipe@22 = children_local(Metadata, <<"contributor"/utf8>>),
            gleam@list:map(_pipe@22, Contributor)
        end,
        first_local_text(Metadata, <<"publisher"/utf8>>),
        first_local_text(Metadata, <<"description"/utf8>>),
        first_local_text(Metadata, <<"date"/utf8>>),
        Property_meta(<<"dcterms:modified"/utf8>>),
        begin
            _pipe@23 = children_local(Metadata, <<"subject"/utf8>>),
            gleam@list:map(_pipe@23, fun text_of/1)
        end,
        first_local_text(Metadata, <<"rights"/utf8>>)}.

-file("src/glepub.gleam", 272).
-spec properties_of(glexml:element()) -> list(binary()).
properties_of(Element) ->
    _pipe = glexml:attribute(Element, <<"properties"/utf8>>),
    _pipe@1 = gleam@result:unwrap(_pipe, <<""/utf8>>),
    _pipe@2 = gleam@string:split(_pipe@1, <<" "/utf8>>),
    gleam@list:filter(_pipe@2, fun(Property) -> Property /= <<""/utf8>> end).

-file("src/glepub.gleam", 620).
?DOC(" The container path without any `#fragment`.\n").
-spec strip_fragment(binary()) -> binary().
strip_fragment(Href) ->
    case gleam@string:split_once(Href, <<"#"/utf8>>) of
        {ok, {Path, _}} ->
            Path;

        {error, nil} ->
            Href
    end.

-file("src/glepub.gleam", 188).
-spec build_book(
    fun((binary()) -> {ok, bitstring()} | {error, nil}),
    binary(),
    glexml:element()
) -> {ok, book()} | {error, epub_error()}.
build_book(Loader, Package_path, Package) ->
    Base = dirname(Package_path),
    Version = begin
        _pipe = glexml:attribute(Package, <<"version"/utf8>>),
        gleam@result:unwrap(_pipe, <<"3.0"/utf8>>)
    end,
    gleam@result:'try'(
        begin
            _pipe@1 = first_local(Package, <<"metadata"/utf8>>),
            gleam@result:replace_error(
                _pipe@1,
                {invalid_package,
                    <<"the package document has no <metadata>"/utf8>>}
            )
        end,
        fun(Metadata_element) ->
            gleam@result:'try'(
                begin
                    _pipe@2 = first_local(Package, <<"manifest"/utf8>>),
                    gleam@result:replace_error(
                        _pipe@2,
                        {invalid_package,
                            <<"the package document has no <manifest>"/utf8>>}
                    )
                end,
                fun(Manifest_element) ->
                    gleam@result:'try'(
                        begin
                            _pipe@3 = first_local(Package, <<"spine"/utf8>>),
                            gleam@result:replace_error(
                                _pipe@3,
                                {invalid_package,
                                    <<"the package document has no <spine>"/utf8>>}
                            )
                        end,
                        fun(Spine_element) ->
                            Manifest = begin
                                _pipe@4 = children_local(
                                    Manifest_element,
                                    <<"item"/utf8>>
                                ),
                                gleam@list:filter_map(
                                    _pipe@4,
                                    fun(Item) ->
                                        case {glexml:attribute(
                                                Item,
                                                <<"id"/utf8>>
                                            ),
                                            glexml:attribute(
                                                Item,
                                                <<"href"/utf8>>
                                            )} of
                                            {{ok, Id}, {ok, Href}} ->
                                                {ok,
                                                    {manifest_item,
                                                        Id,
                                                        begin
                                                            _pipe@5 = resolve(
                                                                Base,
                                                                Href
                                                            ),
                                                            strip_fragment(
                                                                _pipe@5
                                                            )
                                                        end,
                                                        begin
                                                            _pipe@6 = glexml:attribute(
                                                                Item,
                                                                <<"media-type"/utf8>>
                                                            ),
                                                            gleam@result:unwrap(
                                                                _pipe@6,
                                                                <<""/utf8>>
                                                            )
                                                        end,
                                                        properties_of(Item)}};

                                            {_, _} ->
                                                {error, nil}
                                        end
                                    end
                                )
                            end,
                            By_id = begin
                                _pipe@7 = Manifest,
                                _pipe@8 = gleam@list:map(
                                    _pipe@7,
                                    fun(Item@1) ->
                                        {erlang:element(2, Item@1), Item@1}
                                    end
                                ),
                                maps:from_list(_pipe@8)
                            end,
                            Spine = begin
                                _pipe@9 = children_local(
                                    Spine_element,
                                    <<"itemref"/utf8>>
                                ),
                                gleam@list:filter_map(
                                    _pipe@9,
                                    fun(Itemref) ->
                                        gleam@result:'try'(
                                            glexml:attribute(
                                                Itemref,
                                                <<"idref"/utf8>>
                                            ),
                                            fun(Idref) ->
                                                gleam@result:'try'(
                                                    gleam_stdlib:map_get(
                                                        By_id,
                                                        Idref
                                                    ),
                                                    fun(Item@2) ->
                                                        {ok,
                                                            {spine_item,
                                                                Item@2,
                                                                glexml:attribute(
                                                                    Itemref,
                                                                    <<"linear"/utf8>>
                                                                )
                                                                /= {ok,
                                                                    <<"no"/utf8>>},
                                                                properties_of(
                                                                    Itemref
                                                                )}}
                                                    end
                                                )
                                            end
                                        )
                                    end
                                )
                            end,
                            Metadata = parse_metadata(Package, Metadata_element),
                            {Toc, Page_list, Landmarks} = load_navigation(
                                Loader,
                                Base,
                                Manifest,
                                Spine_element,
                                Package
                            ),
                            {ok,
                                {book,
                                    Version,
                                    Metadata,
                                    Manifest,
                                    Spine,
                                    Toc,
                                    Page_list,
                                    Landmarks,
                                    case glexml:attribute(
                                        Spine_element,
                                        <<"page-progression-direction"/utf8>>
                                    ) of
                                        {ok, <<"rtl"/utf8>>} ->
                                            right_to_left;

                                        {ok, <<"ltr"/utf8>>} ->
                                            left_to_right;

                                        _ ->
                                            default_direction
                                    end,
                                    parse_rendition(Metadata_element),
                                    find_cover(Metadata_element, Manifest),
                                    Loader}}
                        end
                    )
                end
            )
        end
    ).

-file("src/glepub.gleam", 167).
?DOC(
    " Open a publication: read `META-INF/container.xml`, find the package\n"
    " document, and parse the package, navigation, and cover information.\n"
).
-spec open(fun((binary()) -> {ok, bitstring()} | {error, nil})) -> {ok, book()} |
    {error, epub_error()}.
open(Loader) ->
    gleam@result:'try'(
        read_xml(Loader, <<"META-INF/container.xml"/utf8>>),
        fun(Container) ->
            gleam@result:'try'(
                begin
                    _pipe = selector_all(
                        erlang:element(7, Container),
                        <<"rootfiles > rootfile"/utf8>>
                    ),
                    _pipe@1 = gleam@list:filter_map(
                        _pipe,
                        fun(Rootfile) ->
                            case glexml:attribute(
                                Rootfile,
                                <<"media-type"/utf8>>
                            ) of
                                {ok, <<"application/oebps-package+xml"/utf8>>} ->
                                    glexml:attribute(
                                        Rootfile,
                                        <<"full-path"/utf8>>
                                    );

                                _ ->
                                    {error, nil}
                            end
                        end
                    ),
                    _pipe@2 = gleam@list:first(_pipe@1),
                    gleam@result:replace_error(
                        _pipe@2,
                        {invalid_package,
                            <<"container.xml names no package document"/utf8>>}
                    )
                end,
                fun(Package_path) ->
                    Package_path@1 = normalise(percent_decode(Package_path)),
                    gleam@result:'try'(
                        read_xml(Loader, Package_path@1),
                        fun(Package) ->
                            build_book(
                                Loader,
                                Package_path@1,
                                erlang:element(7, Package)
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/glepub.gleam", 282).
?DOC(" Read a manifest item's bytes from the container.\n").
-spec resource(book(), manifest_item()) -> {ok, bitstring()} |
    {error, epub_error()}.
resource(Book, Item) ->
    _pipe = (erlang:element(12, Book))(erlang:element(3, Item)),
    gleam@result:replace_error(_pipe, {missing_file, erlang:element(3, Item)}).

-file("src/glepub.gleam", 296).
?DOC(
    " Like `document`, with extra DTD declarations available — typically the\n"
    " XHTML entity set for EPUB 2 content documents.\n"
).
-spec document_with_dtd(book(), manifest_item(), glexml:dtd()) -> {ok,
        glexml:document()} |
    {error, epub_error()}.
document_with_dtd(Book, Item, Dtd) ->
    gleam@result:'try'(
        resource(Book, Item),
        fun(Bytes) -> _pipe = glexml:parse_bytes_with_dtd(Bytes, Dtd),
            gleam@result:map_error(
                _pipe,
                fun(_capture) ->
                    {invalid_xml, erlang:element(3, Item), _capture}
                end
            ) end
    ).

-file("src/glepub.gleam", 290).
?DOC(
    " Read and parse a manifest item as XML — a content document, for\n"
    " instance. EPUB 2 XHTML may use the named entities of the XHTML DTD;\n"
    " supply them with `document_with_dtd` if you need them.\n"
).
-spec document(book(), manifest_item()) -> {ok, glexml:document()} |
    {error, epub_error()}.
document(Book, Item) ->
    document_with_dtd(Book, Item, glexml:empty_dtd()).

-file("src/glepub.gleam", 308).
?DOC(
    " Find the manifest item a container path (as produced in `TocEntry.href`,\n"
    " fragment ignored) refers to.\n"
).
-spec item_for_href(book(), binary()) -> {ok, manifest_item()} | {error, nil}.
item_for_href(Book, Href) ->
    Path = strip_fragment(Href),
    gleam@list:find(
        erlang:element(4, Book),
        fun(Item) -> erlang:element(3, Item) =:= Path end
    ).

-file("src/glepub.gleam", 314).
?DOC(" Whether a reference in a content document points outside the container.\n").
-spec is_external(binary()) -> boolean().
is_external(Reference) ->
    case gleam@string:split_once(Reference, <<":"/utf8>>) of
        {ok, {Scheme, _}} ->
            not gleam_stdlib:contains_string(Scheme, <<"/"/utf8>>);

        {error, nil} ->
            false
    end.
