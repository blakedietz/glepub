-module(glepub_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "test/glepub_test.gleam").
-export([main/0, open_epub3_test/0, manifest_and_spine_test/0, rendition_test/0, toc_test/0, resources_test/0, epub2_test/0, resolve_test/0, missing_container_test/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("test/glepub_test.gleam", 9).
-spec main() -> nil.
main() ->
    gleeunit:main().

-file("test/glepub_test.gleam", 14).
?DOC(" A loader backed by an in-memory dictionary, as a test container.\n").
-spec loader_of(list({binary(), binary()})) -> fun((binary()) -> {ok,
        bitstring()} |
    {error, nil}).
loader_of(Files) ->
    Files@1 = begin
        _pipe = Files,
        _pipe@1 = gleam@list:map(
            _pipe,
            fun(File) ->
                {erlang:element(1, File),
                    gleam_stdlib:identity(erlang:element(2, File))}
            end
        ),
        maps:from_list(_pipe@1)
    end,
    fun(Path) -> gleam_stdlib:map_get(Files@1, Path) end.

-file("test/glepub_test.gleam", 29).
-spec epub3() -> fun((binary()) -> {ok, bitstring()} | {error, nil}).
epub3() ->
    loader_of(
        [{<<"META-INF/container.xml"/utf8>>,
                <<"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">
  <rootfiles>
    <rootfile full-path=\"OEBPS/content.opf\" media-type=\"application/oebps-package+xml\"/>
  </rootfiles>
</container>"/utf8>>},
            {<<"OEBPS/content.opf"/utf8>>,
                <<"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<package xmlns=\"http://www.idpf.org/2007/opf\" version=\"3.0\" unique-identifier=\"pub-id\">
  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">
    <dc:identifier id=\"pub-id\">urn:uuid:1234</dc:identifier>
    <dc:identifier>isbn:999</dc:identifier>
    <dc:title id=\"t2\">A Subtitle</dc:title>
    <dc:title id=\"t1\">Moby-Dick</dc:title>
    <meta refines=\"#t1\" property=\"title-type\">main</meta>
    <meta refines=\"#t2\" property=\"title-type\">subtitle</meta>
    <dc:language>en-US</dc:language>
    <dc:creator id=\"c1\">Herman Melville</dc:creator>
    <meta refines=\"#c1\" property=\"role\" scheme=\"marc:relators\">aut</meta>
    <meta refines=\"#c1\" property=\"file-as\">MELVILLE, HERMAN</meta>
    <dc:publisher>Harper &amp; Brothers</dc:publisher>
    <dc:date>1851-11-14</dc:date>
    <dc:subject>Whaling</dc:subject>
    <dc:subject>Obsession</dc:subject>
    <meta property=\"dcterms:modified\">2026-07-07T00:00:00Z</meta>
    <meta property=\"rendition:layout\">pre-paginated</meta>
    <meta property=\"rendition:spread\">landscape</meta>
  </metadata>
  <manifest>
    <item id=\"nav\" href=\"nav.xhtml\" media-type=\"application/xhtml+xml\" properties=\"nav\"/>
    <item id=\"cover-img\" href=\"images/cover%20art.jpg\" media-type=\"image/jpeg\" properties=\"cover-image\"/>
    <item id=\"c1\" href=\"text/chapter1.xhtml\" media-type=\"application/xhtml+xml\"/>
    <item id=\"c2\" href=\"text/chapter2.xhtml\" media-type=\"application/xhtml+xml\" properties=\"scripted\"/>
  </manifest>
  <spine page-progression-direction=\"rtl\">
    <itemref idref=\"c1\"/>
    <itemref idref=\"c2\" linear=\"no\"/>
  </spine>
</package>"/utf8>>},
            {<<"OEBPS/nav.xhtml"/utf8>>,
                <<"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\">
<head><title>Nav</title></head>
<body>
<nav epub:type=\"toc\">
  <ol>
    <li><a href=\"text/chapter1.xhtml\">Loomings</a>
      <ol>
        <li><a href=\"text/chapter1.xhtml#part2\">Call me Ishmael</a></li>
      </ol>
    </li>
    <li><span>Unlinked heading</span></li>
  </ol>
</nav>
<nav epub:type=\"landmarks\">
  <ol>
    <li><a epub:type=\"bodymatter\" href=\"text/chapter1.xhtml\">Start</a></li>
  </ol>
</nav>
</body>
</html>"/utf8>>},
            {<<"OEBPS/text/chapter1.xhtml"/utf8>>,
                <<"<?xml version=\"1.0\"?>
<html xmlns=\"http://www.w3.org/1999/xhtml\"><body><p>Call me Ishmael.</p></body></html>"/utf8>>}]
    ).

-file("test/glepub_test.gleam", 99).
-spec open_epub3_test() -> nil.
open_epub3_test() ->
    Book@1 = case glepub:open(epub3()) of
        {ok, Book} -> Book;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"open_epub3_test"/utf8>>,
                        line => 100,
                        value => _assert_fail,
                        start => 3458,
                        'end' => 3500,
                        pattern_start => 3469,
                        pattern_end => 3477})
    end,
    _assert_subject = erlang:element(2, Book@1),
    _assert_subject@1 = <<"3.0"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"open_epub3_test"/utf8>>,
                line => 101,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 3510,
                    'end' => 3522
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 3526,
                    'end' => 3531
                    },
                start => 3503,
                'end' => 3531,
                expression_start => 3510})
    end,
    _assert_subject@2 = erlang:element(2, erlang:element(3, Book@1)),
    _assert_subject@3 = <<"urn:uuid:1234"/utf8>>,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"open_epub3_test"/utf8>>,
                line => 102,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 3541,
                    'end' => 3565
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 3569,
                    'end' => 3584
                    },
                start => 3534,
                'end' => 3584,
                expression_start => 3541})
    end,
    _assert_subject@4 = erlang:element(3, erlang:element(3, Book@1)),
    _assert_subject@5 = <<"Moby-Dick"/utf8>>,
    case _assert_subject@4 =:= _assert_subject@5 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"open_epub3_test"/utf8>>,
                line => 103,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 3594,
                    'end' => 3613
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 3617,
                    'end' => 3628
                    },
                start => 3587,
                'end' => 3628,
                expression_start => 3594})
    end,
    _assert_subject@6 = erlang:element(4, erlang:element(3, Book@1)),
    _assert_subject@7 = <<"en-US"/utf8>>,
    case _assert_subject@6 =:= _assert_subject@7 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"open_epub3_test"/utf8>>,
                line => 104,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@6,
                    start => 3638,
                    'end' => 3660
                    },
                right => #{kind => literal,
                    value => _assert_subject@7,
                    start => 3664,
                    'end' => 3671
                    },
                start => 3631,
                'end' => 3671,
                expression_start => 3638})
    end,
    _assert_subject@8 = erlang:element(7, erlang:element(3, Book@1)),
    _assert_subject@9 = {some, <<"Harper & Brothers"/utf8>>},
    case _assert_subject@8 =:= _assert_subject@9 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"open_epub3_test"/utf8>>,
                line => 105,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@8,
                    start => 3681,
                    'end' => 3704
                    },
                right => #{kind => literal,
                    value => _assert_subject@9,
                    start => 3708,
                    'end' => 3733
                    },
                start => 3674,
                'end' => 3733,
                expression_start => 3681})
    end,
    _assert_subject@10 = erlang:element(11, erlang:element(3, Book@1)),
    _assert_subject@11 = [<<"Whaling"/utf8>>, <<"Obsession"/utf8>>],
    case _assert_subject@10 =:= _assert_subject@11 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"open_epub3_test"/utf8>>,
                line => 106,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@10,
                    start => 3743,
                    'end' => 3765
                    },
                right => #{kind => literal,
                    value => _assert_subject@11,
                    start => 3769,
                    'end' => 3793
                    },
                start => 3736,
                'end' => 3793,
                expression_start => 3743})
    end,
    _assert_subject@12 = erlang:element(10, erlang:element(3, Book@1)),
    _assert_subject@13 = {some, <<"2026-07-07T00:00:00Z"/utf8>>},
    case _assert_subject@12 =:= _assert_subject@13 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"open_epub3_test"/utf8>>,
                line => 107,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@12,
                    start => 3803,
                    'end' => 3825
                    },
                right => #{kind => literal,
                    value => _assert_subject@13,
                    start => 3829,
                    'end' => 3857
                    },
                start => 3796,
                'end' => 3857,
                expression_start => 3803})
    end,
    _assert_subject@14 = erlang:element(5, erlang:element(3, Book@1)),
    _assert_subject@15 = [{contributor,
            <<"Herman Melville"/utf8>>,
            {some, <<"aut"/utf8>>},
            {some, <<"MELVILLE, HERMAN"/utf8>>}}],
    case _assert_subject@14 =:= _assert_subject@15 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"open_epub3_test"/utf8>>,
                line => 108,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@14,
                    start => 3867,
                    'end' => 3889
                    },
                right => #{kind => literal,
                    value => _assert_subject@15,
                    start => 3897,
                    'end' => 3968
                    },
                start => 3860,
                'end' => 3968,
                expression_start => 3867})
    end.

