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
    _assert_subject@8 = gleam@list:map(
        erlang:element(5, Book@1),
        fun(S@2) -> erlang:element(5, S@2) end
    ),
    _assert_subject@9 = [<<"/6/2"/utf8>>, <<"/6/4"/utf8>>],
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
                    start => 4551,
                    'end' => 4588
                    },
                right => #{kind => literal,
                    value => _assert_subject@9,
                    start => 4592,
                    'end' => 4608
                    },
                start => 4544,
                'end' => 4608,
                expression_start => 4551})
    end,
    Second@1 = case erlang:element(5, Book@1) of
        [_, Second] -> Second;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"manifest_and_spine_test"/utf8>>,
                        line => 125,
                        value => _assert_fail@2,
                        start => 4611,
                        'end' => 4646,
                        pattern_start => 4622,
                        pattern_end => 4633})
    end,
    _assert_subject@10 = erlang:element(5, erlang:element(2, Second@1)),
    _assert_subject@11 = [<<"scripted"/utf8>>],
    case _assert_subject@10 =:= _assert_subject@11 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"manifest_and_spine_test"/utf8>>,
                line => 126,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@10,
                    start => 4656,
                    'end' => 4678
                    },
                right => #{kind => literal,
                    value => _assert_subject@11,
                    start => 4682,
                    'end' => 4694
                    },
                start => 4649,
                'end' => 4694,
                expression_start => 4656})
    end,
    _assert_subject@12 = erlang:element(9, Book@1),
    _assert_subject@13 = right_to_left,
    case _assert_subject@12 =:= _assert_subject@13 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"manifest_and_spine_test"/utf8>>,
                line => 127,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@12,
                    start => 4704,
                    'end' => 4718
                    },
                right => #{kind => expression,
                    value => _assert_subject@13,
                    start => 4722,
                    'end' => 4740
                    },
                start => 4697,
                'end' => 4740,
                expression_start => 4704})
    end.

-file("test/glepub_test.gleam", 130).
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
                        line => 131,
                        value => _assert_fail,
                        start => 4772,
                        'end' => 4814,
                        pattern_start => 4783,
                        pattern_end => 4791})
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
                line => 132,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 4824,
                    'end' => 4845
                    },
                right => #{kind => expression,
                    value => _assert_subject@1,
                    start => 4849,
                    'end' => 4868
                    },
                start => 4817,
                'end' => 4868,
                expression_start => 4824})
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
                line => 133,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 4878,
                    'end' => 4899
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 4903,
                    'end' => 4920
                    },
                start => 4871,
                'end' => 4920,
                expression_start => 4878})
    end,
    _assert_subject@4 = erlang:element(3, erlang:element(10, Book@1)),
    case _assert_subject@4 =:= none of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"rendition_test"/utf8>>,
                line => 134,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 4930,
                    'end' => 4956
                    },
                right => #{kind => literal,
                    value => none,
                    start => 4960,
                    'end' => 4964
                    },
                start => 4923,
                'end' => 4964,
                expression_start => 4930})
    end.

-file("test/glepub_test.gleam", 137).
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
                        line => 138,
                        value => _assert_fail,
                        start => 4990,
                        'end' => 5032,
                        pattern_start => 5001,
                        pattern_end => 5009})
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
                line => 140,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 5112,
                    'end' => 5120
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 5128,
                    'end' => 5337
                    },
                start => 5105,
                'end' => 5337,
                expression_start => 5112})
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
                line => 147,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 5347,
                    'end' => 5361
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 5369,
                    'end' => 5427
                    },
                start => 5340,
                'end' => 5427,
                expression_start => 5347})
    end.

-file("test/glepub_test.gleam", 151).
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
                        line => 152,
                        value => _assert_fail,
                        start => 5459,
                        'end' => 5501,
                        pattern_start => 5470,
                        pattern_end => 5478})
    end,
    First@1 = case erlang:element(5, Book@1) of
        [First | _] -> First;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"resources_test"/utf8>>,
                        line => 153,
                        value => _assert_fail@1,
                        start => 5504,
                        'end' => 5539,
                        pattern_start => 5515,
                        pattern_end => 5526})
    end,
    Chapter@1 = case glepub:document(Book@1, erlang:element(2, First@1)) of
        {ok, Chapter} -> Chapter;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"resources_test"/utf8>>,
                        line => 154,
                        value => _assert_fail@2,
                        start => 5542,
                        'end' => 5600,
                        pattern_start => 5553,
                        pattern_end => 5564})
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
                line => 155,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 5610,
                    'end' => 5643
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 5647,
                    'end' => 5665
                    },
                start => 5603,
                'end' => 5665,
                expression_start => 5610})
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
                        line => 157,
                        value => _assert_fail@3,
                        start => 5669,
                        'end' => 5756,
                        pattern_start => 5680,
                        pattern_end => 5688})
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
                line => 159,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 5766,
                    'end' => 5773
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 5777,
                    'end' => 5781
                    },
                start => 5759,
                'end' => 5781,
                expression_start => 5766})
    end,
    Missing@1 = case erlang:element(5, Book@1) of
        [_, Missing] -> Missing;
        _assert_fail@4 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"resources_test"/utf8>>,
                        line => 161,
                        value => _assert_fail@4,
                        start => 5785,
                        'end' => 5821,
                        pattern_start => 5796,
                        pattern_end => 5808})
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
                        line => 162,
                        value => _assert_fail@5,
                        start => 5824,
                        'end' => 5931,
                        pattern_start => 5835,
                        pattern_end => 5889})
    end.

