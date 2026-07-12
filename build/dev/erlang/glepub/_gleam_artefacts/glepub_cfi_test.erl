-module(glepub_cfi_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "test/glepub_cfi_test.gleam").
-export([parse_test/0, parse_escaped_assertion_test/0, parse_rejects_test/0, locate_test/0, spine_item_test/0]).

-file("test/glepub_cfi_test.gleam", 8).
-spec parse_test() -> nil.
parse_test() ->
    Parsed@1 = case glepub@cfi:parse(
        <<"epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)"/utf8>>
    ) of
        {ok, Parsed} -> Parsed;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_cfi_test"/utf8>>,
                        function => <<"parse_test"/utf8>>,
                        line => 9,
                        value => _assert_fail,
                        start => 161,
                        'end' => 253,
                        pattern_start => 172,
                        pattern_end => 182})
    end,
    _assert_subject = {cfi,
        [[{step, 6, none}, {step, 4, {some, <<"chap01ref"/utf8>>}}],
            [{step, 4, {some, <<"body01"/utf8>>}},
                {step, 10, {some, <<"para05"/utf8>>}},
                {step, 3, none}]],
        {some, 10}},
    case Parsed@1 =:= _assert_subject of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"parse_test"/utf8>>,
                line => 11,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => Parsed@1,
                    start => 263,
                    'end' => 269
                    },
                right => #{kind => literal,
                    value => _assert_subject,
                    start => 277,
                    'end' => 449
                    },
                start => 256,
                'end' => 449,
                expression_start => 263})
    end,
    _assert_subject@1 = glepub@cfi:to_string(Parsed@1),
    _assert_subject@2 = <<"epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)"/utf8>>,
    case _assert_subject@1 =:= _assert_subject@2 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"parse_test"/utf8>>,
                line => 19,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@1,
                    start => 459,
                    'end' => 480
                    },
                right => #{kind => literal,
                    value => _assert_subject@2,
                    start => 488,
                    'end' => 541
                    },
                start => 452,
                'end' => 541,
                expression_start => 459})
    end.

-file("test/glepub_cfi_test.gleam", 23).
-spec parse_escaped_assertion_test() -> nil.
parse_escaped_assertion_test() ->
    Parsed@1 = case glepub@cfi:parse(<<"epubcfi(/6/2[a^]b])"/utf8>>) of
        {ok, Parsed} -> Parsed;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_cfi_test"/utf8>>,
                        function => <<"parse_escaped_assertion_test"/utf8>>,
                        line => 24,
                        value => _assert_fail,
                        start => 587,
                        'end' => 643,
                        pattern_start => 598,
                        pattern_end => 608})
    end,
    _assert_subject = {cfi,
        [[{step, 6, none}, {step, 2, {some, <<"a]b"/utf8>>}}]],
        none},
    case Parsed@1 =:= _assert_subject of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"parse_escaped_assertion_test"/utf8>>,
                line => 25,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => Parsed@1,
                    start => 653,
                    'end' => 659
                    },
                right => #{kind => literal,
                    value => _assert_subject,
                    start => 663,
                    'end' => 713
                    },
                start => 646,
                'end' => 713,
                expression_start => 653})
    end,
    _assert_subject@1 = glepub@cfi:to_string(Parsed@1),
    _assert_subject@2 = <<"epubcfi(/6/2[a^]b])"/utf8>>,
    case _assert_subject@1 =:= _assert_subject@2 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"parse_escaped_assertion_test"/utf8>>,
                line => 27,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@1,
                    start => 766,
                    'end' => 787
                    },
                right => #{kind => literal,
                    value => _assert_subject@2,
                    start => 791,
                    'end' => 812
                    },
                start => 759,
                'end' => 812,
                expression_start => 766})
    end.