-file("test/glepub_test.gleam", 112).
-spec manifest_and_spine_test() -> nil.
manifest_and_spine_test() ->
    Book@1 = case glepub:open(epub3()) of
        {ok, Book} -> Book;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"manifest_and_spine_test"/utf8>>,
                        line => 113,
                        value => _assert_fail,
                        start => 4009,
                        'end' => 4051,
                        pattern_start => 4020,
                        pattern_end => 4028})
    end,
    Cover@1 = case gleam@list:find(
        erlang:element(4, Book@1),
        fun(I) -> erlang:element(2, I) =:= <<"cover-img"/utf8>> end
    ) of
        {ok, Cover} -> Cover;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"manifest_and_spine_test"/utf8>>,
                        line => 116,
                        value => _assert_fail@1,
                        start => 4130,
                        'end' => 4208,
                        pattern_start => 4141,
                        pattern_end => 4150})
    end,
    _assert_subject = erlang:element(3, Cover@1),
    _assert_subject@1 = <<"OEBPS/images/cover art.jpg"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"manifest_and_spine_test"/utf8>>,
                line => 117,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 4218,
                    'end' => 4228
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 4232,
                    'end' => 4260
                    },
                start => 4211,
                'end' => 4260,
                expression_start => 4218})
    end,
    _assert_subject@2 = erlang:element(11, Book@1),
    _assert_subject@3 = {some, Cover@1},
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"manifest_and_spine_test"/utf8>>,
                line => 118,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 4270,
                    'end' => 4280
                    },
                right => #{kind => expression,
                    value => _assert_subject@3,
                    start => 4284,
                    'end' => 4295
                    },
                start => 4263,
                'end' => 4295,
                expression_start => 4270})
    end,
    _assert_subject@4 = gleam@list:map(
        erlang:element(5, Book@1),
        fun(S) -> erlang:element(3, erlang:element(2, S)) end
    ),
    _assert_subject@5 = [<<"OEBPS/text/chapter1.xhtml"/utf8>>,
        <<"OEBPS/text/chapter2.xhtml"/utf8>>],
    case _assert_subject@4 =:= _assert_subject@5 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"manifest_and_spine_test"/utf8>>,
                line => 120,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 4306,
                    'end' => 4349
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 4357,
                    'end' => 4415
                    },
                start => 4299,
                'end' => 4415,
                expression_start => 4306})
    end,
    _assert_subject@6 = gleam@list:map(
        erlang:element(5, Book@1),
        fun(S@1) -> erlang:element(3, S@1) end
    ),
    _assert_subject@7 = [true, false],
    case _assert_subject@6 =:= _assert_subject@7 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"manifest_and_spine_test"/utf8>>,
                line => 122,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@6,
                    start => 4425,
                    'end' => 4465
                    },
                right => #{kind => literal,
                    value => _assert_subject@7,
                    start => 4469,
                    'end' => 4482
                    },
                start => 4418,
                'end' => 4482,
                expression_start => 4425})
    end,
    Second@1 = case erlang:element(5, Book@1) of
        [_, Second] -> Second;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"manifest_and_spine_test"/utf8>>,
                        line => 123,
                        value => _assert_fail@2,
                        start => 4485,
                        'end' => 4520,
                        pattern_start => 4496,
                        pattern_end => 4507})
    end,
    _assert_subject@8 = erlang:element(5, erlang:element(2, Second@1)),
    _assert_subject@9 = [<<"scripted"/utf8>>],
    case _assert_subject@8 =:= _assert_subject@9 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"manifest_and_spine_test"/utf8>>,
                line => 124,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@8,
                    start => 4530,
                    'end' => 4552
                    },
                right => #{kind => literal,
                    value => _assert_subject@9,
                    start => 4556,
                    'end' => 4568
                    },
                start => 4523,
                'end' => 4568,
                expression_start => 4530})
    end,
    _assert_subject@10 = erlang:element(9, Book@1),
    _assert_subject@11 = right_to_left,
    case _assert_subject@10 =:= _assert_subject@11 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"manifest_and_spine_test"/utf8>>,
                line => 125,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@10,
                    start => 4578,
                    'end' => 4592
                    },
                right => #{kind => expression,
                    value => _assert_subject@11,
                    start => 4596,
                    'end' => 4614
                    },
                start => 4571,
                'end' => 4614,
                expression_start => 4578})
    end.