-file("test/glepub_test.gleam", 166).
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
                        line => 210,
                        value => _assert_fail,
                        start => 7479,
                        'end' => 7530,
                        pattern_start => 7490,
                        pattern_end => 7498})
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
                line => 211,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 7540,
                    'end' => 7552
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 7556,
                    'end' => 7561
                    },
                start => 7533,
                'end' => 7561,
                expression_start => 7540})
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
                line => 212,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 7571,
                    'end' => 7593
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 7601,
                    'end' => 7662
                    },
                start => 7564,
                'end' => 7662,
                expression_start => 7571})
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
                line => 216,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 7732,
                    'end' => 7740
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 7748,
                    'end' => 7884
                    },
                start => 7725,
                'end' => 7884,
                expression_start => 7732})
    end,
    Cover@1 = case erlang:element(11, Book@1) of
        {some, Cover} -> Cover;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_test"/utf8>>,
                        function => <<"epub2_test"/utf8>>,
                        line => 224,
                        value => _assert_fail@1,
                        start => 7950,
                        'end' => 7985,
                        pattern_start => 7961,
                        pattern_end => 7972})
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
                line => 225,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@6,
                    start => 7995,
                    'end' => 8003
                    },
                right => #{kind => literal,
                    value => _assert_subject@7,
                    start => 8007,
                    'end' => 8022
                    },
                start => 7988,
                'end' => 8022,
                expression_start => 7995})
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
                line => 226,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@8,
                    start => 8032,
                    'end' => 8046
                    },
                right => #{kind => literal,
                    value => _assert_subject@9,
                    start => 8050,
                    'end' => 8098
                    },
                start => 8025,
                'end' => 8098,
                expression_start => 8032})
    end.

-file("test/glepub_test.gleam", 229).
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
                line => 230,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 8135,
                    'end' => 8182
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 8186,
                    'end' => 8206
                    },
                start => 8128,
                'end' => 8206,
                expression_start => 8135})
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
                line => 231,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 8216,
                    'end' => 8261
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 8265,
                    'end' => 8287
                    },
                start => 8209,
                'end' => 8287,
                expression_start => 8216})
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
                line => 232,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 8297,
                    'end' => 8328
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 8332,
                    'end' => 8343
                    },
                start => 8290,
                'end' => 8343,
                expression_start => 8297})
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
                line => 233,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@6,
                    start => 8353,
                    'end' => 8393
                    },
                right => #{kind => literal,
                    value => _assert_subject@7,
                    start => 8397,
                    'end' => 8411
                    },
                start => 8346,
                'end' => 8411,
                expression_start => 8353})
    end,
    _assert_subject@8 = <<"https://example.com/x"/utf8>>,
    case glepub:is_external(_assert_subject@8) of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resolve_test"/utf8>>,
                line => 234,
                kind => function_call,
                arguments => [#{kind => literal,
                        value => _assert_subject@8,
                        start => 8440,
                        'end' => 8463
                        }],
                start => 8414,
                'end' => 8464,
                expression_start => 8421})
    end,
    case not glepub:is_external(<<"text/chapter1.xhtml"/utf8>>) of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_test"/utf8>>,
                function => <<"resolve_test"/utf8>>,
                line => 235,
                kind => expression,
                expression => #{kind => expression,
                    value => false,
                    start => 8474,
                    'end' => 8516
                    },
                start => 8467,
                'end' => 8516,
                expression_start => 8474})
    end.

-file("test/glepub_test.gleam", 238).
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
                        line => 239,
                        value => _assert_fail,
                        start => 8556,
                        'end' => 8651,
                        pattern_start => 8567,
                        pattern_end => 8618})
    end.