-file("test/glepub_cfi_test.gleam", 30).
-spec parse_rejects_test() -> nil.
parse_rejects_test() ->
    _assert_subject = glepub@cfi:parse(<<"not a cfi"/utf8>>),
    _assert_subject@1 = {error, nil},
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"parse_rejects_test"/utf8>>,
                line => 31,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 855,
                    'end' => 877
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 881,
                    'end' => 891
                    },
                start => 848,
                'end' => 891,
                expression_start => 855})
    end,
    _assert_subject@2 = glepub@cfi:parse(<<"epubcfi()"/utf8>>),
    _assert_subject@3 = {error, nil},
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"parse_rejects_test"/utf8>>,
                line => 32,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 901,
                    'end' => 923
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 927,
                    'end' => 937
                    },
                start => 894,
                'end' => 937,
                expression_start => 901})
    end,
    _assert_subject@4 = glepub@cfi:parse(<<"epubcfi(6/4)"/utf8>>),
    _assert_subject@5 = {error, nil},
    case _assert_subject@4 =:= _assert_subject@5 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"parse_rejects_test"/utf8>>,
                line => 33,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 947,
                    'end' => 972
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 976,
                    'end' => 986
                    },
                start => 940,
                'end' => 986,
                expression_start => 947})
    end,
    _assert_subject@6 = glepub@cfi:parse(
        <<"epubcfi(/6/4!/4,/10/2:1,/10/2:5)"/utf8>>
    ),
    _assert_subject@7 = {error, nil},
    case _assert_subject@6 =:= _assert_subject@7 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"parse_rejects_test"/utf8>>,
                line => 35,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@6,
                    start => 1030,
                    'end' => 1075
                    },
                right => #{kind => literal,
                    value => _assert_subject@7,
                    start => 1079,
                    'end' => 1089
                    },
                start => 1023,
                'end' => 1089,
                expression_start => 1030})
    end,
    _assert_subject@8 = glepub@cfi:parse(<<"epubcfi(/6/4:2/2)"/utf8>>),
    _assert_subject@9 = {error, nil},
    case _assert_subject@8 =:= _assert_subject@9 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"parse_rejects_test"/utf8>>,
                line => 37,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@8,
                    start => 1128,
                    'end' => 1158
                    },
                right => #{kind => literal,
                    value => _assert_subject@9,
                    start => 1162,
                    'end' => 1172
                    },
                start => 1121,
                'end' => 1172,
                expression_start => 1128})
    end.

-file("test/glepub_cfi_test.gleam", 40).
-spec locate_test() -> nil.
locate_test() ->
    Full@1 = case glepub@cfi:parse(<<"epubcfi(/6/4!/4/10/3:10)"/utf8>>) of
        {ok, Full} -> Full;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_cfi_test"/utf8>>,
                        function => <<"locate_test"/utf8>>,
                        line => 41,
                        value => _assert_fail,
                        start => 1201,
                        'end' => 1260,
                        pattern_start => 1212,
                        pattern_end => 1220})
    end,
    Intra@1 = case glepub@cfi:locate(Full@1) of
        {ok, {1, {some, Intra}}} -> Intra;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_cfi_test"/utf8>>,
                        function => <<"locate_test"/utf8>>,
                        line => 42,
                        value => _assert_fail@1,
                        start => 1263,
                        'end' => 1314,
                        pattern_start => 1274,
                        pattern_end => 1295})
    end,
    _assert_subject = glepub@cfi:to_string(Intra@1),
    _assert_subject@1 = <<"epubcfi(/4/10/3:10)"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"locate_test"/utf8>>,
                line => 43,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 1324,
                    'end' => 1344
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 1348,
                    'end' => 1369
                    },
                start => 1317,
                'end' => 1369,
                expression_start => 1324})
    end,
    Chapter_only@1 = case glepub@cfi:parse(<<"epubcfi(/6/2)"/utf8>>) of
        {ok, Chapter_only} -> Chapter_only;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_cfi_test"/utf8>>,
                        function => <<"locate_test"/utf8>>,
                        line => 46,
                        value => _assert_fail@2,
                        start => 1416,
                        'end' => 1472,
                        pattern_start => 1427,
                        pattern_end => 1443})
    end,
    _assert_subject@2 = glepub@cfi:locate(Chapter_only@1),
    _assert_subject@3 = {ok, {0, none}},
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"locate_test"/utf8>>,
                line => 47,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 1482,
                    'end' => 1506
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 1510,
                    'end' => 1524
                    },
                start => 1475,
                'end' => 1524,
                expression_start => 1482})
    end,
    Odd@1 = case glepub@cfi:parse(<<"epubcfi(/6/3)"/utf8>>) of
        {ok, Odd} -> Odd;
        _assert_fail@3 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_cfi_test"/utf8>>,
                        function => <<"locate_test"/utf8>>,
                        line => 50,
                        value => _assert_fail@3,
                        start => 1587,
                        'end' => 1634,
                        pattern_start => 1598,
                        pattern_end => 1605})
    end,
    _assert_subject@4 = glepub@cfi:locate(Odd@1),
    _assert_subject@5 = {error, nil},
    case _assert_subject@4 =:= _assert_subject@5 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"locate_test"/utf8>>,
                line => 51,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 1644,
                    'end' => 1659
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 1663,
                    'end' => 1673
                    },
                start => 1637,
                'end' => 1673,
                expression_start => 1644})
    end.