-file("test/glepub_test.gleam", 128).
-spec rendition_test() -> nil.
rendition_test() ->
    Book@1 = case glepub:open(epub3()) of
        {ok, Book} -> Book;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"rendition_test"/utf8>>,
                        line => 129,
                        value => _assert_fail,
                        start => 4646,
                        'end' => 4688,
                        pattern_start => 4657,
                        pattern_end => 4665})
    end,
    _assert_subject = erlang:element(2, erlang:element(10, Book@1)),
    _assert_subject@1 = pre_paginated,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"rendition_test"/utf8>>,
                line => 130,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 4698,
                    'end' => 4719
                    },
                right => #{kind => expression,
                    value => _assert_subject@1,
                    start => 4723,
                    'end' => 4742
                    },
                start => 4691,
                'end' => 4742,
                expression_start => 4698})
    end,
    _assert_subject@2 = erlang:element(4, erlang:element(10, Book@1)),
    _assert_subject@3 = {some, <<"landscape"/utf8>>},
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"rendition_test"/utf8>>,
                line => 131,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 4752,
                    'end' => 4773
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 4777,
                    'end' => 4794
                    },
                start => 4745,
                'end' => 4794,
                expression_start => 4752})
    end,
    _assert_subject@4 = erlang:element(3, erlang:element(10, Book@1)),
    case _assert_subject@4 =:= none of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"rendition_test"/utf8>>,
                line => 132,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 4804,
                    'end' => 4830
                    },
                right => #{kind => literal,
                    value => none,
                    start => 4834,
                    'end' => 4838
                    },
                start => 4797,
                'end' => 4838,
                expression_start => 4804})
    end.

-file("test/glepub_test.gleam", 135).
-spec toc_test() -> nil.
toc_test() ->
    Book@1 = case glepub:open(epub3()) of
        {ok, Book} -> Book;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"toc_test"/utf8>>,
                        line => 136,
                        value => _assert_fail,
                        start => 4864,
                        'end' => 4906,
                        pattern_start => 4875,
                        pattern_end => 4883})
    end,
    _assert_subject = erlang:element(6, Book@1),
    _assert_subject@1 = [{toc_entry,
            <<"Loomings"/utf8>>,
            {some, <<"OEBPS/text/chapter1.xhtml"/utf8>>},
            [{toc_entry,
                    <<"Call me Ishmael"/utf8>>,
                    {some, <<"OEBPS/text/chapter1.xhtml#part2"/utf8>>},
                    []}]},
        {toc_entry, <<"Unlinked heading"/utf8>>, none, []}],
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"toc_test"/utf8>>,
                line => 138,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 4986,
                    'end' => 4994
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 5002,
                    'end' => 5211
                    },
                start => 4979,
                'end' => 5211,
                expression_start => 4986})
    end,
    _assert_subject@2 = erlang:element(8, Book@1),
    _assert_subject@3 = [{toc_entry,
            <<"Start"/utf8>>,
            {some, <<"OEBPS/text/chapter1.xhtml"/utf8>>},
            []}],
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"toc_test"/utf8>>,
                line => 145,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 5221,
                    'end' => 5235
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 5243,
                    'end' => 5301
                    },
                start => 5214,
                'end' => 5301,
                expression_start => 5221})
    end.