-file("test/glepub_cfi_test.gleam", 61).
-spec fixture() -> fun((binary()) -> {ok, bitstring()} | {error, nil}).
fixture() ->
    Files = begin
        _pipe = [{<<"META-INF/container.xml"/utf8>>,
                <<"<?xml version=\"1.0\"?>
<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">
  <rootfiles>
    <rootfile full-path=\"content.opf\" media-type=\"application/oebps-package+xml\"/>
  </rootfiles>
</container>"/utf8>>},
            {<<"content.opf"/utf8>>,
                <<"<?xml version=\"1.0\"?>
<package xmlns=\"http://www.idpf.org/2007/opf\" version=\"3.0\" unique-identifier=\"i\">
  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">
    <dc:identifier id=\"i\">urn:uuid:1</dc:identifier>
    <dc:title>T</dc:title>
    <dc:language>en</dc:language>
  </metadata>
  <manifest>
    <item id=\"c1\" href=\"one.xhtml\" media-type=\"application/xhtml+xml\"/>
    <item id=\"c2\" href=\"two.xhtml\" media-type=\"application/xhtml+xml\"/>
  </manifest>
  <spine>
    <itemref idref=\"c1\"/>
    <itemref idref=\"c2\"/>
  </spine>
</package>"/utf8>>}],
        _pipe@1 = gleam@list:map(
            _pipe,
            fun(File) ->
                {erlang:element(1, File),
                    gleam_stdlib:identity(erlang:element(2, File))}
            end
        ),
        maps:from_list(_pipe@1)
    end,
    fun(Path) -> gleam_stdlib:map_get(Files, Path) end.

-file("test/glepub_cfi_test.gleam", 54).
-spec spine_item_test() -> nil.
spine_item_test() ->
    Book@1 = case glepub:open(fixture()) of
        {ok, Book} -> Book;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_cfi_test"/utf8>>,
                        function => <<"spine_item_test"/utf8>>,
                        line => 55,
                        value => _assert_fail,
                        start => 1706,
                        'end' => 1750,
                        pattern_start => 1717,
                        pattern_end => 1725})
    end,
    Parsed@1 = case glepub@cfi:parse(<<"epubcfi(/6/4!/4/2)"/utf8>>) of
        {ok, Parsed} -> Parsed;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_cfi_test"/utf8>>,
                        function => <<"spine_item_test"/utf8>>,
                        line => 56,
                        value => _assert_fail@1,
                        start => 1753,
                        'end' => 1808,
                        pattern_start => 1764,
                        pattern_end => 1774})
    end,
    Item@1 = case glepub@cfi:spine_item(Book@1, Parsed@1) of
        {ok, {Item, {some, _}}} -> Item;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glepub_cfi_test"/utf8>>,
                        function => <<"spine_item_test"/utf8>>,
                        line => 57,
                        value => _assert_fail@2,
                        start => 1811,
                        'end' => 1873,
                        pattern_start => 1822,
                        pattern_end => 1842})
    end,
    _assert_subject = erlang:element(2, erlang:element(2, Item@1)),
    _assert_subject@1 = <<"c2"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"glepub_cfi_test"/utf8>>,
                function => <<"spine_item_test"/utf8>>,
                line => 58,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 1883,
                    'end' => 1895
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 1899,
                    'end' => 1903
                    },
                start => 1876,
                'end' => 1903,
                expression_start => 1883})
    end.