-file("test/glepub_test.gleam", 149).
-spec resources_test() -> {ok, glexml:document()} | {error, glepub:epub_error()}.
resources_test() ->
    Book@1 = case glepub:open(epub3()) of
        {ok, Book} -> Book;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"resources_test"/utf8>>,
                        line => 150,
                        value => _assert_fail,
                        start => 5333,
                        'end' => 5375,
                        pattern_start => 5344,
                        pattern_end => 5352})
    end,
    First@1 = case erlang:element(5, Book@1) of
        [First | _] -> First;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"resources_test"/utf8>>,
                        line => 151,
                        value => _assert_fail@1,
                        start => 5378,
                        'end' => 5413,
                        pattern_start => 5389,
                        pattern_end => 5400})
    end,
    Chapter@1 = case glepub:document(Book@1, erlang:element(2, First@1)) of
        {ok, Chapter} -> Chapter;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"resources_test"/utf8>>,
                        line => 152,
                        value => _assert_fail@2,
                        start => 5416,
                        'end' => 5474,
                        pattern_start => 5427,
                        pattern_end => 5438})
    end,
    _assert_subject = glexml:text_content(erlang:element(7, Chapter@1)),
    _assert_subject@1 = <<"Call me Ishmael."/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resources_test"/utf8>>,
                line => 153,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 5484,
                    'end' => 5517
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 5521,
                    'end' => 5539
                    },
                start => 5477,
                'end' => 5539,
                expression_start => 5484})
    end,
    Item@1 = case glepub:item_for_href(
        Book@1,
        <<"OEBPS/text/chapter1.xhtml#part2"/utf8>>
    ) of
        {ok, Item} -> Item;
        _assert_fail@3 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"resources_test"/utf8>>,
                        line => 155,
                        value => _assert_fail@3,
                        start => 5543,
                        'end' => 5630,
                        pattern_start => 5554,
                        pattern_end => 5562})
    end,
    _assert_subject@2 = erlang:element(2, Item@1),
    _assert_subject@3 = <<"c1"/utf8>>,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resources_test"/utf8>>,
                line => 157,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 5640,
                    'end' => 5647
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 5651,
                    'end' => 5655
                    },
                start => 5633,
                'end' => 5655,
                expression_start => 5640})
    end,
    Missing@1 = case erlang:element(5, Book@1) of
        [_, Missing] -> Missing;
        _assert_fail@4 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"resources_test"/utf8>>,
                        line => 159,
                        value => _assert_fail@4,
                        start => 5659,
                        'end' => 5695,
                        pattern_start => 5670,
                        pattern_end => 5682})
    end,
    _assert_subject@4 = glepub:document(Book@1, erlang:element(2, Missing@1)),
    case _assert_subject@4 of
        {error, {missing_file, <<"OEBPS/text/chapter2.xhtml"/utf8>>}} -> _assert_subject@4;
        _assert_fail@5 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"resources_test"/utf8>>,
                        line => 160,
                        value => _assert_fail@5,
                        start => 5698,
                        'end' => 5805,
                        pattern_start => 5709,
                        pattern_end => 5763})
    end.

-file("test/glepub_test.gleam", 164).
-spec epub2_test() -> nil.
epub2_test() ->
    Files = [{<<"META-INF/container.xml"/utf8>>,
            <<"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">
  <rootfiles>
    <rootfile full-path=\"OEBPS/content.opf\" media-type=\"application/oebps-package+xml\"/>
  </rootfiles>
</container>"/utf8>>},
        {<<"OEBPS/content.opf"/utf8>>,
            <<"<?xml version=\"1.0\"?>
<package xmlns=\"http://www.idpf.org/2007/opf\" version=\"2.0\" unique-identifier=\"bookid\">
  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:opf=\"http://www.idpf.org/2007/opf\">
    <dc:identifier id=\"bookid\">urn:isbn:12345</dc:identifier>
    <dc:title>An Older Book</dc:title>
    <dc:language>en</dc:language>
    <dc:creator opf:role=\"aut\" opf:file-as=\"Author, Ann\">Ann Author</dc:creator>
    <meta name=\"cover\" content=\"cover-picture\"/>
  </metadata>
  <manifest>
    <item id=\"ncx\" href=\"toc.ncx\" media-type=\"application/x-dtbncx+xml\"/>
    <item id=\"cover-picture\" href=\"cover.jpg\" media-type=\"image/jpeg\"/>
    <item id=\"ch1\" href=\"ch1.xhtml\" media-type=\"application/xhtml+xml\"/>
  </manifest>
  <spine toc=\"ncx\">
    <itemref idref=\"ch1\"/>
  </spine>
  <guide>
    <reference type=\"cover\" title=\"Cover\" href=\"cover.jpg\"/>
  </guide>
</package>"/utf8>>},
        {<<"OEBPS/toc.ncx"/utf8>>,
            <<"<?xml version=\"1.0\"?>
<ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" version=\"2005-1\">
  <navMap>
    <navPoint id=\"n1\" playOrder=\"1\">
      <navLabel><text>Chapter One</text></navLabel>
      <content src=\"ch1.xhtml\"/>
      <navPoint id=\"n2\" playOrder=\"2\">
        <navLabel><text>Part Two</text></navLabel>
        <content src=\"ch1.xhtml#p2\"/>
      </navPoint>
    </navPoint>
  </navMap>
</ncx>"/utf8>>}],
    Book@1 = case glepub:open(loader_of(Files)) of
        {ok, Book} -> Book;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"epub2_test"/utf8>>,
                        line => 208,
                        value => _assert_fail,
                        start => 7353,
                        'end' => 7404,
                        pattern_start => 7364,
                        pattern_end => 7372})
    end,
    _assert_subject = erlang:element(2, Book@1),
    _assert_subject@1 = <<"2.0"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"epub2_test"/utf8>>,
                line => 209,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 7414,
                    'end' => 7426
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 7430,
                    'end' => 7435
                    },
                start => 7407,
                'end' => 7435,
                expression_start => 7414})
    end,
    _assert_subject@2 = erlang:element(5, erlang:element(3, Book@1)),
    _assert_subject@3 = [{contributor,
            <<"Ann Author"/utf8>>,
            {some, <<"aut"/utf8>>},
            {some, <<"Author, Ann"/utf8>>}}],
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"epub2_test"/utf8>>,
                line => 210,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 7445,
                    'end' => 7467
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 7475,
                    'end' => 7536
                    },
                start => 7438,
                'end' => 7536,
                expression_start => 7445})
    end,
    _assert_subject@4 = erlang:element(6, Book@1),
    _assert_subject@5 = [{toc_entry,
            <<"Chapter One"/utf8>>,
            {some, <<"OEBPS/ch1.xhtml"/utf8>>},
            [{toc_entry,
                    <<"Part Two"/utf8>>,
                    {some, <<"OEBPS/ch1.xhtml#p2"/utf8>>},
                    []}]}],
    case _assert_subject@4 =:= _assert_subject@5 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"epub2_test"/utf8>>,
                line => 214,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 7606,
                    'end' => 7614
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 7622,
                    'end' => 7758
                    },
                start => 7599,
                'end' => 7758,
                expression_start => 7606})
    end,
    Cover@1 = case erlang:element(11, Book@1) of
        {some, Cover} -> Cover;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"epub2_test"/utf8>>,
                        line => 222,
                        value => _assert_fail@1,
                        start => 7824,
                        'end' => 7859,
                        pattern_start => 7835,
                        pattern_end => 7846})
    end,
    _assert_subject@6 = erlang:element(2, Cover@1),
    _assert_subject@7 = <<"cover-picture"/utf8>>,
    case _assert_subject@6 =:= _assert_subject@7 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"epub2_test"/utf8>>,
                line => 223,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@6,
                    start => 7869,
                    'end' => 7877
                    },
                right => #{kind => literal,
                    value => _assert_subject@7,
                    start => 7881,
                    'end' => 7896
                    },
                start => 7862,
                'end' => 7896,
                expression_start => 7869})
    end,
    _assert_subject@8 = erlang:element(8, Book@1),
    _assert_subject@9 = [{toc_entry,
            <<"Cover"/utf8>>,
            {some, <<"OEBPS/cover.jpg"/utf8>>},
            []}],
    case _assert_subject@8 =:= _assert_subject@9 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"epub2_test"/utf8>>,
                line => 224,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@8,
                    start => 7906,
                    'end' => 7920
                    },
                right => #{kind => literal,
                    value => _assert_subject@9,
                    start => 7924,
                    'end' => 7972
                    },
                start => 7899,
                'end' => 7972,
                expression_start => 7906})
    end.

-file("test/glepub_test.gleam", 227).
-spec resolve_test() -> nil.
resolve_test() ->
    _assert_subject = glepub:resolve(
        <<"OEBPS/text"/utf8>>,
        <<"../images/a.png"/utf8>>
    ),
    _assert_subject@1 = <<"OEBPS/images/a.png"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resolve_test"/utf8>>,
                line => 228,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 8009,
                    'end' => 8056
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 8060,
                    'end' => 8080
                    },
                start => 8002,
                'end' => 8080,
                expression_start => 8009})
    end,
    _assert_subject@2 = glepub:resolve(
        <<"OEBPS"/utf8>>,
        <<"./ch%201.xhtml#top"/utf8>>
    ),
    _assert_subject@3 = <<"OEBPS/ch 1.xhtml#top"/utf8>>,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resolve_test"/utf8>>,
                line => 229,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 8090,
                    'end' => 8135
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 8139,
                    'end' => 8161
                    },
                start => 8083,
                'end' => 8161,
                expression_start => 8090})
    end,
    _assert_subject@4 = glepub:resolve(<<""/utf8>>, <<"ch1.xhtml"/utf8>>),
    _assert_subject@5 = <<"ch1.xhtml"/utf8>>,
    case _assert_subject@4 =:= _assert_subject@5 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resolve_test"/utf8>>,
                line => 230,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 8171,
                    'end' => 8202
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 8206,
                    'end' => 8217
                    },
                start => 8164,
                'end' => 8217,
                expression_start => 8171})
    end,
    _assert_subject@6 = glepub:resolve(
        <<"OEBPS"/utf8>>,
        <<"/absolute.css"/utf8>>
    ),
    _assert_subject@7 = <<"absolute.css"/utf8>>,
    case _assert_subject@6 =:= _assert_subject@7 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resolve_test"/utf8>>,
                line => 231,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@6,
                    start => 8227,
                    'end' => 8267
                    },
                right => #{kind => literal,
                    value => _assert_subject@7,
                    start => 8271,
                    'end' => 8285
                    },
                start => 8220,
                'end' => 8285,
                expression_start => 8227})
    end,
    _assert_subject@8 = <<"https://example.com/x"/utf8>>,
    case glepub:is_external(_assert_subject@8) of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resolve_test"/utf8>>,
                line => 232,
                kind => function_call,
                arguments => [#{kind => literal,
                        value => _assert_subject@8,
                        start => 8314,
                        'end' => 8337
                        }],
                start => 8288,
                'end' => 8338,
                expression_start => 8295})
    end,
    case not glepub:is_external(<<"text/chapter1.xhtml"/utf8>>) of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resolve_test"/utf8>>,
                line => 233,
                kind => expression,
                expression => #{kind => expression,
                    value => false,
                    start => 8348,
                    'end' => 8390
                    },
                start => 8341,
                'end' => 8390,
                expression_start => 8348})
    end.

-file("test/glepub_test.gleam", 236).
-spec missing_container_test() -> {ok, glepub:book()} |
    {error, glepub:epub_error()}.
missing_container_test() ->
    _assert_subject = glepub:open(loader_of([])),
    case _assert_subject of
        {error, {missing_file, <<"META-INF/container.xml"/utf8>>}} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"missing_container_test"/utf8>>,
                        line => 237,
                        value => _assert_fail,
                        start => 8430,
                        'end' => 8525,
                        pattern_start => 8441,
                        pattern_end => 8492})
    end.
