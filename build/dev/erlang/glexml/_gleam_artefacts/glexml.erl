-module(glexml).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/glexml.gleam").
-export([empty_dtd/0, merge_dtds/2, parse_with_dtd/2, parse/1, parse_bytes_with_dtd/2, parse_bytes/1, parse_dtd/1, parse_dtd_with/2, error_to_string/1, attribute/2, child_elements/1, children_named/2, first_child_named/2, descendants_named/2, at/2, text_content/1, local_name/1, namespace_prefix/1, element_to_string/1, doctype_to_string/1, document_to_string/1]).
-export_type([document/0, doctype/0, external_id/0, dtd/0, entity/0, content_model/0, particle/0, occurrence/0, attribute_declaration/0, attribute_kind/0, attribute_default/0, element/0, attribute/0, node_/0, parse_error/0, error_kind/0, detected_encoding/0, subset_kind/0, dtd_input/0, dtd_state/0, group_separator/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " A pure Gleam XML parser that runs on both the Erlang and JavaScript\n"
    " targets, making it suitable for use on the server and in the browser.\n"
    "\n"
    " glexml parses a whole XML document into an immutable tree of nodes and\n"
    " provides helper functions for navigating that tree. It was built to be\n"
    " the core of an EPUB tool, so it comfortably handles the documents found\n"
    " inside EPUB files: package documents (OPF), `container.xml`, NCX, and\n"
    " XHTML content documents.\n"
    "\n"
    " Supported XML features:\n"
    "\n"
    " - Elements, attributes, and text content\n"
    " - Namespaced (qualified) names such as `dc:title`, kept as strings\n"
    " - The five predefined entities (`&amp;` `&lt;` `&gt;` `&quot;` `&apos;`)\n"
    "   and decimal/hexadecimal character references (`&#169;`, `&#x1F600;`)\n"
    " - CDATA sections, comments, and processing instructions\n"
    " - The XML declaration, byte order marks, and CRLF/CR line ending\n"
    "   normalisation\n"
    " - DOCTYPE declarations and DTDs: `<!ELEMENT>`, `<!ATTLIST>`,\n"
    "   `<!ENTITY>` (general and parameter), and `<!NOTATION>` declarations,\n"
    "   entity expansion in content and attribute values (including entities\n"
    "   containing markup, with recursion detection), and conditional\n"
    "   sections in external subsets. Validation lives in the `glexml/dtd`\n"
    "   module.\n"
    "\n"
    " The parser never performs I/O, so external entities and external DTD\n"
    " subsets are not fetched (fetching them is a classic security hole).\n"
    " Load an external DTD's text yourself, parse it with `parse_dtd`, and\n"
    " pass it to `parse_with_dtd` to make its entities available.\n"
    "\n"
    " `parse` takes a `String` (already-decoded text). For raw bytes use\n"
    " `parse_bytes`, which detects the encoding as the XML specification\n"
    " describes and decodes UTF-8 and UTF-16 itself.\n"
    "\n"
    " Internally the parser scans a `BitArray` rather than a `String`: bit\n"
    " array patterns compile to binary pattern matching on Erlang and constant\n"
    " time buffer views on JavaScript, which keeps parsing linear on both\n"
    " targets. Every scanning delimiter in XML is ASCII, so byte-level\n"
    " scanning never splits a multi-byte UTF-8 character.\n"
).

-type document() :: {document,
        binary(),
        gleam@option:option(binary()),
        boolean(),
        gleam@option:option(doctype()),
        list(node_()),
        element(),
        list(node_())}.

-type doctype() :: {doctype,
        binary(),
        gleam@option:option(external_id()),
        dtd()}.

-type external_id() :: {system, binary()} |
    {public, binary(), gleam@option:option(binary())}.

-type dtd() :: {dtd,
        gleam@dict:dict(binary(), content_model()),
        gleam@dict:dict(binary(), list(attribute_declaration())),
        gleam@dict:dict(binary(), entity()),
        gleam@dict:dict(binary(), binary()),
        list(binary()),
        list(binary()),
        list(binary())}.

-type entity() :: {internal_entity, binary()} |
    {external_entity,
        external_id(),
        gleam@option:option(binary()),
        gleam@option:option(binary())}.

-type content_model() :: empty_content |
    any_content |
    {mixed_content, list(binary())} |
    {element_content, particle()}.

-type particle() :: {name_particle, binary(), occurrence()} |
    {sequence, list(particle()), occurrence()} |
    {choice, list(particle()), occurrence()}.

-type occurrence() :: exactly_one | zero_or_one | zero_or_more | one_or_more.

-type attribute_declaration() :: {attribute_declaration,
        binary(),
        attribute_kind(),
        attribute_default()}.

-type attribute_kind() :: cdata_attribute |
    id_attribute |
    id_ref_attribute |
    id_refs_attribute |
    entity_attribute |
    entities_attribute |
    nmtoken_attribute |
    nmtokens_attribute |
    {notation_attribute, list(binary())} |
    {enumerated_attribute, list(binary())}.

-type attribute_default() :: required |
    implied |
    {fixed, binary()} |
    {default, binary()}.

-type element() :: {element, binary(), list(attribute()), list(node_())}.

-type attribute() :: {attribute, binary(), binary()}.

-type node_() :: {element_node, element()} |
    {text_node, binary(), boolean()} |
    {comment_node, binary()} |
    {processing_instruction_node, binary(), binary()} |
    {entity_reference_node, binary()}.

-type parse_error() :: {parse_error,
        error_kind(),
        integer(),
        integer(),
        integer()}.

-type error_kind() :: unexpected_end_of_input |
    missing_root_element |
    content_after_root_element |
    invalid_name |
    {malformed_attribute, binary()} |
    {duplicate_attribute, binary()} |
    {mismatched_closing_tag, binary(), binary()} |
    malformed_entity |
    {unknown_entity, binary()} |
    {invalid_character_reference, binary()} |
    malformed_doctype |
    {recursive_entity, binary()} |
    {unresolvable_entity, binary()} |
    {markup_in_attribute_value, binary()} |
    invalid_character |
    malformed_comment |
    cdata_end_in_content |
    {unbalanced_entity, binary()} |
    missing_whitespace |
    {unsupported_encoding, binary()} |
    {declared_encoding_mismatch, binary(), binary()}.

-type detected_encoding() :: detected_utf8 | {detected_utf16, boolean()}.

-type subset_kind() :: internal_subset | external_subset.

-type dtd_input() :: {dtd_input,
        bitstring(),
        gleam@option:option(binary()),
        integer(),
        boolean(),
        gleam@option:option(dtd_input())}.

-type dtd_state() :: {dtd_state,
        dtd(),
        boolean(),
        integer(),
        boolean(),
        gleam@dict:dict(binary(), nil)}.

-type group_separator() :: undecided_separator |
    sequence_separator |
    choice_separator.

-file("src/glexml.gleam", 626).
?DOC(" A DTD with no declarations at all.\n").
-spec empty_dtd() -> dtd().
empty_dtd() ->
    {dtd, maps:new(), maps:new(), maps:new(), maps:new(), [], [], []}.

-file("src/glexml.gleam", 3747).
?DOC(
    " Positions are only computed when parsing fails: the number of bytes\n"
    " remaining at the failure point gives the consumed prefix, whose line,\n"
    " column, and length in graphemes locate the error.\n"
).
-spec make_error(bitstring(), error_kind(), integer()) -> parse_error().
make_error(Input, Kind, Remaining) ->
    Consumed_bytes = gleam@int:clamp(
        erlang:byte_size(Input) - Remaining,
        0,
        erlang:byte_size(Input)
    ),
    Consumed = case gleam_stdlib:bit_array_slice(Input, 0, Consumed_bytes) of
        {ok, Bytes} ->
            _pipe = gleam@bit_array:to_string(Bytes),
            gleam@result:unwrap(_pipe, <<""/utf8>>);

        {error, nil} ->
            <<""/utf8>>
    end,
    Lines = gleam@string:split(Consumed, <<"\n"/utf8>>),
    Line = erlang:length(Lines),
    Column = case gleam@list:last(Lines) of
        {ok, Last} ->
            string:length(Last) + 1;

        {error, nil} ->
            1
    end,
    {parse_error, Kind, Line, Column, string:length(Consumed)}.

-file("src/glexml.gleam", 3477).
?DOC(
    " Take `count` bytes from the front of the input as a string. This cannot\n"
    " fail: counts come from scanning the same bit array, and scanning stops\n"
    " only at ASCII delimiters, so the bytes are always whole UTF-8 characters.\n"
).
-spec take_string(bitstring(), integer()) -> binary().
take_string(Input, Count) ->
    Bytes@1 = case gleam_stdlib:bit_array_slice(Input, 0, Count) of
        {ok, Bytes} -> Bytes;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glexml"/utf8>>,
                        function => <<"take_string"/utf8>>,
                        line => 3478,
                        value => _assert_fail,
                        start => 117067,
                        'end' => 117122,
                        pattern_start => 117078,
                        pattern_end => 117087})
    end,
    String@1 = case gleam@bit_array:to_string(Bytes@1) of
        {ok, String} -> String;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"glexml"/utf8>>,
                        function => <<"take_string"/utf8>>,
                        line => 3479,
                        value => _assert_fail@1,
                        start => 117125,
                        'end' => 117175,
                        pattern_start => 117136,
                        pattern_end => 117146})
    end,
    String@1.

-file("src/glexml.gleam", 3328).
?DOC(
    " Whether a byte may never appear in an XML document: the control\n"
    " characters other than tab and line feed (carriage returns are gone by\n"
    " this point, normalised to line feeds).\n"
).
-spec is_forbidden_byte(integer()) -> boolean().
is_forbidden_byte(Byte) ->
    (((Byte < 16#20) andalso (Byte /= 16#9)) andalso (Byte /= 16#A)) andalso (Byte
    /= 16#D).

-file("src/glexml.gleam", 3453).
-spec scan_processing_instruction_end(bitstring(), integer()) -> {ok,
        {integer(), bitstring()}} |
    {error, {error_kind(), integer()}}.
scan_processing_instruction_end(Input, Count) ->
    case Input of
        <<"?>"/utf8, Rest/binary>> ->
            {ok, {Count, Rest}};

        <<16#EF, 16#BF, 16#BE, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<16#EF, 16#BF, 16#BF, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<Byte, Rest@1/binary>> ->
            case is_forbidden_byte(Byte) of
                false ->
                    scan_processing_instruction_end(Rest@1, Count + 1);

                true ->
                    {error, {invalid_character, erlang:byte_size(Input)}}
            end;

        _ ->
            {error, {unexpected_end_of_input, 0}}
    end.

-file("src/glexml.gleam", 1340).
-spec require(
    boolean(),
    {error_kind(), integer()},
    fun(() -> {ok, DTG} | {error, {error_kind(), integer()}})
) -> {ok, DTG} | {error, {error_kind(), integer()}}.
require(Condition, Failure, Continue) ->
    case Condition of
        true ->
            Continue();

        false ->
            {error, Failure}
    end.

-file("src/glexml.gleam", 3261).
?DOC(" The NameStartChar production from XML 1.0 fifth edition.\n").
-spec is_name_start_character(integer()) -> boolean().
is_name_start_character(Code) ->
    (((((((((((((((Code =:= 16#3A) orelse (Code =:= 16#5F)) orelse ((Code >= 16#41)
    andalso (Code =< 16#5A)))
    orelse ((Code >= 16#61) andalso (Code =< 16#7A)))
    orelse ((Code >= 16#C0) andalso (Code =< 16#D6)))
    orelse ((Code >= 16#D8) andalso (Code =< 16#F6)))
    orelse ((Code >= 16#F8) andalso (Code =< 16#2FF)))
    orelse ((Code >= 16#370) andalso (Code =< 16#37D)))
    orelse ((Code >= 16#37F) andalso (Code =< 16#1FFF)))
    orelse ((Code >= 16#200C) andalso (Code =< 16#200D)))
    orelse ((Code >= 16#2070) andalso (Code =< 16#218F)))
    orelse ((Code >= 16#2C00) andalso (Code =< 16#2FEF)))
    orelse ((Code >= 16#3001) andalso (Code =< 16#D7FF)))
    orelse ((Code >= 16#F900) andalso (Code =< 16#FDCF)))
    orelse ((Code >= 16#FDF0) andalso (Code =< 16#FFFD)))
    orelse ((Code >= 16#10000) andalso (Code =< 16#EFFFF)).

-file("src/glexml.gleam", 3281).
?DOC(" The NameChar production from XML 1.0 fifth edition.\n").
-spec is_name_character(integer()) -> boolean().
is_name_character(Code) ->
    (((((is_name_start_character(Code) orelse (Code =:= 16#2D)) orelse (Code =:= 16#2E))
    orelse (Code =:= 16#B7))
    orelse ((Code >= 16#30) andalso (Code =< 16#39)))
    orelse ((Code >= 16#300) andalso (Code =< 16#36F)))
    orelse ((Code >= 16#203F) andalso (Code =< 16#2040)).

-file("src/glexml.gleam", 3249).
-spec is_valid_name(binary()) -> boolean().
is_valid_name(Name) ->
    case gleam@string:to_utf_codepoints(Name) of
        [] ->
            false;

        [First | Rest] ->
            is_name_start_character(gleam_stdlib:identity(First)) andalso gleam@list:all(
                Rest,
                fun(Codepoint) ->
                    is_name_character(gleam_stdlib:identity(Codepoint))
                end
            )
    end.

-file("src/glexml.gleam", 3306).
?DOC(
    " Whether a byte can appear in an element or attribute name. This is\n"
    " deliberately lenient: anything that cannot terminate a name (or open\n"
    " other markup) is accepted, which also admits all multi-byte UTF-8\n"
    " characters, as the XML specification largely does.\n"
).
-spec is_name_byte(integer()) -> boolean().
is_name_byte(Byte) ->
    case Byte of
        9 ->
            false;

        10 ->
            false;

        32 ->
            false;

        33 ->
            false;

        34 ->
            false;

        37 ->
            false;

        38 ->
            false;

        39 ->
            false;

        40 ->
            false;

        41 ->
            false;

        42 ->
            false;

        43 ->
            false;

        44 ->
            false;

        47 ->
            false;

        59 ->
            false;

        60 ->
            false;

        61 ->
            false;

        62 ->
            false;

        63 ->
            false;

        91 ->
            false;

        93 ->
            false;

        124 ->
            false;

        _ ->
            true
    end.

-file("src/glexml.gleam", 3291).
-spec scan_name(bitstring(), integer()) -> {integer(), bitstring()}.
scan_name(Input, Count) ->
    case Input of
        <<Byte, Rest/binary>> ->
            case is_name_byte(Byte) of
                true ->
                    scan_name(Rest, Count + 1);

                false ->
                    {Count, Input}
            end;

        _ ->
            {Count, Input}
    end.

-file("src/glexml.gleam", 3214).
-spec parse_name(bitstring()) -> {ok, {binary(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_name(Input) ->
    case scan_name(Input, 0) of
        {0, <<>>} ->
            {error, {unexpected_end_of_input, 0}};

        {0, Rest} ->
            {error, {invalid_name, erlang:byte_size(Rest)}};

        {Count, Rest@1} ->
            Name = take_string(Input, Count),
            case is_valid_name(Name) of
                true ->
                    {ok, {Name, Rest@1}};

                false ->
                    {error, {invalid_name, erlang:byte_size(Input)}}
            end
    end.

-file("src/glexml.gleam", 3083).
?DOC(" Parse a processing instruction. The input begins immediately after `<?`.\n").
-spec parse_processing_instruction(bitstring()) -> {ok, {node_(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_processing_instruction(Input) ->
    gleam@result:'try'(
        parse_name(Input),
        fun(_use0) ->
            {Target, Rest} = _use0,
            require(
                string:lowercase(Target) /= <<"xml"/utf8>>,
                {invalid_name, erlang:byte_size(Input)},
                fun() -> case Rest of
                        <<>> ->
                            {error, {unexpected_end_of_input, 0}};

                        <<"?>"/utf8, Rest@1/binary>> ->
                            {ok,
                                {{processing_instruction_node,
                                        Target,
                                        <<""/utf8>>},
                                    Rest@1}};

                        <<" "/utf8, Rest@2/binary>> ->
                            case scan_processing_instruction_end(Rest@2, 0) of
                                {ok, {Count, After}} ->
                                    {ok,
                                        {{processing_instruction_node,
                                                Target,
                                                gleam@string:trim_start(
                                                    take_string(Rest@2, Count)
                                                )},
                                            After}};

                                {error, Failure} ->
                                    {error, Failure}
                            end;

                        <<"\t"/utf8, Rest@2/binary>> ->
                            case scan_processing_instruction_end(Rest@2, 0) of
                                {ok, {Count, After}} ->
                                    {ok,
                                        {{processing_instruction_node,
                                                Target,
                                                gleam@string:trim_start(
                                                    take_string(Rest@2, Count)
                                                )},
                                            After}};

                                {error, Failure} ->
                                    {error, Failure}
                            end;

                        <<"\n"/utf8, Rest@2/binary>> ->
                            case scan_processing_instruction_end(Rest@2, 0) of
                                {ok, {Count, After}} ->
                                    {ok,
                                        {{processing_instruction_node,
                                                Target,
                                                gleam@string:trim_start(
                                                    take_string(Rest@2, Count)
                                                )},
                                            After}};

                                {error, Failure} ->
                                    {error, Failure}
                            end;

                        _ ->
                            {error, {invalid_name, erlang:byte_size(Rest)}}
                    end end
            )
        end
    ).

-file("src/glexml.gleam", 3417).
-spec scan_comment_end(bitstring(), integer()) -> {ok, {integer(), bitstring()}} |
    {error, {error_kind(), integer()}}.
scan_comment_end(Input, Count) ->
    case Input of
        <<"-->"/utf8, Rest/binary>> ->
            {ok, {Count, Rest}};

        <<"--"/utf8, _/binary>> ->
            {error, {malformed_comment, erlang:byte_size(Input)}};

        <<16#EF, 16#BF, 16#BE, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<16#EF, 16#BF, 16#BF, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<Byte, Rest@1/binary>> ->
            case is_forbidden_byte(Byte) of
                false ->
                    scan_comment_end(Rest@1, Count + 1);

                true ->
                    {error, {invalid_character, erlang:byte_size(Input)}}
            end;

        _ ->
            {error, {unexpected_end_of_input, 0}}
    end.

-file("src/glexml.gleam", 3075).
?DOC(" Parse a comment. The input begins immediately after `<!--`.\n").
-spec parse_comment(bitstring()) -> {ok, {binary(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_comment(Input) ->
    case scan_comment_end(Input, 0) of
        {ok, {Count, Rest}} ->
            {ok, {take_string(Input, Count), Rest}};

        {error, Failure} ->
            {error, Failure}
    end.

-file("src/glexml.gleam", 3316).
-spec skip_whitespace(bitstring()) -> bitstring().
skip_whitespace(Input) ->
    case Input of
        <<" "/utf8, Rest/binary>> ->
            skip_whitespace(Rest);

        <<"\t"/utf8, Rest/binary>> ->
            skip_whitespace(Rest);

        <<"\n"/utf8, Rest/binary>> ->
            skip_whitespace(Rest);

        _ ->
            Input
    end.

-file("src/glexml.gleam", 1223).
?DOC(
    " Read whitespace, comments, and processing instructions after the root\n"
    " element, keeping the comments and processing instructions in document\n"
    " order.\n"
).
-spec parse_epilogue(bitstring(), list(node_())) -> {ok,
        {list(node_()), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_epilogue(Input, Nodes) ->
    Input@1 = skip_whitespace(Input),
    case Input@1 of
        <<"<!--"/utf8, Rest/binary>> ->
            case parse_comment(Rest) of
                {ok, {Content, Rest@1}} ->
                    parse_epilogue(Rest@1, [{comment_node, Content} | Nodes]);

                {error, Failure} ->
                    {error, Failure}
            end;

        <<"<?"/utf8, Rest@2/binary>> ->
            case parse_processing_instruction(Rest@2) of
                {ok, {Instruction, Rest@3}} ->
                    parse_epilogue(Rest@3, [Instruction | Nodes]);

                {error, Failure@1} ->
                    {error, Failure@1}
            end;

        _ ->
            {ok, {lists:reverse(Nodes), Input@1}}
    end.

-file("src/glexml.gleam", 3436).
-spec scan_cdata_end(bitstring(), integer()) -> {ok, {integer(), bitstring()}} |
    {error, {error_kind(), integer()}}.
scan_cdata_end(Input, Count) ->
    case Input of
        <<"]]>"/utf8, Rest/binary>> ->
            {ok, {Count, Rest}};

        <<16#EF, 16#BF, 16#BE, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<16#EF, 16#BF, 16#BF, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<Byte, Rest@1/binary>> ->
            case is_forbidden_byte(Byte) of
                false ->
                    scan_cdata_end(Rest@1, Count + 1);

                true ->
                    {error, {invalid_character, erlang:byte_size(Input)}}
            end;

        _ ->
            {error, {unexpected_end_of_input, 0}}
    end.

-file("src/glexml.gleam", 3062).
-spec take_adjacent_text(list(node_()), list(binary()), boolean()) -> {list(binary()),
    boolean(),
    list(node_())}.
take_adjacent_text(Nodes, Acc, Literal) ->
    case Nodes of
        [{text_node, Text, Text_literal} | Rest] ->
            take_adjacent_text(Rest, [Text | Acc], Literal andalso Text_literal);

        _ ->
            {Acc, Literal, Nodes}
    end.

-file("src/glexml.gleam", 3046).
-spec do_merge_adjacent_text(list(node_()), list(node_())) -> list(node_()).
do_merge_adjacent_text(Nodes, Acc) ->
    case Nodes of
        [] ->
            lists:reverse(Acc);

        [{text_node, First, First_literal} | Rest] ->
            {Pieces, Literal, Rest@1} = take_adjacent_text(
                Rest,
                [First],
                First_literal
            ),
            Text = erlang:list_to_binary(lists:reverse(Pieces)),
            do_merge_adjacent_text(Rest@1, [{text_node, Text, Literal} | Acc]);

        [Node | Rest@2] ->
            do_merge_adjacent_text(Rest@2, [Node | Acc])
    end.

-file("src/glexml.gleam", 3042).
?DOC(
    " Entity expansion can produce several text nodes in a row; combine them\n"
    " so consumers see one text node per run of character data, and drop any\n"
    " that are empty.\n"
).
-spec merge_adjacent_text(list(node_())) -> list(node_()).
merge_adjacent_text(Nodes) ->
    do_merge_adjacent_text(Nodes, []).

-file("src/glexml.gleam", 3016).
?DOC(" Parse a closing tag. The input begins immediately after `</`.\n").
-spec parse_closing_tag(bitstring(), binary(), list(node_())) -> {ok,
        {list(node_()), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_closing_tag(Input, Parent, Acc) ->
    gleam@result:'try'(
        parse_name(Input),
        fun(_use0) ->
            {Closing, Rest} = _use0,
            Rest@1 = skip_whitespace(Rest),
            case Rest@1 of
                <<>> ->
                    {error, {unexpected_end_of_input, 0}};

                <<">"/utf8, Rest@2/binary>> ->
                    case Closing =:= Parent of
                        true ->
                            {ok,
                                {merge_adjacent_text(lists:reverse(Acc)),
                                    Rest@2}};

                        false ->
                            {error,
                                {{mismatched_closing_tag, Parent, Closing},
                                    erlang:byte_size(Input) + 2}}
                    end;

                _ ->
                    {error, {invalid_name, erlang:byte_size(Rest@1)}}
            end
        end
    ).

-file("src/glexml.gleam", 3338).
?DOC(
    " Count the bytes of character data before the next `<` or `&`, stopping\n"
    " without consuming it. The remaining input is returned alongside the\n"
    " count. Characters XML forbids, and the `]]>` sequence, are errors.\n"
).
-spec scan_text(bitstring(), integer()) -> {ok, {integer(), bitstring()}} |
    {error, {error_kind(), integer()}}.
scan_text(Input, Count) ->
    case Input of
        <<"<"/utf8, _/binary>> ->
            {ok, {Count, Input}};

        <<"&"/utf8, _/binary>> ->
            {ok, {Count, Input}};

        <<"]]>"/utf8, _/binary>> ->
            {error, {cdata_end_in_content, erlang:byte_size(Input)}};

        <<16#EF, 16#BF, 16#BE, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<16#EF, 16#BF, 16#BF, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<Byte, Rest/binary>> ->
            case is_forbidden_byte(Byte) of
                false ->
                    scan_text(Rest, Count + 1);

                true ->
                    {error, {invalid_character, erlang:byte_size(Input)}}
            end;

        _ ->
            {ok, {Count, Input}}
    end.

-file("src/glexml.gleam", 2909).
?DOC(
    " The number of bytes a `&name;` reference and everything after it spans,\n"
    " used to report error positions at the `&`.\n"
).
-spec reference_size(binary(), bitstring()) -> integer().
reference_size(Reference, After) ->
    (erlang:byte_size(Reference) + 2) + erlang:byte_size(After).

-file("src/glexml.gleam", 3733).
?DOC(" The Char production from the XML specification.\n").
-spec is_valid_xml_character(integer()) -> boolean().
is_valid_xml_character(Code) ->
    (((((Code =:= 16#9) orelse (Code =:= 16#A)) orelse (Code =:= 16#D)) orelse ((Code
    >= 16#20)
    andalso (Code =< 16#D7FF)))
    orelse ((Code >= 16#E000) andalso (Code =< 16#FFFD)))
    orelse ((Code >= 16#10000) andalso (Code =< 16#10FFFF)).

-file("src/glexml.gleam", 3713).
-spec resolve_character_reference(binary(), integer(), binary()) -> {ok,
        binary()} |
    {error, error_kind()}.
resolve_character_reference(Digits, Base, Reference) ->
    case gleam@int:base_parse(Digits, Base) of
        {error, nil} ->
            {error, {invalid_character_reference, Reference}};

        {ok, Code} ->
            case is_valid_xml_character(Code) of
                false ->
                    {error, {invalid_character_reference, Reference}};

                true ->
                    case gleam@string:utf_codepoint(Code) of
                        {error, nil} ->
                            {error, {invalid_character_reference, Reference}};

                        {ok, Codepoint} ->
                            {ok,
                                gleam_stdlib:utf_codepoint_list_to_string(
                                    [Codepoint]
                                )}
                    end
            end
    end.

-file("src/glexml.gleam", 3700).
-spec resolve_entity(binary()) -> {ok, binary()} | {error, error_kind()}.
resolve_entity(Reference) ->
    case Reference of
        <<"amp"/utf8>> ->
            {ok, <<"&"/utf8>>};

        <<"lt"/utf8>> ->
            {ok, <<"<"/utf8>>};

        <<"gt"/utf8>> ->
            {ok, <<">"/utf8>>};

        <<"quot"/utf8>> ->
            {ok, <<"\""/utf8>>};

        <<"apos"/utf8>> ->
            {ok, <<"'"/utf8>>};

        <<"#x"/utf8, Digits/binary>> ->
            resolve_character_reference(Digits, 16, Reference);

        <<"#"/utf8, Digits@1/binary>> ->
            resolve_character_reference(Digits@1, 10, Reference);

        _ ->
            {error, {unknown_entity, Reference}}
    end.

-file("src/glexml.gleam", 3594).
-spec do_decode_character_references(binary(), list(binary()), boolean()) -> {ok,
        {binary(), boolean()}} |
    {error, error_kind()}.
do_decode_character_references(Text, Acc, Literal) ->
    case gleam@string:split_once(Text, <<"&"/utf8>>) of
        {error, nil} ->
            {ok, {erlang:list_to_binary(lists:reverse([Text | Acc])), Literal}};

        {ok, {Before, After}} ->
            case gleam@string:split_once(After, <<";"/utf8>>) of
                {error, nil} ->
                    {error, malformed_entity};

                {ok, {Reference, Rest}} ->
                    case resolve_entity(Reference) of
                        {error, Kind} ->
                            {error, Kind};

                        {ok, Replacement} ->
                            Literal@1 = case Reference of
                                <<"#"/utf8, _/binary>> ->
                                    false;

                                _ ->
                                    Literal
                            end,
                            do_decode_character_references(
                                Rest,
                                [Replacement, Before | Acc],
                                Literal@1
                            )
                    end
            end
    end.

-file("src/glexml.gleam", 3588).
?DOC(
    " Decode character references and the five predefined entities in text\n"
    " where general entities have already been expanded.\n"
    " Also reports whether the text stayed \"literal\": character references\n"
    " recognised here poison the text for use as element-content separator\n"
    " whitespace, while entity references (the predefined five) do not.\n"
).
-spec decode_character_references(binary()) -> {ok, {binary(), boolean()}} |
    {error, error_kind()}.
decode_character_references(Text) ->
    do_decode_character_references(Text, [], true).

-file("src/glexml.gleam", 3356).
?DOC(" Parse a `name;` after a `&` or `%`, consuming the semicolon.\n").
-spec parse_reference_name(bitstring()) -> {ok, {binary(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_reference_name(Input) ->
    case scan_name(Input, 0) of
        {0, _} ->
            {error, {malformed_entity, erlang:byte_size(Input) + 1}};

        {Count, Rest} ->
            case Rest of
                <<";"/utf8, Rest@1/binary>> ->
                    {ok, {take_string(Input, Count), Rest@1}};

                _ ->
                    {error, {malformed_entity, erlang:byte_size(Input) + 1}}
            end
    end.

-file("src/glexml.gleam", 3513).
-spec expand_references_in_bytes(
    bitstring(),
    dtd(),
    list(binary()),
    list(binary())
) -> {ok, binary()} | {error, error_kind()}.
expand_references_in_bytes(Input, Dtd, Active, Acc) ->
    case Input of
        <<>> ->
            {ok, erlang:list_to_binary(lists:reverse(Acc))};

        <<"<![CDATA["/utf8, Rest/binary>> ->
            case scan_cdata_end(Rest, 0) of
                {error, {Kind, _}} ->
                    {error, Kind};

                {ok, {Count, After}} ->
                    expand_references_in_bytes(
                        After,
                        Dtd,
                        Active,
                        [<<<<"<![CDATA["/utf8,
                                    (take_string(Rest, Count))/binary>>/binary,
                                "]]>"/utf8>> |
                            Acc]
                    )
            end;

        <<"<!--"/utf8, Rest@1/binary>> ->
            case scan_comment_end(Rest@1, 0) of
                {error, {Kind@1, _}} ->
                    {error, Kind@1};

                {ok, {Count@1, After@1}} ->
                    expand_references_in_bytes(
                        After@1,
                        Dtd,
                        Active,
                        [<<<<"<!--"/utf8,
                                    (take_string(Rest@1, Count@1))/binary>>/binary,
                                "-->"/utf8>> |
                            Acc]
                    )
            end;

        <<"<?"/utf8, Rest@2/binary>> ->
            case scan_processing_instruction_end(Rest@2, 0) of
                {error, {Kind@2, _}} ->
                    {error, Kind@2};

                {ok, {Count@2, After@2}} ->
                    expand_references_in_bytes(
                        After@2,
                        Dtd,
                        Active,
                        [<<<<"<?"/utf8, (take_string(Rest@2, Count@2))/binary>>/binary,
                                "?>"/utf8>> |
                            Acc]
                    )
            end;

        <<"<"/utf8, Rest@3/binary>> ->
            expand_references_in_bytes(
                Rest@3,
                Dtd,
                Active,
                [<<"<"/utf8>> | Acc]
            );

        <<"&"/utf8, Rest@4/binary>> ->
            case parse_reference_name(Rest@4) of
                {error, {Kind@3, _}} ->
                    {error, Kind@3};

                {ok, {Reference, After@3}} ->
                    case Reference of
                        <<"#"/utf8, _/binary>> ->
                            expand_references_in_bytes(
                                After@3,
                                Dtd,
                                Active,
                                [<<<<"&"/utf8, Reference/binary>>/binary,
                                        ";"/utf8>> |
                                    Acc]
                            );

                        <<"amp"/utf8>> ->
                            expand_references_in_bytes(
                                After@3,
                                Dtd,
                                Active,
                                [<<<<"&"/utf8, Reference/binary>>/binary,
                                        ";"/utf8>> |
                                    Acc]
                            );

                        <<"lt"/utf8>> ->
                            expand_references_in_bytes(
                                After@3,
                                Dtd,
                                Active,
                                [<<<<"&"/utf8, Reference/binary>>/binary,
                                        ";"/utf8>> |
                                    Acc]
                            );

                        <<"gt"/utf8>> ->
                            expand_references_in_bytes(
                                After@3,
                                Dtd,
                                Active,
                                [<<<<"&"/utf8, Reference/binary>>/binary,
                                        ";"/utf8>> |
                                    Acc]
                            );

                        <<"quot"/utf8>> ->
                            expand_references_in_bytes(
                                After@3,
                                Dtd,
                                Active,
                                [<<<<"&"/utf8, Reference/binary>>/binary,
                                        ";"/utf8>> |
                                    Acc]
                            );

                        <<"apos"/utf8>> ->
                            expand_references_in_bytes(
                                After@3,
                                Dtd,
                                Active,
                                [<<<<"&"/utf8, Reference/binary>>/binary,
                                        ";"/utf8>> |
                                    Acc]
                            );

                        _ ->
                            case expand_general_entity(Reference, Dtd, Active) of
                                {error, Kind@4} ->
                                    {error, Kind@4};

                                {ok, Expansion} ->
                                    expand_references_in_bytes(
                                        After@3,
                                        Dtd,
                                        Active,
                                        [Expansion | Acc]
                                    )
                            end
                    end
            end;

        _ ->
            case scan_text(Input, 0) of
                {error, {Kind@5, _}} ->
                    {error, Kind@5};

                {ok, {Count@3, Rest@5}} ->
                    expand_references_in_bytes(
                        Rest@5,
                        Dtd,
                        Active,
                        [take_string(Input, Count@3) | Acc]
                    )
            end
    end.

-file("src/glexml.gleam", 3491).
?DOC(
    " Fully expand a general entity declared in the DTD to its replacement\n"
    " text: nested general entity references are expanded recursively (with\n"
    " cycle detection via `active`), while character references, the five\n"
    " predefined entities, CDATA sections, comments, and processing\n"
    " instructions are left untouched for the parser or the final text decode\n"
    " to handle.\n"
).
-spec expand_general_entity(binary(), dtd(), list(binary())) -> {ok, binary()} |
    {error, error_kind()}.
expand_general_entity(Name, Dtd, Active) ->
    case gleam@list:contains(Active, Name) of
        true ->
            {error, {recursive_entity, Name}};

        false ->
            case gleam_stdlib:map_get(erlang:element(4, Dtd), Name) of
                {error, nil} ->
                    {error, {unknown_entity, Name}};

                {ok, {external_entity, _, _, _}} ->
                    {error, {unresolvable_entity, Name}};

                {ok, {internal_entity, Replacement}} ->
                    expand_references_in_bytes(
                        gleam_stdlib:identity(Replacement),
                        Dtd,
                        [Name | Active],
                        []
                    )
            end
    end.

-file("src/glexml.gleam", 3196).
-spec has_attribute(list(attribute()), binary()) -> boolean().
has_attribute(Attributes, Name) ->
    gleam@list:any(
        Attributes,
        fun(Attribute) -> erlang:element(2, Attribute) =:= Name end
    ).

-file("src/glexml.gleam", 3643).
-spec do_decode_attribute_text(binary(), dtd(), list(binary()), list(binary())) -> {ok,
        binary()} |
    {error, error_kind()}.
do_decode_attribute_text(Text, Dtd, Active, Acc) ->
    case gleam@string:split_once(Text, <<"&"/utf8>>) of
        {error, nil} ->
            {ok, erlang:list_to_binary(lists:reverse([Text | Acc]))};

        {ok, {Before, After}} ->
            case gleam@string:split_once(After, <<";"/utf8>>) of
                {error, nil} ->
                    {error, malformed_entity};

                {ok, {Reference, Rest}} ->
                    case Reference of
                        <<"#"/utf8, _/binary>> ->
                            case resolve_entity(Reference) of
                                {error, Kind} ->
                                    {error, Kind};

                                {ok, Replacement} ->
                                    do_decode_attribute_text(
                                        Rest,
                                        Dtd,
                                        Active,
                                        [Replacement, Before | Acc]
                                    )
                            end;

                        <<"amp"/utf8>> ->
                            case resolve_entity(Reference) of
                                {error, Kind} ->
                                    {error, Kind};

                                {ok, Replacement} ->
                                    do_decode_attribute_text(
                                        Rest,
                                        Dtd,
                                        Active,
                                        [Replacement, Before | Acc]
                                    )
                            end;

                        <<"lt"/utf8>> ->
                            case resolve_entity(Reference) of
                                {error, Kind} ->
                                    {error, Kind};

                                {ok, Replacement} ->
                                    do_decode_attribute_text(
                                        Rest,
                                        Dtd,
                                        Active,
                                        [Replacement, Before | Acc]
                                    )
                            end;

                        <<"gt"/utf8>> ->
                            case resolve_entity(Reference) of
                                {error, Kind} ->
                                    {error, Kind};

                                {ok, Replacement} ->
                                    do_decode_attribute_text(
                                        Rest,
                                        Dtd,
                                        Active,
                                        [Replacement, Before | Acc]
                                    )
                            end;

                        <<"quot"/utf8>> ->
                            case resolve_entity(Reference) of
                                {error, Kind} ->
                                    {error, Kind};

                                {ok, Replacement} ->
                                    do_decode_attribute_text(
                                        Rest,
                                        Dtd,
                                        Active,
                                        [Replacement, Before | Acc]
                                    )
                            end;

                        <<"apos"/utf8>> ->
                            case resolve_entity(Reference) of
                                {error, Kind} ->
                                    {error, Kind};

                                {ok, Replacement} ->
                                    do_decode_attribute_text(
                                        Rest,
                                        Dtd,
                                        Active,
                                        [Replacement, Before | Acc]
                                    )
                            end;

                        _ ->
                            case gleam@list:contains(Active, Reference) of
                                true ->
                                    {error, {recursive_entity, Reference}};

                                false ->
                                    case gleam_stdlib:map_get(
                                        erlang:element(4, Dtd),
                                        Reference
                                    ) of
                                        {error, nil} ->
                                            {error, {unknown_entity, Reference}};

                                        {ok, {external_entity, _, _, _}} ->
                                            {error,
                                                {unresolvable_entity, Reference}};

                                        {ok, {internal_entity, Replacement@1}} ->
                                            case gleam_stdlib:contains_string(
                                                Replacement@1,
                                                <<"<"/utf8>>
                                            ) of
                                                true ->
                                                    {error,
                                                        {markup_in_attribute_value,
                                                            Reference}};

                                                false ->
                                                    case decode_attribute_text(
                                                        Replacement@1,
                                                        Dtd,
                                                        [Reference | Active]
                                                    ) of
                                                        {error, Kind@1} ->
                                                            {error, Kind@1};

                                                        {ok, Replacement@2} ->
                                                            do_decode_attribute_text(
                                                                Rest,
                                                                Dtd,
                                                                Active,
                                                                [Replacement@2,
                                                                    Before |
                                                                    Acc]
                                                            )
                                                    end
                                            end
                                    end
                            end
                    end
            end
    end.

-file("src/glexml.gleam", 3627).
?DOC(
    " Decode an attribute value: whitespace is normalised to spaces, character\n"
    " references become characters, and entity references are expanded\n"
    " recursively. An entity that would put a `<` in the value is an error, as\n"
    " the specification requires.\n"
).
-spec decode_attribute_text(binary(), dtd(), list(binary())) -> {ok, binary()} |
    {error, error_kind()}.
decode_attribute_text(Text, Dtd, Active) ->
    Text@1 = begin
        _pipe = Text,
        _pipe@1 = gleam@string:replace(_pipe, <<"\n"/utf8>>, <<" "/utf8>>),
        _pipe@2 = gleam@string:replace(_pipe@1, <<"\t"/utf8>>, <<" "/utf8>>),
        gleam@string:replace(_pipe@2, <<"\r"/utf8>>, <<" "/utf8>>)
    end,
    do_decode_attribute_text(Text@1, Dtd, Active, []).

-file("src/glexml.gleam", 3394).
?DOC(
    " Scan an attribute value to its closing quote, consuming it. A literal\n"
    " `<` is not allowed in attribute values.\n"
).
-spec scan_attribute_value(bitstring(), integer(), integer()) -> {ok,
        {integer(), bitstring()}} |
    {error, {error_kind(), integer()}}.
scan_attribute_value(Input, Count, Quote) ->
    case Input of
        <<"<"/utf8, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<16#EF, 16#BF, 16#BE, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<16#EF, 16#BF, 16#BF, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<Byte, Rest/binary>> ->
            case Byte =:= Quote of
                true ->
                    {ok, {Count, Rest}};

                false ->
                    case is_forbidden_byte(Byte) of
                        false ->
                            scan_attribute_value(Rest, Count + 1, Quote);

                        true ->
                            {error,
                                {invalid_character, erlang:byte_size(Input)}}
                    end
            end;

        _ ->
            {error, {unexpected_end_of_input, 0}}
    end.

-file("src/glexml.gleam", 3181).
-spec finish_attribute_value(bitstring(), integer(), dtd()) -> {ok,
        {binary(), bitstring()}} |
    {error, {error_kind(), integer()}}.
finish_attribute_value(Input, Quote, Dtd) ->
    case scan_attribute_value(Input, 0, Quote) of
        {error, Failure} ->
            {error, Failure};

        {ok, {Count, Rest}} ->
            case decode_attribute_text(take_string(Input, Count), Dtd, []) of
                {ok, Value} ->
                    {ok, {Value, Rest}};

                {error, Kind} ->
                    {error, {Kind, erlang:byte_size(Rest)}}
            end
    end.

-file("src/glexml.gleam", 3169).
-spec parse_attribute_value(bitstring(), binary(), dtd()) -> {ok,
        {binary(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_attribute_value(Input, Attribute, Dtd) ->
    case Input of
        <<"\""/utf8, Rest/binary>> ->
            finish_attribute_value(Rest, 34, Dtd);

        <<"'"/utf8, Rest@1/binary>> ->
            finish_attribute_value(Rest@1, 39, Dtd);

        _ ->
            {error, {{malformed_attribute, Attribute}, erlang:byte_size(Input)}}
    end.

-file("src/glexml.gleam", 3153).
-spec parse_attribute(bitstring(), dtd()) -> {ok, {attribute(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_attribute(Input, Dtd) ->
    gleam@result:'try'(
        parse_name(Input),
        fun(_use0) ->
            {Name, Rest} = _use0,
            Rest@1 = skip_whitespace(Rest),
            case Rest@1 of
                <<"="/utf8, Rest@2/binary>> ->
                    Rest@3 = skip_whitespace(Rest@2),
                    gleam@result:'try'(
                        parse_attribute_value(Rest@3, Name, Dtd),
                        fun(_use0@1) ->
                            {Value, Rest@4} = _use0@1,
                            {ok, {{attribute, Name, Value}, Rest@4}}
                        end
                    );

                _ ->
                    {error,
                        {{malformed_attribute, Name}, erlang:byte_size(Rest@1)}}
            end
        end
    ).

-file("src/glexml.gleam", 3118).
-spec parse_attributes(bitstring(), list(attribute()), dtd()) -> {ok,
        {list(attribute()), bitstring(), boolean()}} |
    {error, {error_kind(), integer()}}.
parse_attributes(Input, Acc, Dtd) ->
    Stripped = skip_whitespace(Input),
    case Stripped of
        <<>> ->
            {error, {unexpected_end_of_input, 0}};

        <<"/>"/utf8, Rest/binary>> ->
            {ok, {lists:reverse(Acc), Rest, true}};

        <<">"/utf8, Rest@1/binary>> ->
            {ok, {lists:reverse(Acc), Rest@1, false}};

        _ ->
            gleam@result:'try'(
                case erlang:byte_size(Stripped) < erlang:byte_size(Input) of
                    true ->
                        {ok, Stripped};

                    false ->
                        {error,
                            {missing_whitespace, erlang:byte_size(Stripped)}}
                end,
                fun(Input@1) -> case parse_attribute(Input@1, Dtd) of
                        {error, Failure} ->
                            {error, Failure};

                        {ok, {Attribute, Rest@2}} ->
                            case has_attribute(
                                Acc,
                                erlang:element(2, Attribute)
                            ) of
                                true ->
                                    {error,
                                        {{duplicate_attribute,
                                                erlang:element(2, Attribute)},
                                            erlang:byte_size(Input@1)}};

                                false ->
                                    parse_attributes(
                                        Rest@2,
                                        [Attribute | Acc],
                                        Dtd
                                    )
                            end
                    end end
            )
    end.

-file("src/glexml.gleam", 2920).
?DOC(
    " Parse the expansion of a general entity as content. The expansion must\n"
    " be balanced on its own: reaching the end of the fragment is success, and\n"
    " a closing tag with no matching open element within the fragment is an\n"
    " error. Returns the nodes newest-first, matching how `parse_children`\n"
    " accumulates. General entity references no longer occur here — they were\n"
    " expanded before the fragment was parsed — so only character and\n"
    " predefined references remain.\n"
).
-spec parse_fragment(bitstring(), dtd(), binary(), list(node_()), boolean()) -> {ok,
        list(node_())} |
    {error, {error_kind(), integer()}}.
parse_fragment(Input, Dtd, Entity, Acc, Relaxed_entities) ->
    case Input of
        <<>> ->
            {ok, Acc};

        <<"</"/utf8, _/binary>> ->
            {error, {{unbalanced_entity, Entity}, erlang:byte_size(Input)}};

        <<"<!--"/utf8, Rest/binary>> ->
            case parse_comment(Rest) of
                {ok, {Content, Rest@1}} ->
                    parse_fragment(
                        Rest@1,
                        Dtd,
                        Entity,
                        [{comment_node, Content} | Acc],
                        Relaxed_entities
                    );

                {error, Failure} ->
                    {error, Failure}
            end;

        <<"<![CDATA["/utf8, Rest@2/binary>> ->
            case scan_cdata_end(Rest@2, 0) of
                {ok, {Count, After}} ->
                    parse_fragment(
                        After,
                        Dtd,
                        Entity,
                        [{text_node, take_string(Rest@2, Count), false} | Acc],
                        Relaxed_entities
                    );

                {error, Failure@1} ->
                    {error, Failure@1}
            end;

        <<"<?"/utf8, Rest@3/binary>> ->
            case parse_processing_instruction(Rest@3) of
                {ok, {Instruction, Rest@4}} ->
                    parse_fragment(
                        Rest@4,
                        Dtd,
                        Entity,
                        [Instruction | Acc],
                        Relaxed_entities
                    );

                {error, Failure@2} ->
                    {error, Failure@2}
            end;

        <<"<"/utf8, Rest@5/binary>> ->
            case parse_element(Rest@5, Dtd, Relaxed_entities) of
                {ok, {Element, Rest@6}} ->
                    parse_fragment(
                        Rest@6,
                        Dtd,
                        Entity,
                        [{element_node, Element} | Acc],
                        Relaxed_entities
                    );

                {error, Failure@3} ->
                    {error, Failure@3}
            end;

        <<"&"/utf8, Rest@7/binary>> ->
            case parse_reference_name(Rest@7) of
                {error, Failure@4} ->
                    {error, Failure@4};

                {ok, {Reference, After@1}} ->
                    case resolve_entity(Reference) of
                        {ok, Text} ->
                            Literal = case Reference of
                                <<"#"/utf8, _/binary>> ->
                                    false;

                                _ ->
                                    true
                            end,
                            parse_fragment(
                                After@1,
                                Dtd,
                                Entity,
                                [{text_node, Text, Literal} | Acc],
                                Relaxed_entities
                            );

                        {error, Kind} ->
                            {error, {Kind, reference_size(Reference, After@1)}}
                    end
            end;

        _ ->
            case scan_text(Input, 0) of
                {error, Failure@5} ->
                    {error, Failure@5};

                {ok, {Count@1, Rest@8}} ->
                    parse_fragment(
                        Rest@8,
                        Dtd,
                        Entity,
                        [{text_node, take_string(Input, Count@1), true} | Acc],
                        Relaxed_entities
                    )
            end
    end.

-file("src/glexml.gleam", 2707).
?DOC(
    " Parse the children of an element up to and including its closing tag.\n"
    "\n"
    " When `in_markup` is true the input begins just after a `<`. This function\n"
    " only ever tail-calls itself so that it compiles to a loop on the\n"
    " JavaScript target, where a long run of sibling nodes would otherwise\n"
    " overflow the stack.\n"
).
-spec parse_children(
    bitstring(),
    boolean(),
    binary(),
    list(node_()),
    dtd(),
    boolean()
) -> {ok, {list(node_()), bitstring()}} | {error, {error_kind(), integer()}}.
parse_children(Input, In_markup, Parent, Acc, Dtd, Relaxed_entities) ->
    case In_markup of
        false ->
            case Input of
                <<>> ->
                    {error, {unexpected_end_of_input, 0}};

                <<"<"/utf8, Rest/binary>> ->
                    parse_children(
                        Rest,
                        true,
                        Parent,
                        Acc,
                        Dtd,
                        Relaxed_entities
                    );

                <<"&"/utf8, Rest@1/binary>> ->
                    case parse_reference_name(Rest@1) of
                        {error, Failure} ->
                            {error, Failure};

                        {ok, {Reference, After}} ->
                            case Reference of
                                <<"#"/utf8, _/binary>> ->
                                    case resolve_entity(Reference) of
                                        {ok, Text} ->
                                            parse_children(
                                                After,
                                                false,
                                                Parent,
                                                [{text_node, Text, false} | Acc],
                                                Dtd,
                                                Relaxed_entities
                                            );

                                        {error, Kind} ->
                                            {error,
                                                {Kind,
                                                    reference_size(
                                                        Reference,
                                                        After
                                                    )}}
                                    end;

                                <<"amp"/utf8>> ->
                                    case resolve_entity(Reference) of
                                        {ok, Text@1} ->
                                            parse_children(
                                                After,
                                                false,
                                                Parent,
                                                [{text_node, Text@1, true} |
                                                    Acc],
                                                Dtd,
                                                Relaxed_entities
                                            );

                                        {error, Kind@1} ->
                                            {error,
                                                {Kind@1,
                                                    reference_size(
                                                        Reference,
                                                        After
                                                    )}}
                                    end;

                                <<"lt"/utf8>> ->
                                    case resolve_entity(Reference) of
                                        {ok, Text@1} ->
                                            parse_children(
                                                After,
                                                false,
                                                Parent,
                                                [{text_node, Text@1, true} |
                                                    Acc],
                                                Dtd,
                                                Relaxed_entities
                                            );

                                        {error, Kind@1} ->
                                            {error,
                                                {Kind@1,
                                                    reference_size(
                                                        Reference,
                                                        After
                                                    )}}
                                    end;

                                <<"gt"/utf8>> ->
                                    case resolve_entity(Reference) of
                                        {ok, Text@1} ->
                                            parse_children(
                                                After,
                                                false,
                                                Parent,
                                                [{text_node, Text@1, true} |
                                                    Acc],
                                                Dtd,
                                                Relaxed_entities
                                            );

                                        {error, Kind@1} ->
                                            {error,
                                                {Kind@1,
                                                    reference_size(
                                                        Reference,
                                                        After
                                                    )}}
                                    end;

                                <<"quot"/utf8>> ->
                                    case resolve_entity(Reference) of
                                        {ok, Text@1} ->
                                            parse_children(
                                                After,
                                                false,
                                                Parent,
                                                [{text_node, Text@1, true} |
                                                    Acc],
                                                Dtd,
                                                Relaxed_entities
                                            );

                                        {error, Kind@1} ->
                                            {error,
                                                {Kind@1,
                                                    reference_size(
                                                        Reference,
                                                        After
                                                    )}}
                                    end;

                                <<"apos"/utf8>> ->
                                    case resolve_entity(Reference) of
                                        {ok, Text@1} ->
                                            parse_children(
                                                After,
                                                false,
                                                Parent,
                                                [{text_node, Text@1, true} |
                                                    Acc],
                                                Dtd,
                                                Relaxed_entities
                                            );

                                        {error, Kind@1} ->
                                            {error,
                                                {Kind@1,
                                                    reference_size(
                                                        Reference,
                                                        After
                                                    )}}
                                    end;

                                _ ->
                                    case expand_general_entity(
                                        Reference,
                                        Dtd,
                                        []
                                    ) of
                                        {error, Kind@2} ->
                                            case {Kind@2, Relaxed_entities} of
                                                {{unknown_entity, _}, true} ->
                                                    parse_children(
                                                        After,
                                                        false,
                                                        Parent,
                                                        [{entity_reference_node,
                                                                Reference} |
                                                            Acc],
                                                        Dtd,
                                                        Relaxed_entities
                                                    );

                                                {_, _} ->
                                                    {error,
                                                        {Kind@2,
                                                            reference_size(
                                                                Reference,
                                                                After
                                                            )}}
                                            end;

                                        {ok, Expansion} ->
                                            case gleam_stdlib:contains_string(
                                                Expansion,
                                                <<"<"/utf8>>
                                            ) of
                                                true ->
                                                    case parse_fragment(
                                                        gleam_stdlib:identity(
                                                            Expansion
                                                        ),
                                                        Dtd,
                                                        Reference,
                                                        [],
                                                        Relaxed_entities
                                                    ) of
                                                        {ok, Nodes} ->
                                                            parse_children(
                                                                After,
                                                                false,
                                                                Parent,
                                                                lists:append(
                                                                    Nodes,
                                                                    Acc
                                                                ),
                                                                Dtd,
                                                                Relaxed_entities
                                                            );

                                                        {error, {Kind@3, _}} ->
                                                            Kind@4 = case Kind@3 of
                                                                unexpected_end_of_input ->
                                                                    {unbalanced_entity,
                                                                        Reference};

                                                                {mismatched_closing_tag,
                                                                    _,
                                                                    _} ->
                                                                    {unbalanced_entity,
                                                                        Reference};

                                                                Other ->
                                                                    Other
                                                            end,
                                                            {error,
                                                                {Kind@4,
                                                                    reference_size(
                                                                        Reference,
                                                                        After
                                                                    )}}
                                                    end;

                                                false ->
                                                    case decode_character_references(
                                                        Expansion
                                                    ) of
                                                        {ok, {Text@2, Literal}} ->
                                                            parse_children(
                                                                After,
                                                                false,
                                                                Parent,
                                                                [{text_node,
                                                                        Text@2,
                                                                        Literal} |
                                                                    Acc],
                                                                Dtd,
                                                                Relaxed_entities
                                                            );

                                                        {error, Kind@5} ->
                                                            {error,
                                                                {Kind@5,
                                                                    reference_size(
                                                                        Reference,
                                                                        After
                                                                    )}}
                                                    end
                                            end
                                    end
                            end
                    end;

                _ ->
                    case scan_text(Input, 0) of
                        {error, Failure@1} ->
                            {error, Failure@1};

                        {ok, {Count, Rest@2}} ->
                            case Rest@2 of
                                <<>> ->
                                    {error, {unexpected_end_of_input, 0}};

                                _ ->
                                    parse_children(
                                        Rest@2,
                                        false,
                                        Parent,
                                        [{text_node,
                                                take_string(Input, Count),
                                                true} |
                                            Acc],
                                        Dtd,
                                        Relaxed_entities
                                    )
                            end
                    end
            end;

        true ->
            case Input of
                <<>> ->
                    {error, {unexpected_end_of_input, 0}};

                <<"/"/utf8, Rest@3/binary>> ->
                    parse_closing_tag(Rest@3, Parent, Acc);

                <<"!--"/utf8, Rest@4/binary>> ->
                    case parse_comment(Rest@4) of
                        {ok, {Content, Rest@5}} ->
                            parse_children(
                                Rest@5,
                                false,
                                Parent,
                                [{comment_node, Content} | Acc],
                                Dtd,
                                Relaxed_entities
                            );

                        {error, Failure@2} ->
                            {error, Failure@2}
                    end;

                <<"![CDATA["/utf8, Rest@6/binary>> ->
                    case scan_cdata_end(Rest@6, 0) of
                        {ok, {Count@1, After@1}} ->
                            parse_children(
                                After@1,
                                false,
                                Parent,
                                [{text_node,
                                        take_string(Rest@6, Count@1),
                                        false} |
                                    Acc],
                                Dtd,
                                Relaxed_entities
                            );

                        {error, Failure@3} ->
                            {error, Failure@3}
                    end;

                <<"?"/utf8, Rest@7/binary>> ->
                    case parse_processing_instruction(Rest@7) of
                        {ok, {Instruction, Rest@8}} ->
                            parse_children(
                                Rest@8,
                                false,
                                Parent,
                                [Instruction | Acc],
                                Dtd,
                                Relaxed_entities
                            );

                        {error, Failure@4} ->
                            {error, Failure@4}
                    end;

                _ ->
                    case parse_element(Input, Dtd, Relaxed_entities) of
                        {ok, {Element, Rest@9}} ->
                            parse_children(
                                Rest@9,
                                false,
                                Parent,
                                [{element_node, Element} | Acc],
                                Dtd,
                                Relaxed_entities
                            );

                        {error, Failure@5} ->
                            {error, Failure@5}
                    end
            end
    end.

-file("src/glexml.gleam", 2674).
?DOC(" Parse an element. The input begins immediately after the opening `<`.\n").
-spec parse_element(bitstring(), dtd(), boolean()) -> {ok,
        {element(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_element(Input, Dtd, Relaxed_entities) ->
    gleam@result:'try'(
        parse_name(Input),
        fun(_use0) ->
            {Name, Rest} = _use0,
            gleam@result:'try'(
                parse_attributes(Rest, [], Dtd),
                fun(_use0@1) ->
                    {Attributes, Rest@1, Self_closing} = _use0@1,
                    case Self_closing of
                        true ->
                            {ok, {{element, Name, Attributes, []}, Rest@1}};

                        false ->
                            gleam@result:'try'(
                                parse_children(
                                    Rest@1,
                                    false,
                                    Name,
                                    [],
                                    Dtd,
                                    Relaxed_entities
                                ),
                                fun(_use0@2) ->
                                    {Children, Rest@2} = _use0@2,
                                    {ok,
                                        {{element, Name, Attributes, Children},
                                            Rest@2}}
                                end
                            )
                    end
                end
            )
        end
    ).

-file("src/glexml.gleam", 649).
?DOC(
    " Combine two DTDs. Where both declare the same name the `preferred` DTD\n"
    " wins, matching the XML rule that the first declaration of an entity is\n"
    " binding. Use this to merge a document's internal subset with an external\n"
    " DTD: `merge_dtds(doctype.declarations, external)`.\n"
    "\n"
    " One exception to preference: when the preferred DTD declares an entity\n"
    " as an external parsed entity (whose content this library cannot fetch)\n"
    " and the other DTD supplies an `InternalEntity` under the same name, the\n"
    " supplied content is used. This is how callers provide the content of\n"
    " external entities: load the file yourself and pass it as an\n"
    " `InternalEntity` in the DTD given to `parse_with_dtd`.\n"
).
-spec merge_dtds(dtd(), dtd()) -> dtd().
merge_dtds(Preferred, Other) ->
    Entities = begin
        _pipe = maps:merge(
            erlang:element(4, Other),
            erlang:element(4, Preferred)
        ),
        gleam@dict:map_values(_pipe, fun(Name, Entity) -> case Entity of
                    {external_entity, _, none, _} ->
                        case gleam_stdlib:map_get(
                            erlang:element(4, Other),
                            Name
                        ) of
                            {ok, {internal_entity, Replacement}} ->
                                {internal_entity, Replacement};

                            _ ->
                                Entity
                        end;

                    _ ->
                        Entity
                end end)
    end,
    Attribute_lists = gleam@dict:fold(
        erlang:element(3, Other),
        erlang:element(3, Preferred),
        fun(Merged, Element, Other_declarations) ->
            Preferred_declarations = begin
                _pipe@1 = gleam_stdlib:map_get(
                    erlang:element(3, Preferred),
                    Element
                ),
                gleam@result:unwrap(_pipe@1, [])
            end,
            Additional = gleam@list:filter(
                Other_declarations,
                fun(Declaration) ->
                    not gleam@list:any(
                        Preferred_declarations,
                        fun(D) ->
                            erlang:element(2, D) =:= erlang:element(
                                2,
                                Declaration
                            )
                        end
                    )
                end
            ),
            gleam@dict:insert(
                Merged,
                Element,
                lists:append(Preferred_declarations, Additional)
            )
        end
    ),
    {dtd,
        maps:merge(erlang:element(2, Other), erlang:element(2, Preferred)),
        Attribute_lists,
        Entities,
        maps:merge(erlang:element(5, Other), erlang:element(5, Preferred)),
        begin
            _pipe@2 = lists:append(
                erlang:element(6, Preferred),
                erlang:element(6, Other)
            ),
            gleam@list:unique(_pipe@2)
        end,
        begin
            _pipe@3 = lists:append(
                erlang:element(7, Preferred),
                erlang:element(7, Other)
            ),
            gleam@list:unique(_pipe@3)
        end,
        begin
            _pipe@4 = lists:append(
                erlang:element(8, Preferred),
                erlang:element(8, Other)
            ),
            gleam@list:unique(_pipe@4)
        end}.

-file("src/glexml.gleam", 1452).
?DOC(
    " Error positions inside parameter entity replacements are reported at\n"
    " the position of the reference in the outermost input.\n"
).
-spec dtd_position(dtd_input()) -> integer().
dtd_position(Input) ->
    case erlang:element(6, Input) of
        none ->
            erlang:byte_size(erlang:element(2, Input));

        {some, Parent} ->
            dtd_position(Parent)
    end.

-file("src/glexml.gleam", 1446).
-spec advance(dtd_input(), bitstring()) -> dtd_input().
advance(Input, Rest) ->
    {dtd_input,
        Rest,
        erlang:element(3, Input),
        erlang:element(4, Input),
        erlang:element(5, Input),
        erlang:element(6, Input)}.

-file("src/glexml.gleam", 1484).
-spec record_nesting_violation(dtd_state(), binary()) -> dtd_state().
record_nesting_violation(State, Description) ->
    Dtd = erlang:element(2, State),
    {dtd_state,
        {dtd,
            erlang:element(2, Dtd),
            erlang:element(3, Dtd),
            erlang:element(4, Dtd),
            erlang:element(5, Dtd),
            erlang:element(6, Dtd),
            erlang:element(7, Dtd),
            [Description | erlang:element(8, Dtd)]},
        erlang:element(3, State),
        erlang:element(4, State),
        erlang:element(5, State),
        erlang:element(6, State)}.

-file("src/glexml.gleam", 1500).
?DOC(
    " When a construct opens in one entity and closes in another, record a\n"
    " violation of the Proper Declaration/Group/Conditional Section PE\n"
    " Nesting validity constraints. (The well-formedness case — a between-\n"
    " declarations parameter entity whose replacement is not complete\n"
    " declarations — is caught when its segment is popped mid-construct.)\n"
).
-spec check_same_segment(dtd_input(), dtd_state(), integer(), binary()) -> {ok,
        dtd_state()} |
    {error, {error_kind(), integer()}}.
check_same_segment(Input, State, Opened_in, What) ->
    case erlang:element(4, Input) =:= Opened_in of
        true ->
            {ok, State};

        false ->
            {ok,
                record_nesting_violation(
                    State,
                    <<What/binary,
                        " does not start and end in the same entity"/utf8>>
                )}
    end.

-file("src/glexml.gleam", 1462).
?DOC(
    " Whether parameter entity references may be expanded here: anywhere in\n"
    " an external subset, and inside parameter entity replacement text, but\n"
    " not within markup declarations written directly in the internal subset.\n"
).
-spec may_expand_here(dtd_input(), dtd_state()) -> boolean().
may_expand_here(Input, State) ->
    erlang:element(3, State) orelse gleam@option:is_some(
        erlang:element(6, Input)
    ).

-file("src/glexml.gleam", 1536).
-spec do_skip_dtd_space(dtd_input(), dtd_state(), boolean(), boolean()) -> {ok,
        {dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
do_skip_dtd_space(Input, State, Expand, At_declaration_separator) ->
    Input@1 = advance(Input, skip_whitespace(erlang:element(2, Input))),
    case {erlang:element(2, Input@1), erlang:element(6, Input@1)} of
        {<<>>, {some, Parent}} ->
            case erlang:element(5, Input@1) andalso not At_declaration_separator of
                true ->
                    {error, {malformed_doctype, dtd_position(Input@1)}};

                false ->
                    do_skip_dtd_space(
                        Parent,
                        State,
                        Expand,
                        At_declaration_separator
                    )
            end;

        {<<"%"/utf8, Rest/binary>>, _} ->
            case Expand of
                false ->
                    {ok, {Input@1, State}};

                true ->
                    case parse_reference_name(Rest) of
                        {error, {Kind, _}} ->
                            {error, {Kind, dtd_position(Input@1)}};

                        {ok, {Name, Rest@1}} ->
                            case gleam_stdlib:map_get(
                                erlang:element(5, erlang:element(2, State)),
                                Name
                            ) of
                                {error, nil} ->
                                    {error,
                                        {{unknown_entity, Name},
                                            dtd_position(Input@1)}};

                                {ok, Replacement} ->
                                    Segment = {dtd_input,
                                        gleam_stdlib:identity(Replacement),
                                        {some, Name},
                                        erlang:element(4, State),
                                        At_declaration_separator,
                                        {some, advance(Input@1, Rest@1)}},
                                    State@1 = {dtd_state,
                                        erlang:element(2, State),
                                        erlang:element(3, State),
                                        erlang:element(4, State) + 1,
                                        true,
                                        erlang:element(6, State)},
                                    do_skip_dtd_space(
                                        Segment,
                                        State@1,
                                        Expand,
                                        At_declaration_separator
                                    )
                            end
                    end
            end;

        {_, _} ->
            {ok, {Input@1, State}}
    end.

-file("src/glexml.gleam", 1519).
?DOC(
    " Skip whitespace, popping exhausted segments, and (where allowed)\n"
    " expanding `%name;` parameter entity references by pushing a segment\n"
    " with their replacement text.\n"
).
-spec skip_dtd_space(dtd_input(), dtd_state(), boolean()) -> {ok,
        {dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
skip_dtd_space(Input, State, Expand) ->
    do_skip_dtd_space(Input, State, Expand, false).

-file("src/glexml.gleam", 1822).
?DOC(
    " Skip DTD whitespace and the closing `>` of a declaration, checking that\n"
    " the declaration ends in the entity it started in.\n"
).
-spec close_declaration(dtd_input(), dtd_state(), integer()) -> {ok,
        {dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
close_declaration(Input, State, Opened_in) ->
    gleam@result:'try'(
        skip_dtd_space(Input, State, may_expand_here(Input, State)),
        fun(_use0) ->
            {Input@1, State@1} = _use0,
            case erlang:element(2, Input@1) of
                <<">"/utf8, Rest/binary>> ->
                    case check_same_segment(
                        Input@1,
                        State@1,
                        Opened_in,
                        <<"a markup declaration"/utf8>>
                    ) of
                        {error, Failure} ->
                            {error, Failure};

                        {ok, State@2} ->
                            {ok, {advance(Input@1, Rest), State@2}}
                    end;

                <<>> ->
                    {error, {unexpected_end_of_input, 0}};

                _ ->
                    {error, {malformed_doctype, dtd_position(Input@1)}}
            end
        end
    ).

-file("src/glexml.gleam", 3371).
?DOC(
    " Scan to the given byte (a quote in every current use), consuming it.\n"
    " Forbidden characters are errors.\n"
).
-spec scan_to_byte(bitstring(), integer(), integer()) -> {ok,
        {integer(), bitstring()}} |
    {error, {error_kind(), integer()}}.
scan_to_byte(Input, Count, Target) ->
    case Input of
        <<16#EF, 16#BF, 16#BE, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<16#EF, 16#BF, 16#BF, _/binary>> ->
            {error, {invalid_character, erlang:byte_size(Input)}};

        <<Byte, Rest/binary>> ->
            case Byte =:= Target of
                true ->
                    {ok, {Count, Rest}};

                false ->
                    case is_forbidden_byte(Byte) of
                        false ->
                            scan_to_byte(Rest, Count + 1, Target);

                        true ->
                            {error,
                                {invalid_character, erlang:byte_size(Input)}}
                    end
            end;

        _ ->
            {error, {unexpected_end_of_input, 0}}
    end.

-file("src/glexml.gleam", 1387).
-spec finish_quoted_literal(bitstring(), integer()) -> {ok,
        {binary(), bitstring()}} |
    {error, {error_kind(), integer()}}.
finish_quoted_literal(Input, Quote) ->
    case scan_to_byte(Input, 0, Quote) of
        {error, Failure} ->
            {error, Failure};

        {ok, {Count, Rest}} ->
            {ok, {take_string(Input, Count), Rest}}
    end.

-file("src/glexml.gleam", 1377).
-spec parse_quoted_literal(bitstring()) -> {ok, {binary(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_quoted_literal(Input) ->
    case Input of
        <<"\""/utf8, Rest/binary>> ->
            finish_quoted_literal(Rest, 34);

        <<"'"/utf8, Rest@1/binary>> ->
            finish_quoted_literal(Rest@1, 39);

        _ ->
            {error, {malformed_doctype, erlang:byte_size(Input)}}
    end.

-file("src/glexml.gleam", 2655).
-spec dtd_quoted_literal(dtd_input()) -> {ok, {binary(), dtd_input()}} |
    {error, {error_kind(), integer()}}.
dtd_quoted_literal(Input) ->
    case parse_quoted_literal(erlang:element(2, Input)) of
        {ok, {Value, Rest}} ->
            {ok, {Value, advance(Input, Rest)}};

        {error, {Kind, _}} ->
            {error, {Kind, dtd_position(Input)}}
    end.

-file("src/glexml.gleam", 1590).
?DOC(
    " Require at least one whitespace character; a segment boundary or a\n"
    " parameter entity reference also separates tokens, exactly as the\n"
    " specification's space padding would.\n"
).
-spec require_dtd_space(dtd_input(), dtd_state(), boolean()) -> {ok,
        {dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
require_dtd_space(Input, State, Expand) ->
    case erlang:element(2, Input) of
        <<" "/utf8, _/binary>> ->
            skip_dtd_space(Input, State, Expand);

        <<"\t"/utf8, _/binary>> ->
            skip_dtd_space(Input, State, Expand);

        <<"\n"/utf8, _/binary>> ->
            skip_dtd_space(Input, State, Expand);

        <<>> ->
            case erlang:element(6, Input) of
                {some, _} ->
                    skip_dtd_space(Input, State, Expand);

                none ->
                    {error, {missing_whitespace, dtd_position(Input)}}
            end;

        <<"%"/utf8, _/binary>> ->
            case Expand of
                true ->
                    skip_dtd_space(Input, State, Expand);

                false ->
                    {error, {missing_whitespace, dtd_position(Input)}}
            end;

        _ ->
            {error, {missing_whitespace, dtd_position(Input)}}
    end.

-file("src/glexml.gleam", 1361).
?DOC(
    " The PubidChar production: public identifiers use a restricted character\n"
    " set.\n"
).
-spec is_valid_public_id(binary()) -> boolean().
is_valid_public_id(Public) ->
    _pipe = gleam@string:to_utf_codepoints(Public),
    gleam@list:all(
        _pipe,
        fun(Codepoint) ->
            Code = gleam_stdlib:identity(Codepoint),
            (((((Code =:= 16#20) orelse (Code =:= 16#A)) orelse ((Code >= 16#61)
            andalso (Code =< 16#7A)))
            orelse ((Code >= 16#41) andalso (Code =< 16#5A)))
            orelse ((Code >= 16#30) andalso (Code =< 16#39)))
            orelse gleam_stdlib:contains_string(
                <<"-'()+,./:=?;!*#@$_%"/utf8>>,
                gleam_stdlib:utf_codepoint_list_to_string([Codepoint])
            )
        end
    ).

-file("src/glexml.gleam", 2605).
?DOC(
    " Parse a SYSTEM or PUBLIC identifier within a DTD declaration. Keywords\n"
    " and literals are tokens, so they lie within one entity; the whitespace\n"
    " between them may cross entity boundaries.\n"
).
-spec parse_external_id_in_dtd(dtd_input(), dtd_state(), boolean()) -> {ok,
        {external_id(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_external_id_in_dtd(Input, State, Require_system) ->
    case erlang:element(2, Input) of
        <<"SYSTEM"/utf8, Rest/binary>> ->
            gleam@result:'try'(
                require_dtd_space(
                    advance(Input, Rest),
                    State,
                    may_expand_here(Input, State)
                ),
                fun(_use0) ->
                    {Input@1, State@1} = _use0,
                    gleam@result:'try'(
                        dtd_quoted_literal(Input@1),
                        fun(_use0@1) ->
                            {System, Input@2} = _use0@1,
                            {ok, {{system, System}, Input@2, State@1}}
                        end
                    )
                end
            );

        <<"PUBLIC"/utf8, Rest@1/binary>> ->
            gleam@result:'try'(
                require_dtd_space(
                    advance(Input, Rest@1),
                    State,
                    may_expand_here(Input, State)
                ),
                fun(_use0@2) ->
                    {Input@3, State@2} = _use0@2,
                    gleam@result:'try'(
                        dtd_quoted_literal(Input@3),
                        fun(_use0@3) ->
                            {Public, Input@4} = _use0@3,
                            require(
                                is_valid_public_id(Public),
                                {malformed_doctype, dtd_position(Input@4)},
                                fun() -> case Require_system of
                                        true ->
                                            gleam@result:'try'(
                                                require_dtd_space(
                                                    Input@4,
                                                    State@2,
                                                    may_expand_here(
                                                        Input@4,
                                                        State@2
                                                    )
                                                ),
                                                fun(_use0@4) ->
                                                    {Input@5, State@3} = _use0@4,
                                                    gleam@result:'try'(
                                                        dtd_quoted_literal(
                                                            Input@5
                                                        ),
                                                        fun(_use0@5) ->
                                                            {System@1, Input@6} = _use0@5,
                                                            {ok,
                                                                {{public,
                                                                        Public,
                                                                        {some,
                                                                            System@1}},
                                                                    Input@6,
                                                                    State@3}}
                                                        end
                                                    )
                                                end
                                            );

                                        false ->
                                            After_public = advance(
                                                Input@4,
                                                skip_whitespace(
                                                    erlang:element(2, Input@4)
                                                )
                                            ),
                                            case dtd_quoted_literal(
                                                After_public
                                            ) of
                                                {ok, {System@2, Input@7}} ->
                                                    {ok,
                                                        {{public,
                                                                Public,
                                                                {some, System@2}},
                                                            Input@7,
                                                            State@2}};

                                                {error, _} ->
                                                    {ok,
                                                        {{public, Public, none},
                                                            Input@4,
                                                            State@2}}
                                            end
                                    end end
                            )
                        end
                    )
                end
            );

        _ ->
            {error, {malformed_doctype, dtd_position(Input)}}
    end.

-file("src/glexml.gleam", 2664).
?DOC(
    " Parse a name from the current segment, with error positions mapped to\n"
    " the outermost input.\n"
).
-spec dtd_name(dtd_input()) -> {ok, {binary(), bitstring()}} |
    {error, {error_kind(), integer()}}.
dtd_name(Input) ->
    case parse_name(erlang:element(2, Input)) of
        {ok, Pair} ->
            {ok, Pair};

        {error, {Kind, _}} ->
            {error, {Kind, dtd_position(Input)}}
    end.

-file("src/glexml.gleam", 2571).
-spec parse_notation_declaration(dtd_input(), dtd_state(), integer()) -> {ok,
        {dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_notation_declaration(Input, State, Opened_in) ->
    gleam@result:'try'(
        require_dtd_space(Input, State, may_expand_here(Input, State)),
        fun(_use0) ->
            {Input@1, State@1} = _use0,
            gleam@result:'try'(
                dtd_name(Input@1),
                fun(_use0@1) ->
                    {Name, Rest} = _use0@1,
                    Input@2 = advance(Input@1, Rest),
                    gleam@result:'try'(
                        require_dtd_space(
                            Input@2,
                            State@1,
                            may_expand_here(Input@2, State@1)
                        ),
                        fun(_use0@2) ->
                            {Input@3, State@2} = _use0@2,
                            gleam@result:'try'(
                                parse_external_id_in_dtd(
                                    Input@3,
                                    State@2,
                                    false
                                ),
                                fun(_use0@3) ->
                                    {_, Input@4, State@3} = _use0@3,
                                    gleam@result:'try'(
                                        close_declaration(
                                            Input@4,
                                            State@3,
                                            Opened_in
                                        ),
                                        fun(_use0@4) ->
                                            {Input@5, State@4} = _use0@4,
                                            Dtd = erlang:element(2, State@4),
                                            Dtd@1 = case gleam@list:contains(
                                                erlang:element(6, Dtd),
                                                Name
                                            ) of
                                                true ->
                                                    Dtd;

                                                false ->
                                                    {dtd,
                                                        erlang:element(2, Dtd),
                                                        erlang:element(3, Dtd),
                                                        erlang:element(4, Dtd),
                                                        erlang:element(5, Dtd),
                                                        [Name |
                                                            erlang:element(
                                                                6,
                                                                Dtd
                                                            )],
                                                        erlang:element(7, Dtd),
                                                        erlang:element(8, Dtd)}
                                            end,
                                            {ok,
                                                {Input@5,
                                                    {dtd_state,
                                                        Dtd@1,
                                                        erlang:element(
                                                            3,
                                                            State@4
                                                        ),
                                                        erlang:element(
                                                            4,
                                                            State@4
                                                        ),
                                                        erlang:element(
                                                            5,
                                                            State@4
                                                        ),
                                                        erlang:element(
                                                            6,
                                                            State@4
                                                        )}}}
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/glexml.gleam", 2550).
?DOC(
    " Parse a quoted attribute default value, decoding references the same way\n"
    " attribute values in documents are decoded. The literal must close within\n"
    " the entity it opened in.\n"
).
-spec parse_default_value(dtd_input(), dtd_state()) -> {ok,
        {binary(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_default_value(Input, State) ->
    gleam@result:'try'(case erlang:element(2, Input) of
            <<"\""/utf8, Rest/binary>> ->
                {ok, {34, advance(Input, Rest)}};

            <<"'"/utf8, Rest@1/binary>> ->
                {ok, {39, advance(Input, Rest@1)}};

            _ ->
                {error, {malformed_doctype, dtd_position(Input)}}
        end, fun(_use0) ->
            {Quote, Input@1} = _use0,
            case scan_attribute_value(erlang:element(2, Input@1), 0, Quote) of
                {error, {Kind, _}} ->
                    {error, {Kind, dtd_position(Input@1)}};

                {ok, {Count, Rest@2}} ->
                    case decode_attribute_text(
                        take_string(erlang:element(2, Input@1), Count),
                        erlang:element(2, State),
                        []
                    ) of
                        {ok, Value} ->
                            {ok, {Value, advance(Input@1, Rest@2), State}};

                        {error, Kind@1} ->
                            {error, {Kind@1, dtd_position(Input@1)}}
                    end
            end
        end).

-file("src/glexml.gleam", 2522).
-spec parse_attribute_default(dtd_input(), dtd_state()) -> {ok,
        {attribute_default(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_attribute_default(Input, State) ->
    case erlang:element(2, Input) of
        <<"#REQUIRED"/utf8, Rest/binary>> ->
            {ok, {required, advance(Input, Rest), State}};

        <<"#IMPLIED"/utf8, Rest@1/binary>> ->
            {ok, {implied, advance(Input, Rest@1), State}};

        <<"#FIXED"/utf8, Rest@2/binary>> ->
            gleam@result:'try'(
                require_dtd_space(
                    advance(Input, Rest@2),
                    State,
                    may_expand_here(Input, State)
                ),
                fun(_use0) ->
                    {Input@1, State@1} = _use0,
                    gleam@result:'try'(
                        parse_default_value(Input@1, State@1),
                        fun(_use0@1) ->
                            {Value, Input@2, State@2} = _use0@1,
                            {ok, {{fixed, Value}, Input@2, State@2}}
                        end
                    )
                end
            );

        _ ->
            gleam@result:'try'(
                parse_default_value(Input, State),
                fun(_use0@2) ->
                    {Value@1, Input@3, State@3} = _use0@2,
                    {ok, {{default, Value@1}, Input@3, State@3}}
                end
            )
    end.

-file("src/glexml.gleam", 3230).
?DOC(
    " Parse a name token (`Nmtoken`): like a name, but without the restriction\n"
    " on the first character, so `007` is a valid name token.\n"
).
-spec parse_nmtoken(bitstring()) -> {ok, {binary(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_nmtoken(Input) ->
    case scan_name(Input, 0) of
        {0, <<>>} ->
            {error, {unexpected_end_of_input, 0}};

        {0, Rest} ->
            {error, {invalid_name, erlang:byte_size(Rest)}};

        {Count, Rest@1} ->
            Token = take_string(Input, Count),
            Valid = begin
                _pipe = gleam@string:to_utf_codepoints(Token),
                gleam@list:all(
                    _pipe,
                    fun(Codepoint) ->
                        is_name_character(gleam_stdlib:identity(Codepoint))
                    end
                )
            end,
            case Valid of
                true ->
                    {ok, {Token, Rest@1}};

                false ->
                    {error, {invalid_name, erlang:byte_size(Input)}}
            end
    end.

-file("src/glexml.gleam", 2481).
-spec parse_name_enumeration(
    dtd_input(),
    dtd_state(),
    list(binary()),
    integer()
) -> {ok, {list(binary()), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_name_enumeration(Input, State, Names, Opened_in) ->
    gleam@result:'try'(
        skip_dtd_space(Input, State, may_expand_here(Input, State)),
        fun(_use0) ->
            {Input@1, State@1} = _use0,
            gleam@result:'try'(case parse_nmtoken(erlang:element(2, Input@1)) of
                    {ok, Pair} ->
                        {ok, Pair};

                    {error, {Kind, _}} ->
                        {error, {Kind, dtd_position(Input@1)}}
                end, fun(_use0@1) ->
                    {Name, Rest} = _use0@1,
                    Input@2 = advance(Input@1, Rest),
                    gleam@result:'try'(
                        skip_dtd_space(
                            Input@2,
                            State@1,
                            may_expand_here(Input@2, State@1)
                        ),
                        fun(_use0@2) ->
                            {Input@3, State@2} = _use0@2,
                            case erlang:element(2, Input@3) of
                                <<")"/utf8, Rest@1/binary>> ->
                                    case check_same_segment(
                                        Input@3,
                                        State@2,
                                        Opened_in,
                                        <<"an enumeration"/utf8>>
                                    ) of
                                        {error, Failure} ->
                                            {error, Failure};

                                        {ok, State@3} ->
                                            {ok,
                                                {lists:reverse([Name | Names]),
                                                    advance(Input@3, Rest@1),
                                                    State@3}}
                                    end;

                                <<"|"/utf8, Rest@2/binary>> ->
                                    parse_name_enumeration(
                                        advance(Input@3, Rest@2),
                                        State@2,
                                        [Name | Names],
                                        Opened_in
                                    );

                                <<>> ->
                                    {error, {unexpected_end_of_input, 0}};

                                _ ->
                                    {error,
                                        {malformed_doctype,
                                            dtd_position(Input@3)}}
                            end
                        end
                    )
                end)
        end
    ).

-file("src/glexml.gleam", 2426).
-spec parse_attribute_kind(dtd_input(), dtd_state()) -> {ok,
        {attribute_kind(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_attribute_kind(Input, State) ->
    case erlang:element(2, Input) of
        <<"CDATA"/utf8, Rest/binary>> ->
            {ok, {cdata_attribute, advance(Input, Rest), State}};

        <<"IDREFS"/utf8, Rest@1/binary>> ->
            {ok, {id_refs_attribute, advance(Input, Rest@1), State}};

        <<"IDREF"/utf8, Rest@2/binary>> ->
            {ok, {id_ref_attribute, advance(Input, Rest@2), State}};

        <<"ID"/utf8, Rest@3/binary>> ->
            {ok, {id_attribute, advance(Input, Rest@3), State}};

        <<"ENTITIES"/utf8, Rest@4/binary>> ->
            {ok, {entities_attribute, advance(Input, Rest@4), State}};

        <<"ENTITY"/utf8, Rest@5/binary>> ->
            {ok, {entity_attribute, advance(Input, Rest@5), State}};

        <<"NMTOKENS"/utf8, Rest@6/binary>> ->
            {ok, {nmtokens_attribute, advance(Input, Rest@6), State}};

        <<"NMTOKEN"/utf8, Rest@7/binary>> ->
            {ok, {nmtoken_attribute, advance(Input, Rest@7), State}};

        <<"NOTATION"/utf8, Rest@8/binary>> ->
            gleam@result:'try'(
                require_dtd_space(
                    advance(Input, Rest@8),
                    State,
                    may_expand_here(Input, State)
                ),
                fun(_use0) ->
                    {Input@1, State@1} = _use0,
                    case erlang:element(2, Input@1) of
                        <<"("/utf8, Rest@9/binary>> ->
                            Opened_in = erlang:element(4, Input@1),
                            gleam@result:'try'(
                                parse_name_enumeration(
                                    advance(Input@1, Rest@9),
                                    State@1,
                                    [],
                                    Opened_in
                                ),
                                fun(_use0@1) ->
                                    {Names, Input@2, State@2} = _use0@1,
                                    {ok,
                                        {{notation_attribute, Names},
                                            Input@2,
                                            State@2}}
                                end
                            );

                        _ ->
                            {error, {malformed_doctype, dtd_position(Input@1)}}
                    end
                end
            );

        <<"("/utf8, Rest@10/binary>> ->
            Opened_in@1 = erlang:element(4, Input),
            gleam@result:'try'(
                parse_name_enumeration(
                    advance(Input, Rest@10),
                    State,
                    [],
                    Opened_in@1
                ),
                fun(_use0@2) ->
                    {Names@1, Input@3, State@3} = _use0@2,
                    {ok, {{enumerated_attribute, Names@1}, Input@3, State@3}}
                end
            );

        <<>> ->
            {error, {unexpected_end_of_input, 0}};

        _ ->
            {error, {malformed_doctype, dtd_position(Input)}}
    end.

-file("src/glexml.gleam", 2402).
-spec parse_attlist_attribute(dtd_input(), dtd_state()) -> {ok,
        {attribute_declaration(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_attlist_attribute(Input, State) ->
    gleam@result:'try'(
        dtd_name(Input),
        fun(_use0) ->
            {Name, Rest} = _use0,
            Input@1 = advance(Input, Rest),
            gleam@result:'try'(
                require_dtd_space(
                    Input@1,
                    State,
                    may_expand_here(Input@1, State)
                ),
                fun(_use0@1) ->
                    {Input@2, State@1} = _use0@1,
                    gleam@result:'try'(
                        parse_attribute_kind(Input@2, State@1),
                        fun(_use0@2) ->
                            {Kind, Input@3, State@2} = _use0@2,
                            gleam@result:'try'(
                                require_dtd_space(
                                    Input@3,
                                    State@2,
                                    may_expand_here(Input@3, State@2)
                                ),
                                fun(_use0@3) ->
                                    {Input@4, State@3} = _use0@3,
                                    gleam@result:'try'(
                                        parse_attribute_default(
                                            Input@4,
                                            State@3
                                        ),
                                        fun(_use0@4) ->
                                            {Default, Input@5, State@4} = _use0@4,
                                            {ok,
                                                {{attribute_declaration,
                                                        Name,
                                                        Kind,
                                                        Default},
                                                    Input@5,
                                                    State@4}}
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/glexml.gleam", 2338).
-spec parse_attlist_attributes(
    dtd_input(),
    dtd_state(),
    binary(),
    list(attribute_declaration()),
    integer()
) -> {ok, {dtd_input(), dtd_state()}} | {error, {error_kind(), integer()}}.
parse_attlist_attributes(Input, State, Element, Declared, Opened_in) ->
    Space = case erlang:element(2, Input) of
        <<">"/utf8, _/binary>> ->
            {ok, {Input, State}};

        _ ->
            require_dtd_space(Input, State, may_expand_here(Input, State))
    end,
    case Space of
        {error, Failure} ->
            {error, Failure};

        {ok, {Input@1, State@1}} ->
            case erlang:element(2, Input@1) of
                <<>> ->
                    {error, {unexpected_end_of_input, 0}};

                <<">"/utf8, Rest/binary>> ->
                    case check_same_segment(
                        Input@1,
                        State@1,
                        Opened_in,
                        <<"a markup declaration"/utf8>>
                    ) of
                        {error, Failure@1} ->
                            {error, Failure@1};

                        {ok, State@2} ->
                            Dtd = erlang:element(2, State@2),
                            Existing = begin
                                _pipe = gleam_stdlib:map_get(
                                    erlang:element(3, Dtd),
                                    Element
                                ),
                                gleam@result:unwrap(_pipe, [])
                            end,
                            New = gleam@list:filter(
                                lists:reverse(Declared),
                                fun(Declaration) ->
                                    not gleam@list:any(
                                        Existing,
                                        fun(Existing@1) ->
                                            erlang:element(2, Existing@1) =:= erlang:element(
                                                2,
                                                Declaration
                                            )
                                        end
                                    )
                                end
                            ),
                            Dtd@1 = {dtd,
                                erlang:element(2, Dtd),
                                gleam@dict:insert(
                                    erlang:element(3, Dtd),
                                    Element,
                                    lists:append(Existing, New)
                                ),
                                erlang:element(4, Dtd),
                                erlang:element(5, Dtd),
                                erlang:element(6, Dtd),
                                erlang:element(7, Dtd),
                                erlang:element(8, Dtd)},
                            {ok,
                                {advance(Input@1, Rest),
                                    {dtd_state,
                                        Dtd@1,
                                        erlang:element(3, State@2),
                                        erlang:element(4, State@2),
                                        erlang:element(5, State@2),
                                        erlang:element(6, State@2)}}}
                    end;

                _ ->
                    case parse_attlist_attribute(Input@1, State@1) of
                        {ok, {Declaration@1, Input@2, State@3}} ->
                            parse_attlist_attributes(
                                Input@2,
                                State@3,
                                Element,
                                [Declaration@1 | Declared],
                                Opened_in
                            );

                        {error, Failure@2} ->
                            {error, Failure@2}
                    end
            end
    end.

-file("src/glexml.gleam", 2324).
-spec parse_attlist_declaration(dtd_input(), dtd_state(), integer()) -> {ok,
        {dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_attlist_declaration(Input, State, Opened_in) ->
    gleam@result:'try'(
        require_dtd_space(Input, State, may_expand_here(Input, State)),
        fun(_use0) ->
            {Input@1, State@1} = _use0,
            gleam@result:'try'(
                dtd_name(Input@1),
                fun(_use0@1) ->
                    {Element, Rest} = _use0@1,
                    parse_attlist_attributes(
                        advance(Input@1, Rest),
                        State@1,
                        Element,
                        [],
                        Opened_in
                    )
                end
            )
        end
    ).

-file("src/glexml.gleam", 2315).
-spec parse_occurrence(bitstring()) -> {occurrence(), bitstring()}.
parse_occurrence(Input) ->
    case Input of
        <<"?"/utf8, Rest/binary>> ->
            {zero_or_one, Rest};

        <<"*"/utf8, Rest@1/binary>> ->
            {zero_or_more, Rest@1};

        <<"+"/utf8, Rest@2/binary>> ->
            {one_or_more, Rest@2};

        _ ->
            {exactly_one, Input}
    end.

-file("src/glexml.gleam", 2293).
-spec parse_particle(dtd_input(), dtd_state()) -> {ok,
        {particle(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_particle(Input, State) ->
    case erlang:element(2, Input) of
        <<"("/utf8, Rest/binary>> ->
            Opened_in = erlang:element(4, Input),
            gleam@result:'try'(
                skip_dtd_space(
                    advance(Input, Rest),
                    State,
                    may_expand_here(Input, State)
                ),
                fun(_use0) ->
                    {Input@1, State@1} = _use0,
                    parse_group(Input@1, State@1, Opened_in)
                end
            );

        _ ->
            gleam@result:'try'(
                dtd_name(Input),
                fun(_use0@1) ->
                    {Name, Rest@1} = _use0@1,
                    {Occurrence, Rest@2} = parse_occurrence(Rest@1),
                    {ok,
                        {{name_particle, Name, Occurrence},
                            advance(Input, Rest@2),
                            State}}
                end
            )
    end.

-file("src/glexml.gleam", 2216).
-spec parse_group_items(
    dtd_input(),
    dtd_state(),
    list(particle()),
    group_separator(),
    integer()
) -> {ok, {particle(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_group_items(Input, State, Particles, Separator, Opened_in) ->
    gleam@result:'try'(
        skip_dtd_space(Input, State, may_expand_here(Input, State)),
        fun(_use0) ->
            {Input@1, State@1} = _use0,
            case erlang:element(2, Input@1) of
                <<")"/utf8, Rest/binary>> ->
                    case check_same_segment(
                        Input@1,
                        State@1,
                        Opened_in,
                        <<"a content model group"/utf8>>
                    ) of
                        {error, Failure} ->
                            {error, Failure};

                        {ok, State@2} ->
                            {Occurrence, Rest@1} = parse_occurrence(Rest),
                            Particles@1 = lists:reverse(Particles),
                            Particle = case Separator of
                                choice_separator ->
                                    {choice, Particles@1, Occurrence};

                                _ ->
                                    {sequence, Particles@1, Occurrence}
                            end,
                            {ok, {Particle, advance(Input@1, Rest@1), State@2}}
                    end;

                <<"|"/utf8, Rest@2/binary>> ->
                    case Separator of
                        sequence_separator ->
                            {error, {malformed_doctype, dtd_position(Input@1)}};

                        _ ->
                            gleam@result:'try'(
                                skip_dtd_space(
                                    advance(Input@1, Rest@2),
                                    State@1,
                                    may_expand_here(Input@1, State@1)
                                ),
                                fun(_use0@1) ->
                                    {Input@2, State@3} = _use0@1,
                                    gleam@result:'try'(
                                        parse_particle(Input@2, State@3),
                                        fun(_use0@2) ->
                                            {Particle@1, Input@3, State@4} = _use0@2,
                                            parse_group_items(
                                                Input@3,
                                                State@4,
                                                [Particle@1 | Particles],
                                                choice_separator,
                                                Opened_in
                                            )
                                        end
                                    )
                                end
                            )
                    end;

                <<","/utf8, Rest@3/binary>> ->
                    case Separator of
                        choice_separator ->
                            {error, {malformed_doctype, dtd_position(Input@1)}};

                        _ ->
                            gleam@result:'try'(
                                skip_dtd_space(
                                    advance(Input@1, Rest@3),
                                    State@1,
                                    may_expand_here(Input@1, State@1)
                                ),
                                fun(_use0@3) ->
                                    {Input@4, State@5} = _use0@3,
                                    gleam@result:'try'(
                                        parse_particle(Input@4, State@5),
                                        fun(_use0@4) ->
                                            {Particle@2, Input@5, State@6} = _use0@4,
                                            parse_group_items(
                                                Input@5,
                                                State@6,
                                                [Particle@2 | Particles],
                                                sequence_separator,
                                                Opened_in
                                            )
                                        end
                                    )
                                end
                            )
                    end;

                <<>> ->
                    {error, {unexpected_end_of_input, 0}};

                _ ->
                    {error, {malformed_doctype, dtd_position(Input@1)}}
            end
        end
    ).

-file("src/glexml.gleam", 2207).
?DOC(
    " Parse a `(a, b)` or `(a | b)` group body. The input begins after the\n"
    " opening `(`, whose segment id is given so the closing parenthesis can\n"
    " be checked against it.\n"
).
-spec parse_group(dtd_input(), dtd_state(), integer()) -> {ok,
        {particle(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_group(Input, State, Opened_in) ->
    gleam@result:'try'(
        parse_particle(Input, State),
        fun(_use0) ->
            {First, Input@1, State@1} = _use0,
            parse_group_items(
                Input@1,
                State@1,
                [First],
                undecided_separator,
                Opened_in
            )
        end
    ).

-file("src/glexml.gleam", 2147).
?DOC(
    " Parse the rest of a `(#PCDATA | a | b)*` mixed content model, after the\n"
    " `#PCDATA`. The closing parenthesis must be in the same entity as the\n"
    " opening one.\n"
).
-spec parse_mixed_content(dtd_input(), dtd_state(), list(binary()), integer()) -> {ok,
        {content_model(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_mixed_content(Input, State, Names, Opened_in) ->
    gleam@result:'try'(
        skip_dtd_space(Input, State, may_expand_here(Input, State)),
        fun(_use0) ->
            {Input@1, State@1} = _use0,
            case erlang:element(2, Input@1) of
                <<")*"/utf8, Rest/binary>> ->
                    case check_same_segment(
                        Input@1,
                        State@1,
                        Opened_in,
                        <<"a content model group"/utf8>>
                    ) of
                        {error, Failure} ->
                            {error, Failure};

                        {ok, State@2} ->
                            {ok,
                                {{mixed_content, lists:reverse(Names)},
                                    advance(Input@1, Rest),
                                    State@2}}
                    end;

                <<")"/utf8, Rest@1/binary>> ->
                    case Names of
                        [] ->
                            case check_same_segment(
                                Input@1,
                                State@1,
                                Opened_in,
                                <<"a content model group"/utf8>>
                            ) of
                                {error, Failure@1} ->
                                    {error, Failure@1};

                                {ok, State@3} ->
                                    {ok,
                                        {{mixed_content, []},
                                            advance(Input@1, Rest@1),
                                            State@3}}
                            end;

                        _ ->
                            {error, {malformed_doctype, dtd_position(Input@1)}}
                    end;

                <<"|"/utf8, Rest@2/binary>> ->
                    gleam@result:'try'(
                        skip_dtd_space(
                            advance(Input@1, Rest@2),
                            State@1,
                            may_expand_here(Input@1, State@1)
                        ),
                        fun(_use0@1) ->
                            {Input@2, State@4} = _use0@1,
                            gleam@result:'try'(
                                dtd_name(Input@2),
                                fun(_use0@2) ->
                                    {Name, Rest@3} = _use0@2,
                                    parse_mixed_content(
                                        advance(Input@2, Rest@3),
                                        State@4,
                                        [Name | Names],
                                        Opened_in
                                    )
                                end
                            )
                        end
                    );

                <<>> ->
                    {error, {unexpected_end_of_input, 0}};

                _ ->
                    {error, {malformed_doctype, dtd_position(Input@1)}}
            end
        end
    ).

-file("src/glexml.gleam", 2112).
-spec parse_content_model(dtd_input(), dtd_state()) -> {ok,
        {content_model(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_content_model(Input, State) ->
    case erlang:element(2, Input) of
        <<"EMPTY"/utf8, Rest/binary>> ->
            {ok, {empty_content, advance(Input, Rest), State}};

        <<"ANY"/utf8, Rest@1/binary>> ->
            {ok, {any_content, advance(Input, Rest@1), State}};

        <<"("/utf8, Rest@2/binary>> ->
            Opened_in = erlang:element(4, Input),
            gleam@result:'try'(
                skip_dtd_space(
                    advance(Input, Rest@2),
                    State,
                    may_expand_here(Input, State)
                ),
                fun(_use0) ->
                    {Input@1, State@1} = _use0,
                    case erlang:element(2, Input@1) of
                        <<"#PCDATA"/utf8, Rest@3/binary>> ->
                            parse_mixed_content(
                                advance(Input@1, Rest@3),
                                State@1,
                                [],
                                Opened_in
                            );

                        _ ->
                            gleam@result:'try'(
                                parse_group(Input@1, State@1, Opened_in),
                                fun(_use0@1) ->
                                    {Particle, Input@2, State@2} = _use0@1,
                                    {ok,
                                        {{element_content, Particle},
                                            Input@2,
                                            State@2}}
                                end
                            )
                    end
                end
            );

        _ ->
            {error, {malformed_doctype, dtd_position(Input)}}
    end.

-file("src/glexml.gleam", 2083).
-spec parse_element_declaration(dtd_input(), dtd_state(), integer()) -> {ok,
        {dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_element_declaration(Input, State, Opened_in) ->
    gleam@result:'try'(
        require_dtd_space(Input, State, may_expand_here(Input, State)),
        fun(_use0) ->
            {Input@1, State@1} = _use0,
            gleam@result:'try'(
                dtd_name(Input@1),
                fun(_use0@1) ->
                    {Name, Rest} = _use0@1,
                    Input@2 = advance(Input@1, Rest),
                    gleam@result:'try'(
                        require_dtd_space(
                            Input@2,
                            State@1,
                            may_expand_here(Input@2, State@1)
                        ),
                        fun(_use0@2) ->
                            {Input@3, State@2} = _use0@2,
                            gleam@result:'try'(
                                parse_content_model(Input@3, State@2),
                                fun(_use0@3) ->
                                    {Model, Input@4, State@3} = _use0@3,
                                    gleam@result:'try'(
                                        close_declaration(
                                            Input@4,
                                            State@3,
                                            Opened_in
                                        ),
                                        fun(_use0@4) ->
                                            {Input@5, State@4} = _use0@4,
                                            Dtd = erlang:element(2, State@4),
                                            Dtd@1 = case gleam@dict:has_key(
                                                erlang:element(2, Dtd),
                                                Name
                                            ) of
                                                true ->
                                                    {dtd,
                                                        erlang:element(2, Dtd),
                                                        erlang:element(3, Dtd),
                                                        erlang:element(4, Dtd),
                                                        erlang:element(5, Dtd),
                                                        erlang:element(6, Dtd),
                                                        [Name |
                                                            erlang:element(
                                                                7,
                                                                Dtd
                                                            )],
                                                        erlang:element(8, Dtd)};

                                                false ->
                                                    {dtd,
                                                        gleam@dict:insert(
                                                            erlang:element(
                                                                2,
                                                                Dtd
                                                            ),
                                                            Name,
                                                            Model
                                                        ),
                                                        erlang:element(3, Dtd),
                                                        erlang:element(4, Dtd),
                                                        erlang:element(5, Dtd),
                                                        erlang:element(6, Dtd),
                                                        erlang:element(7, Dtd),
                                                        erlang:element(8, Dtd)}
                                            end,
                                            {ok,
                                                {Input@5,
                                                    {dtd_state,
                                                        Dtd@1,
                                                        erlang:element(
                                                            3,
                                                            State@4
                                                        ),
                                                        erlang:element(
                                                            4,
                                                            State@4
                                                        ),
                                                        erlang:element(
                                                            5,
                                                            State@4
                                                        ),
                                                        erlang:element(
                                                            6,
                                                            State@4
                                                        )}}}
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/glexml.gleam", 2061).
?DOC(
    " Expand character references in an entity value, keeping general entity\n"
    " references (`&name;`) untouched for later.\n"
).
-spec expand_character_references(binary()) -> {ok, binary()} |
    {error, error_kind()}.
expand_character_references(Text) ->
    case gleam@string:split_once(Text, <<"&"/utf8>>) of
        {error, nil} ->
            {ok, Text};

        {ok, {Before, After}} ->
            case gleam@string:split_once(After, <<";"/utf8>>) of
                {error, nil} ->
                    {error, malformed_entity};

                {ok, {Reference, Rest}} ->
                    gleam@result:'try'(case Reference of
                            <<"#"/utf8, _/binary>> ->
                                resolve_entity(Reference);

                            _ ->
                                case is_valid_name(Reference) of
                                    true ->
                                        {ok,
                                            <<<<"&"/utf8, Reference/binary>>/binary,
                                                ";"/utf8>>};

                                    false ->
                                        {error, malformed_entity}
                                end
                        end, fun(Expanded) ->
                            gleam@result:'try'(
                                expand_character_references(Rest),
                                fun(Rest@1) ->
                                    {ok,
                                        <<<<Before/binary, Expanded/binary>>/binary,
                                            Rest@1/binary>>}
                                end
                            )
                        end)
            end
    end.

-file("src/glexml.gleam", 2027).
-spec expand_parameter_references(binary(), dtd_state(), boolean()) -> {ok,
        binary()} |
    {error, error_kind()}.
expand_parameter_references(Text, State, Allowed) ->
    case gleam@string:split_once(Text, <<"%"/utf8>>) of
        {error, nil} ->
            {ok, Text};

        {ok, {Before, After}} ->
            case Allowed of
                false ->
                    {error, malformed_doctype};

                true ->
                    case gleam@string:split_once(After, <<";"/utf8>>) of
                        {error, nil} ->
                            {error, malformed_entity};

                        {ok, {Name, Rest}} ->
                            case gleam_stdlib:map_get(
                                erlang:element(5, erlang:element(2, State)),
                                Name
                            ) of
                                {error, nil} ->
                                    {error, {unknown_entity, Name}};

                                {ok, Replacement} ->
                                    gleam@result:'try'(
                                        expand_parameter_references(
                                            Rest,
                                            State,
                                            Allowed
                                        ),
                                        fun(Rest@1) ->
                                            {ok,
                                                <<<<Before/binary,
                                                        Replacement/binary>>/binary,
                                                    Rest@1/binary>>}
                                        end
                                    )
                            end
                    end
            end
    end.

-file("src/glexml.gleam", 2006).
?DOC(
    " Parse a quoted entity value, which must close within the entity it\n"
    " opened in. Parameter entity references and character references are\n"
    " expanded now, at declaration time; general entity references are kept\n"
    " for expansion when the entity is used.\n"
).
-spec parse_entity_value(dtd_input(), dtd_state(), integer()) -> {ok,
        {entity(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_entity_value(Input, State, Quote) ->
    case scan_to_byte(erlang:element(2, Input), 0, Quote) of
        {error, {Kind, _}} ->
            {error, {Kind, dtd_position(Input)}};

        {ok, {Count, Rest}} ->
            Processed = begin
                _pipe = take_string(erlang:element(2, Input), Count),
                _pipe@1 = expand_parameter_references(
                    _pipe,
                    State,
                    may_expand_here(Input, State)
                ),
                gleam@result:'try'(_pipe@1, fun expand_character_references/1)
            end,
            case Processed of
                {ok, Replacement} ->
                    {ok,
                        {{internal_entity, Replacement},
                            advance(Input, Rest),
                            State}};

                {error, Kind@1} ->
                    {error, {Kind@1, dtd_position(Input)}}
            end
    end.

-file("src/glexml.gleam", 1956).
-spec parse_entity_definition(
    dtd_input(),
    dtd_state(),
    gleam@option:option(binary())
) -> {ok, {entity(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_entity_definition(Input, State, Declared_in) ->
    case erlang:element(2, Input) of
        <<"\""/utf8, Rest/binary>> ->
            parse_entity_value(advance(Input, Rest), State, 34);

        <<"'"/utf8, Rest@1/binary>> ->
            parse_entity_value(advance(Input, Rest@1), State, 39);

        <<"SYSTEM"/utf8, _/binary>> ->
            gleam@result:'try'(
                parse_external_id_in_dtd(Input, State, true),
                fun(_use0) ->
                    {Id, Input@1, State@1} = _use0,
                    case skip_whitespace(erlang:element(2, Input@1)) of
                        <<"NDATA"/utf8, Ndata_rest/binary>> ->
                            case erlang:byte_size(
                                skip_whitespace(erlang:element(2, Input@1))
                            )
                            < erlang:byte_size(erlang:element(2, Input@1)) of
                                false ->
                                    {error,
                                        {missing_whitespace,
                                            dtd_position(Input@1)}};

                                true ->
                                    Input@2 = advance(Input@1, Ndata_rest),
                                    gleam@result:'try'(
                                        require_dtd_space(
                                            Input@2,
                                            State@1,
                                            may_expand_here(Input@2, State@1)
                                        ),
                                        fun(_use0@1) ->
                                            {Input@3, State@2} = _use0@1,
                                            gleam@result:'try'(
                                                dtd_name(Input@3),
                                                fun(_use0@2) ->
                                                    {Notation, Rest@2} = _use0@2,
                                                    {ok,
                                                        {{external_entity,
                                                                Id,
                                                                {some, Notation},
                                                                Declared_in},
                                                            advance(
                                                                Input@3,
                                                                Rest@2
                                                            ),
                                                            State@2}}
                                                end
                                            )
                                        end
                                    )
                            end;

                        _ ->
                            {ok,
                                {{external_entity, Id, none, Declared_in},
                                    Input@1,
                                    State@1}}
                    end
                end
            );

        <<"PUBLIC"/utf8, _/binary>> ->
            gleam@result:'try'(
                parse_external_id_in_dtd(Input, State, true),
                fun(_use0) ->
                    {Id, Input@1, State@1} = _use0,
                    case skip_whitespace(erlang:element(2, Input@1)) of
                        <<"NDATA"/utf8, Ndata_rest/binary>> ->
                            case erlang:byte_size(
                                skip_whitespace(erlang:element(2, Input@1))
                            )
                            < erlang:byte_size(erlang:element(2, Input@1)) of
                                false ->
                                    {error,
                                        {missing_whitespace,
                                            dtd_position(Input@1)}};

                                true ->
                                    Input@2 = advance(Input@1, Ndata_rest),
                                    gleam@result:'try'(
                                        require_dtd_space(
                                            Input@2,
                                            State@1,
                                            may_expand_here(Input@2, State@1)
                                        ),
                                        fun(_use0@1) ->
                                            {Input@3, State@2} = _use0@1,
                                            gleam@result:'try'(
                                                dtd_name(Input@3),
                                                fun(_use0@2) ->
                                                    {Notation, Rest@2} = _use0@2,
                                                    {ok,
                                                        {{external_entity,
                                                                Id,
                                                                {some, Notation},
                                                                Declared_in},
                                                            advance(
                                                                Input@3,
                                                                Rest@2
                                                            ),
                                                            State@2}}
                                                end
                                            )
                                        end
                                    )
                            end;

                        _ ->
                            {ok,
                                {{external_entity, Id, none, Declared_in},
                                    Input@1,
                                    State@1}}
                    end
                end
            );

        _ ->
            {error, {malformed_doctype, dtd_position(Input)}}
    end.

-file("src/glexml.gleam", 1469).
?DOC(
    " The external parameter entity whose replacement text the parser is\n"
    " currently reading, skipping internally declared parameter entities,\n"
    " whose text belongs to wherever they are referenced.\n"
).
-spec declaring_entity(dtd_input(), dtd_state()) -> gleam@option:option(binary()).
declaring_entity(Input, State) ->
    case erlang:element(3, Input) of
        none ->
            none;

        {some, Name} ->
            case gleam@dict:has_key(erlang:element(6, State), Name) of
                false ->
                    {some, Name};

                true ->
                    case erlang:element(6, Input) of
                        {some, Parent} ->
                            declaring_entity(Parent, State);

                        none ->
                            none
                    end
            end
    end.

-file("src/glexml.gleam", 1845).
?DOC(
    " Parse an `<!ENTITY ...>` declaration. The first declaration of a name is\n"
    " binding; later ones are ignored, as the specification requires.\n"
).
-spec parse_entity_declaration(dtd_input(), dtd_state(), integer()) -> {ok,
        {dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_entity_declaration(Input, State, Opened_in) ->
    Declared_in = declaring_entity(Input, State),
    gleam@result:'try'(
        require_dtd_space(Input, State, false),
        fun(_use0) ->
            {Input@1, State@1} = _use0,
            case erlang:element(2, Input@1) of
                <<"% "/utf8, Rest/binary>> ->
                    gleam@result:'try'(
                        skip_dtd_space(advance(Input@1, Rest), State@1, false),
                        fun(_use0@1) ->
                            {Input@2, State@2} = _use0@1,
                            gleam@result:'try'(
                                dtd_name(Input@2),
                                fun(_use0@2) ->
                                    {Name, Rest@1} = _use0@2,
                                    Input@3 = advance(Input@2, Rest@1),
                                    gleam@result:'try'(
                                        require_dtd_space(
                                            Input@3,
                                            State@2,
                                            may_expand_here(Input@3, State@2)
                                        ),
                                        fun(_use0@3) ->
                                            {Input@4, State@3} = _use0@3,
                                            gleam@result:'try'(
                                                parse_entity_definition(
                                                    Input@4,
                                                    State@3,
                                                    Declared_in
                                                ),
                                                fun(_use0@4) ->
                                                    {Entity, Input@5, State@4} = _use0@4,
                                                    require(case Entity of
                                                            {external_entity,
                                                                _,
                                                                {some, _},
                                                                _} ->
                                                                false;

                                                            _ ->
                                                                true
                                                        end, {malformed_doctype,
                                                            dtd_position(
                                                                Input@5
                                                            )}, fun() ->
                                                            gleam@result:'try'(
                                                                close_declaration(
                                                                    Input@5,
                                                                    State@4,
                                                                    Opened_in
                                                                ),
                                                                fun(_use0@5) ->
                                                                    {Input@6,
                                                                        State@5} = _use0@5,
                                                                    Dtd = erlang:element(
                                                                        2,
                                                                        State@5
                                                                    ),
                                                                    State@6 = case Entity of
                                                                        {internal_entity,
                                                                            Replacement} ->
                                                                            case gleam@dict:has_key(
                                                                                erlang:element(
                                                                                    5,
                                                                                    Dtd
                                                                                ),
                                                                                Name
                                                                            ) of
                                                                                true ->
                                                                                    State@5;

                                                                                false ->
                                                                                    {dtd_state,
                                                                                        {dtd,
                                                                                            erlang:element(
                                                                                                2,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                3,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                4,
                                                                                                Dtd
                                                                                            ),
                                                                                            gleam@dict:insert(
                                                                                                erlang:element(
                                                                                                    5,
                                                                                                    Dtd
                                                                                                ),
                                                                                                Name,
                                                                                                Replacement
                                                                                            ),
                                                                                            erlang:element(
                                                                                                6,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                7,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                8,
                                                                                                Dtd
                                                                                            )},
                                                                                        erlang:element(
                                                                                            3,
                                                                                            State@5
                                                                                        ),
                                                                                        erlang:element(
                                                                                            4,
                                                                                            State@5
                                                                                        ),
                                                                                        erlang:element(
                                                                                            5,
                                                                                            State@5
                                                                                        ),
                                                                                        gleam@dict:insert(
                                                                                            erlang:element(
                                                                                                6,
                                                                                                State@5
                                                                                            ),
                                                                                            Name,
                                                                                            nil
                                                                                        )}
                                                                            end;

                                                                        {external_entity,
                                                                            _,
                                                                            _,
                                                                            _} ->
                                                                            State@5
                                                                    end,
                                                                    {ok,
                                                                        {Input@6,
                                                                            State@6}}
                                                                end
                                                            )
                                                        end)
                                                end
                                            )
                                        end
                                    )
                                end
                            )
                        end
                    );

                <<"%\t"/utf8, Rest/binary>> ->
                    gleam@result:'try'(
                        skip_dtd_space(advance(Input@1, Rest), State@1, false),
                        fun(_use0@1) ->
                            {Input@2, State@2} = _use0@1,
                            gleam@result:'try'(
                                dtd_name(Input@2),
                                fun(_use0@2) ->
                                    {Name, Rest@1} = _use0@2,
                                    Input@3 = advance(Input@2, Rest@1),
                                    gleam@result:'try'(
                                        require_dtd_space(
                                            Input@3,
                                            State@2,
                                            may_expand_here(Input@3, State@2)
                                        ),
                                        fun(_use0@3) ->
                                            {Input@4, State@3} = _use0@3,
                                            gleam@result:'try'(
                                                parse_entity_definition(
                                                    Input@4,
                                                    State@3,
                                                    Declared_in
                                                ),
                                                fun(_use0@4) ->
                                                    {Entity, Input@5, State@4} = _use0@4,
                                                    require(case Entity of
                                                            {external_entity,
                                                                _,
                                                                {some, _},
                                                                _} ->
                                                                false;

                                                            _ ->
                                                                true
                                                        end, {malformed_doctype,
                                                            dtd_position(
                                                                Input@5
                                                            )}, fun() ->
                                                            gleam@result:'try'(
                                                                close_declaration(
                                                                    Input@5,
                                                                    State@4,
                                                                    Opened_in
                                                                ),
                                                                fun(_use0@5) ->
                                                                    {Input@6,
                                                                        State@5} = _use0@5,
                                                                    Dtd = erlang:element(
                                                                        2,
                                                                        State@5
                                                                    ),
                                                                    State@6 = case Entity of
                                                                        {internal_entity,
                                                                            Replacement} ->
                                                                            case gleam@dict:has_key(
                                                                                erlang:element(
                                                                                    5,
                                                                                    Dtd
                                                                                ),
                                                                                Name
                                                                            ) of
                                                                                true ->
                                                                                    State@5;

                                                                                false ->
                                                                                    {dtd_state,
                                                                                        {dtd,
                                                                                            erlang:element(
                                                                                                2,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                3,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                4,
                                                                                                Dtd
                                                                                            ),
                                                                                            gleam@dict:insert(
                                                                                                erlang:element(
                                                                                                    5,
                                                                                                    Dtd
                                                                                                ),
                                                                                                Name,
                                                                                                Replacement
                                                                                            ),
                                                                                            erlang:element(
                                                                                                6,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                7,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                8,
                                                                                                Dtd
                                                                                            )},
                                                                                        erlang:element(
                                                                                            3,
                                                                                            State@5
                                                                                        ),
                                                                                        erlang:element(
                                                                                            4,
                                                                                            State@5
                                                                                        ),
                                                                                        erlang:element(
                                                                                            5,
                                                                                            State@5
                                                                                        ),
                                                                                        gleam@dict:insert(
                                                                                            erlang:element(
                                                                                                6,
                                                                                                State@5
                                                                                            ),
                                                                                            Name,
                                                                                            nil
                                                                                        )}
                                                                            end;

                                                                        {external_entity,
                                                                            _,
                                                                            _,
                                                                            _} ->
                                                                            State@5
                                                                    end,
                                                                    {ok,
                                                                        {Input@6,
                                                                            State@6}}
                                                                end
                                                            )
                                                        end)
                                                end
                                            )
                                        end
                                    )
                                end
                            )
                        end
                    );

                <<"%\n"/utf8, Rest/binary>> ->
                    gleam@result:'try'(
                        skip_dtd_space(advance(Input@1, Rest), State@1, false),
                        fun(_use0@1) ->
                            {Input@2, State@2} = _use0@1,
                            gleam@result:'try'(
                                dtd_name(Input@2),
                                fun(_use0@2) ->
                                    {Name, Rest@1} = _use0@2,
                                    Input@3 = advance(Input@2, Rest@1),
                                    gleam@result:'try'(
                                        require_dtd_space(
                                            Input@3,
                                            State@2,
                                            may_expand_here(Input@3, State@2)
                                        ),
                                        fun(_use0@3) ->
                                            {Input@4, State@3} = _use0@3,
                                            gleam@result:'try'(
                                                parse_entity_definition(
                                                    Input@4,
                                                    State@3,
                                                    Declared_in
                                                ),
                                                fun(_use0@4) ->
                                                    {Entity, Input@5, State@4} = _use0@4,
                                                    require(case Entity of
                                                            {external_entity,
                                                                _,
                                                                {some, _},
                                                                _} ->
                                                                false;

                                                            _ ->
                                                                true
                                                        end, {malformed_doctype,
                                                            dtd_position(
                                                                Input@5
                                                            )}, fun() ->
                                                            gleam@result:'try'(
                                                                close_declaration(
                                                                    Input@5,
                                                                    State@4,
                                                                    Opened_in
                                                                ),
                                                                fun(_use0@5) ->
                                                                    {Input@6,
                                                                        State@5} = _use0@5,
                                                                    Dtd = erlang:element(
                                                                        2,
                                                                        State@5
                                                                    ),
                                                                    State@6 = case Entity of
                                                                        {internal_entity,
                                                                            Replacement} ->
                                                                            case gleam@dict:has_key(
                                                                                erlang:element(
                                                                                    5,
                                                                                    Dtd
                                                                                ),
                                                                                Name
                                                                            ) of
                                                                                true ->
                                                                                    State@5;

                                                                                false ->
                                                                                    {dtd_state,
                                                                                        {dtd,
                                                                                            erlang:element(
                                                                                                2,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                3,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                4,
                                                                                                Dtd
                                                                                            ),
                                                                                            gleam@dict:insert(
                                                                                                erlang:element(
                                                                                                    5,
                                                                                                    Dtd
                                                                                                ),
                                                                                                Name,
                                                                                                Replacement
                                                                                            ),
                                                                                            erlang:element(
                                                                                                6,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                7,
                                                                                                Dtd
                                                                                            ),
                                                                                            erlang:element(
                                                                                                8,
                                                                                                Dtd
                                                                                            )},
                                                                                        erlang:element(
                                                                                            3,
                                                                                            State@5
                                                                                        ),
                                                                                        erlang:element(
                                                                                            4,
                                                                                            State@5
                                                                                        ),
                                                                                        erlang:element(
                                                                                            5,
                                                                                            State@5
                                                                                        ),
                                                                                        gleam@dict:insert(
                                                                                            erlang:element(
                                                                                                6,
                                                                                                State@5
                                                                                            ),
                                                                                            Name,
                                                                                            nil
                                                                                        )}
                                                                            end;

                                                                        {external_entity,
                                                                            _,
                                                                            _,
                                                                            _} ->
                                                                            State@5
                                                                    end,
                                                                    {ok,
                                                                        {Input@6,
                                                                            State@6}}
                                                                end
                                                            )
                                                        end)
                                                end
                                            )
                                        end
                                    )
                                end
                            )
                        end
                    );

                _ ->
                    gleam@result:'try'(
                        skip_dtd_space(
                            Input@1,
                            State@1,
                            may_expand_here(Input@1, State@1)
                        ),
                        fun(_use0@6) ->
                            {Input@7, State@7} = _use0@6,
                            gleam@result:'try'(
                                dtd_name(Input@7),
                                fun(_use0@7) ->
                                    {Name@1, Rest@2} = _use0@7,
                                    Input@8 = advance(Input@7, Rest@2),
                                    gleam@result:'try'(
                                        require_dtd_space(
                                            Input@8,
                                            State@7,
                                            may_expand_here(Input@8, State@7)
                                        ),
                                        fun(_use0@8) ->
                                            {Input@9, State@8} = _use0@8,
                                            gleam@result:'try'(
                                                parse_entity_definition(
                                                    Input@9,
                                                    State@8,
                                                    Declared_in
                                                ),
                                                fun(_use0@9) ->
                                                    {Entity@1,
                                                        Input@10,
                                                        State@9} = _use0@9,
                                                    gleam@result:'try'(
                                                        close_declaration(
                                                            Input@10,
                                                            State@9,
                                                            Opened_in
                                                        ),
                                                        fun(_use0@10) ->
                                                            {Input@11, State@10} = _use0@10,
                                                            Dtd@1 = erlang:element(
                                                                2,
                                                                State@10
                                                            ),
                                                            State@11 = case gleam@dict:has_key(
                                                                erlang:element(
                                                                    4,
                                                                    Dtd@1
                                                                ),
                                                                Name@1
                                                            ) of
                                                                true ->
                                                                    State@10;

                                                                false ->
                                                                    {dtd_state,
                                                                        {dtd,
                                                                            erlang:element(
                                                                                2,
                                                                                Dtd@1
                                                                            ),
                                                                            erlang:element(
                                                                                3,
                                                                                Dtd@1
                                                                            ),
                                                                            gleam@dict:insert(
                                                                                erlang:element(
                                                                                    4,
                                                                                    Dtd@1
                                                                                ),
                                                                                Name@1,
                                                                                Entity@1
                                                                            ),
                                                                            erlang:element(
                                                                                5,
                                                                                Dtd@1
                                                                            ),
                                                                            erlang:element(
                                                                                6,
                                                                                Dtd@1
                                                                            ),
                                                                            erlang:element(
                                                                                7,
                                                                                Dtd@1
                                                                            ),
                                                                            erlang:element(
                                                                                8,
                                                                                Dtd@1
                                                                            )},
                                                                        erlang:element(
                                                                            3,
                                                                            State@10
                                                                        ),
                                                                        erlang:element(
                                                                            4,
                                                                            State@10
                                                                        ),
                                                                        erlang:element(
                                                                            5,
                                                                            State@10
                                                                        ),
                                                                        erlang:element(
                                                                            6,
                                                                            State@10
                                                                        )}
                                                            end,
                                                            {ok,
                                                                {Input@11,
                                                                    State@11}}
                                                        end
                                                    )
                                                end
                                            )
                                        end
                                    )
                                end
                            )
                        end
                    )
            end
        end
    ).

-file("src/glexml.gleam", 1804).
?DOC(
    " Skip an IGNORE section body up to its matching `]]>`, which must lie in\n"
    " the same entity (the section's content is not parsed, so segments are\n"
    " never pushed here).\n"
).
-spec skip_ignore_section(bitstring(), integer()) -> {ok, bitstring()} |
    {error, {error_kind(), integer()}}.
skip_ignore_section(Input, Depth) ->
    case Input of
        <<"]]>"/utf8, Rest/binary>> ->
            case Depth of
                0 ->
                    {ok, Rest};

                _ ->
                    skip_ignore_section(Rest, Depth - 1)
            end;

        <<"<!["/utf8, Rest@1/binary>> ->
            skip_ignore_section(Rest@1, Depth + 1);

        <<_, Rest@2/binary>> ->
            skip_ignore_section(Rest@2, Depth);

        _ ->
            {error, {unexpected_end_of_input, 0}}
    end.

-file("src/glexml.gleam", 1746).
?DOC(
    " Handle `INCLUDE [` or `IGNORE [` after `<![`. Returns `True` when an\n"
    " INCLUDE section was opened. The `[` must be in the same entity as the\n"
    " `<![`.\n"
).
-spec parse_conditional_start(dtd_input(), dtd_state(), integer()) -> {ok,
        {boolean(), dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
parse_conditional_start(Input, State, Opened_in) ->
    gleam@result:'try'(
        skip_dtd_space(Input, State, true),
        fun(_use0) ->
            {Input@1, State@1} = _use0,
            case erlang:element(2, Input@1) of
                <<"INCLUDE"/utf8, Rest/binary>> ->
                    case skip_dtd_space(advance(Input@1, Rest), State@1, true) of
                        {error, Failure} ->
                            {error, Failure};

                        {ok, {Input@2, State@2}} ->
                            case erlang:element(2, Input@2) of
                                <<"["/utf8, Rest@1/binary>> ->
                                    case check_same_segment(
                                        Input@2,
                                        State@2,
                                        Opened_in,
                                        <<"a conditional section"/utf8>>
                                    ) of
                                        {error, Failure@1} ->
                                            {error, Failure@1};

                                        {ok, State@3} ->
                                            {ok,
                                                {true,
                                                    advance(Input@2, Rest@1),
                                                    State@3}}
                                    end;

                                _ ->
                                    {error,
                                        {malformed_doctype,
                                            dtd_position(Input@2)}}
                            end
                    end;

                <<"IGNORE"/utf8, Rest@2/binary>> ->
                    case skip_dtd_space(advance(Input@1, Rest@2), State@1, true) of
                        {error, Failure@2} ->
                            {error, Failure@2};

                        {ok, {Input@3, State@4}} ->
                            case erlang:element(2, Input@3) of
                                <<"["/utf8, Rest@3/binary>> ->
                                    case check_same_segment(
                                        Input@3,
                                        State@4,
                                        Opened_in,
                                        <<"a conditional section"/utf8>>
                                    ) of
                                        {error, Failure@3} ->
                                            {error, Failure@3};

                                        {ok, State@5} ->
                                            case skip_ignore_section(Rest@3, 0) of
                                                {ok, Rest@4} ->
                                                    {ok,
                                                        {false,
                                                            advance(
                                                                Input@3,
                                                                Rest@4
                                                            ),
                                                            State@5}};

                                                {error, Failure@4} ->
                                                    {error, Failure@4}
                                            end
                                    end;

                                _ ->
                                    {error,
                                        {malformed_doctype,
                                            dtd_position(Input@3)}}
                            end
                    end;

                _ ->
                    {error, {malformed_doctype, dtd_position(Input@1)}}
            end
        end
    ).

-file("src/glexml.gleam", 1529).
?DOC(
    " The between-declarations variant: references expanded here must hold\n"
    " complete declarations.\n"
).
-spec skip_declaration_separators(dtd_input(), dtd_state()) -> {ok,
        {dtd_input(), dtd_state()}} |
    {error, {error_kind(), integer()}}.
skip_declaration_separators(Input, State) ->
    do_skip_dtd_space(Input, State, true, true).

-file("src/glexml.gleam", 1731).
-spec continue_declaration(
    {ok, {dtd_input(), dtd_state()}} | {error, {error_kind(), integer()}},
    subset_kind(),
    list(integer())
) -> {ok, {dtd_state(), bitstring()}} | {error, {error_kind(), integer()}}.
continue_declaration(Result, Kind, Conditionals) ->
    case Result of
        {ok, {Input, State}} ->
            parse_dtd_declarations(Input, State, Kind, Conditionals);

        {error, Failure} ->
            {error, Failure}
    end.

-file("src/glexml.gleam", 1616).
?DOC(
    " Parse the declarations of a DTD subset. An internal subset ends at `]`\n"
    " in the outermost segment, an external one at the end of input.\n"
    " `conditionals` holds the segment ids of the open `<![INCLUDE[`\n"
    " sections.\n"
).
-spec parse_dtd_declarations(
    dtd_input(),
    dtd_state(),
    subset_kind(),
    list(integer())
) -> {ok, {dtd_state(), bitstring()}} | {error, {error_kind(), integer()}}.
parse_dtd_declarations(Input, State, Kind, Conditionals) ->
    case skip_declaration_separators(Input, State) of
        {error, Failure} ->
            {error, Failure};

        {ok, {Input@1, State@1}} ->
            case erlang:element(2, Input@1) of
                <<>> ->
                    case {Kind, Conditionals} of
                        {external_subset, []} ->
                            {ok, {State@1, erlang:element(2, Input@1)}};

                        {_, _} ->
                            {error, {unexpected_end_of_input, 0}}
                    end;

                <<"]]>"/utf8, Rest/binary>> ->
                    case Conditionals of
                        [] ->
                            {error, {malformed_doctype, dtd_position(Input@1)}};

                        [Opened_in | Conditionals@1] ->
                            case check_same_segment(
                                Input@1,
                                State@1,
                                Opened_in,
                                <<"a conditional section"/utf8>>
                            ) of
                                {error, Failure@1} ->
                                    {error, Failure@1};

                                {ok, State@2} ->
                                    parse_dtd_declarations(
                                        advance(Input@1, Rest),
                                        State@2,
                                        Kind,
                                        Conditionals@1
                                    )
                            end
                    end;

                <<"]"/utf8, Rest@1/binary>> ->
                    case {Kind, Conditionals, erlang:element(6, Input@1)} of
                        {internal_subset, [], none} ->
                            {ok, {State@1, Rest@1}};

                        {_, _, _} ->
                            {error, {malformed_doctype, dtd_position(Input@1)}}
                    end;

                <<"<!--"/utf8, Rest@2/binary>> ->
                    case parse_comment(Rest@2) of
                        {ok, {_, Rest@3}} ->
                            parse_dtd_declarations(
                                advance(Input@1, Rest@3),
                                State@1,
                                Kind,
                                Conditionals
                            );

                        {error, Failure@2} ->
                            {error, Failure@2}
                    end;

                <<"<?"/utf8, Rest@4/binary>> ->
                    case parse_processing_instruction(Rest@4) of
                        {ok, {_, Rest@5}} ->
                            parse_dtd_declarations(
                                advance(Input@1, Rest@5),
                                State@1,
                                Kind,
                                Conditionals
                            );

                        {error, Failure@3} ->
                            {error, Failure@3}
                    end;

                <<"<!["/utf8, Rest@6/binary>> ->
                    case erlang:element(3, State@1) orelse gleam@option:is_some(
                        erlang:element(6, Input@1)
                    ) of
                        false ->
                            {error, {malformed_doctype, dtd_position(Input@1)}};

                        true ->
                            Opened_in@1 = erlang:element(4, Input@1),
                            case parse_conditional_start(
                                advance(Input@1, Rest@6),
                                State@1,
                                Opened_in@1
                            ) of
                                {error, Failure@4} ->
                                    {error, Failure@4};

                                {ok, {true, Input@2, State@3}} ->
                                    parse_dtd_declarations(
                                        Input@2,
                                        State@3,
                                        Kind,
                                        [Opened_in@1 | Conditionals]
                                    );

                                {ok, {false, Input@3, State@4}} ->
                                    parse_dtd_declarations(
                                        Input@3,
                                        State@4,
                                        Kind,
                                        Conditionals
                                    )
                            end
                    end;

                <<"<!ENTITY"/utf8, Rest@7/binary>> ->
                    continue_declaration(
                        parse_entity_declaration(
                            advance(Input@1, Rest@7),
                            State@1,
                            erlang:element(4, Input@1)
                        ),
                        Kind,
                        Conditionals
                    );

                <<"<!ELEMENT"/utf8, Rest@8/binary>> ->
                    continue_declaration(
                        parse_element_declaration(
                            advance(Input@1, Rest@8),
                            State@1,
                            erlang:element(4, Input@1)
                        ),
                        Kind,
                        Conditionals
                    );

                <<"<!ATTLIST"/utf8, Rest@9/binary>> ->
                    continue_declaration(
                        parse_attlist_declaration(
                            advance(Input@1, Rest@9),
                            State@1,
                            erlang:element(4, Input@1)
                        ),
                        Kind,
                        Conditionals
                    );

                <<"<!NOTATION"/utf8, Rest@10/binary>> ->
                    continue_declaration(
                        parse_notation_declaration(
                            advance(Input@1, Rest@10),
                            State@1,
                            erlang:element(4, Input@1)
                        ),
                        Kind,
                        Conditionals
                    );

                _ ->
                    {error, {malformed_doctype, dtd_position(Input@1)}}
            end
    end.

-file("src/glexml.gleam", 1351).
-spec require_whitespace(bitstring()) -> {ok, bitstring()} |
    {error, {error_kind(), integer()}}.
require_whitespace(Input) ->
    Stripped = skip_whitespace(Input),
    case erlang:byte_size(Stripped) < erlang:byte_size(Input) of
        true ->
            {ok, Stripped};

        false ->
            {error, {missing_whitespace, erlang:byte_size(Input)}}
    end.

-file("src/glexml.gleam", 1304).
?DOC(
    " Parse a SYSTEM or PUBLIC identifier. A system literal is required after\n"
    " a public one everywhere except in notation declarations.\n"
).
-spec parse_external_id(bitstring(), boolean()) -> {ok,
        {external_id(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_external_id(Input, Require_system) ->
    case Input of
        <<"SYSTEM"/utf8, Rest/binary>> ->
            gleam@result:'try'(
                require_whitespace(Rest),
                fun(Rest@1) ->
                    gleam@result:'try'(
                        parse_quoted_literal(Rest@1),
                        fun(_use0) ->
                            {System, Rest@2} = _use0,
                            {ok, {{system, System}, Rest@2}}
                        end
                    )
                end
            );

        <<"PUBLIC"/utf8, Rest@3/binary>> ->
            gleam@result:'try'(
                require_whitespace(Rest@3),
                fun(Rest@4) ->
                    gleam@result:'try'(
                        parse_quoted_literal(Rest@4),
                        fun(_use0@1) ->
                            {Public, Rest@5} = _use0@1,
                            case is_valid_public_id(Public) of
                                false ->
                                    {error,
                                        {malformed_doctype,
                                            erlang:byte_size(Rest@5)}};

                                true ->
                                    case Require_system of
                                        true ->
                                            gleam@result:'try'(
                                                require_whitespace(Rest@5),
                                                fun(Rest@6) ->
                                                    gleam@result:'try'(
                                                        parse_quoted_literal(
                                                            Rest@6
                                                        ),
                                                        fun(_use0@2) ->
                                                            {System@1, Rest@7} = _use0@2,
                                                            {ok,
                                                                {{public,
                                                                        Public,
                                                                        {some,
                                                                            System@1}},
                                                                    Rest@7}}
                                                        end
                                                    )
                                                end
                                            );

                                        false ->
                                            After_public = skip_whitespace(
                                                Rest@5
                                            ),
                                            case parse_quoted_literal(
                                                After_public
                                            ) of
                                                {ok, {System@2, Rest@8}} ->
                                                    {ok,
                                                        {{public,
                                                                Public,
                                                                {some, System@2}},
                                                            Rest@8}};

                                                {error, _} ->
                                                    {ok,
                                                        {{public, Public, none},
                                                            Rest@5}}
                                            end
                                    end
                            end
                        end
                    )
                end
            );

        _ ->
            {error, {malformed_doctype, erlang:byte_size(Input)}}
    end.

-file("src/glexml.gleam", 1246).
?DOC(
    " Parse a DOCTYPE declaration. The input begins immediately after\n"
    " `<!DOCTYPE`.\n"
).
-spec parse_doctype(bitstring(), dtd()) -> {ok,
        {doctype(), boolean(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_doctype(Input, External) ->
    Input@1 = skip_whitespace(Input),
    gleam@result:'try'(
        parse_name(Input@1),
        fun(_use0) ->
            {Name, Rest} = _use0,
            Rest@1 = skip_whitespace(Rest),
            gleam@result:'try'(case Rest@1 of
                    <<"SYSTEM"/utf8, _/binary>> ->
                        gleam@result:'try'(
                            parse_external_id(Rest@1, true),
                            fun(_use0@1) ->
                                {Id, Rest@2} = _use0@1,
                                {ok, {{some, Id}, Rest@2}}
                            end
                        );

                    <<"PUBLIC"/utf8, _/binary>> ->
                        gleam@result:'try'(
                            parse_external_id(Rest@1, true),
                            fun(_use0@1) ->
                                {Id, Rest@2} = _use0@1,
                                {ok, {{some, Id}, Rest@2}}
                            end
                        );

                    _ ->
                        {ok, {none, Rest@1}}
                end, fun(_use0@2) ->
                    {External_id, Rest@3} = _use0@2,
                    Rest@4 = skip_whitespace(Rest@3),
                    gleam@result:'try'(case Rest@4 of
                            <<"["/utf8, Rest@5/binary>> ->
                                Seed = begin
                                    _record = empty_dtd(),
                                    {dtd,
                                        erlang:element(2, _record),
                                        erlang:element(3, _record),
                                        erlang:element(4, _record),
                                        erlang:element(5, External),
                                        erlang:element(6, _record),
                                        erlang:element(7, _record),
                                        erlang:element(8, _record)}
                                end,
                                Subset_input = {dtd_input,
                                    Rest@5,
                                    none,
                                    0,
                                    false,
                                    none},
                                Subset_state = {dtd_state,
                                    Seed,
                                    false,
                                    1,
                                    false,
                                    maps:new()},
                                gleam@result:'try'(
                                    parse_dtd_declarations(
                                        Subset_input,
                                        Subset_state,
                                        internal_subset,
                                        []
                                    ),
                                    fun(_use0@3) ->
                                        {State, Rest@6} = _use0@3,
                                        {ok,
                                            {erlang:element(2, State),
                                                erlang:element(5, State),
                                                skip_whitespace(Rest@6)}}
                                    end
                                );

                            _ ->
                                {ok, {empty_dtd(), false, Rest@4}}
                        end, fun(_use0@4) ->
                            {Declarations, Used_parameter_entities, Rest@7} = _use0@4,
                            case Rest@7 of
                                <<">"/utf8, Rest@8/binary>> ->
                                    {ok,
                                        {{doctype,
                                                Name,
                                                External_id,
                                                Declarations},
                                            Used_parameter_entities,
                                            Rest@8}};

                                <<>> ->
                                    {error, {unexpected_end_of_input, 0}};

                                _ ->
                                    {error,
                                        {malformed_doctype,
                                            erlang:byte_size(Rest@7)}}
                            end
                        end)
                end)
        end
    ).

-file("src/glexml.gleam", 1181).
?DOC(
    " Read whitespace, comments, processing instructions, and at most one\n"
    " DOCTYPE declaration before the root element, keeping the comments and\n"
    " processing instructions in document order.\n"
).
-spec parse_prolog(
    bitstring(),
    gleam@option:option({doctype(), boolean()}),
    list(node_()),
    dtd()
) -> {ok,
        {gleam@option:option({doctype(), boolean()}),
            list(node_()),
            bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_prolog(Input, Doctype, Nodes, External) ->
    Input@1 = skip_whitespace(Input),
    case Input@1 of
        <<"<!--"/utf8, Rest/binary>> ->
            case parse_comment(Rest) of
                {ok, {Content, Rest@1}} ->
                    parse_prolog(
                        Rest@1,
                        Doctype,
                        [{comment_node, Content} | Nodes],
                        External
                    );

                {error, Failure} ->
                    {error, Failure}
            end;

        <<"<!DOCTYPE"/utf8, Rest@2/binary>> ->
            case Doctype of
                {some, _} ->
                    {error, {malformed_doctype, erlang:byte_size(Input@1)}};

                none ->
                    case parse_doctype(Rest@2, External) of
                        {ok, {Doctype@1, Used_parameter_entities, Rest@3}} ->
                            parse_prolog(
                                Rest@3,
                                {some, {Doctype@1, Used_parameter_entities}},
                                Nodes,
                                External
                            );

                        {error, Failure@1} ->
                            {error, Failure@1}
                    end
            end;

        <<"<!doctype"/utf8, Rest@2/binary>> ->
            case Doctype of
                {some, _} ->
                    {error, {malformed_doctype, erlang:byte_size(Input@1)}};

                none ->
                    case parse_doctype(Rest@2, External) of
                        {ok, {Doctype@1, Used_parameter_entities, Rest@3}} ->
                            parse_prolog(
                                Rest@3,
                                {some, {Doctype@1, Used_parameter_entities}},
                                Nodes,
                                External
                            );

                        {error, Failure@1} ->
                            {error, Failure@1}
                    end
            end;

        <<"<?"/utf8, Rest@4/binary>> ->
            case parse_processing_instruction(Rest@4) of
                {ok, {Instruction, Rest@5}} ->
                    parse_prolog(
                        Rest@5,
                        Doctype,
                        [Instruction | Nodes],
                        External
                    );

                {error, Failure@2} ->
                    {error, Failure@2}
            end;

        _ ->
            {ok, {Doctype, lists:reverse(Nodes), Input@1}}
    end.

-file("src/glexml.gleam", 3200).
-spec attribute_value(list(attribute()), binary()) -> {ok, binary()} |
    {error, nil}.
attribute_value(Attributes, Name) ->
    gleam@list:find_map(
        Attributes,
        fun(Attribute) -> case erlang:element(2, Attribute) =:= Name of
                true ->
                    {ok, erlang:element(3, Attribute)};

                false ->
                    {error, nil}
            end end
    ).

-file("src/glexml.gleam", 1126).
-spec is_valid_encoding_name(binary()) -> boolean().
is_valid_encoding_name(Encoding) ->
    case gleam@string:to_utf_codepoints(Encoding) of
        [] ->
            false;

        [First | Rest] ->
            Is_alpha = fun(Code) ->
                ((Code >= 16#41) andalso (Code =< 16#5A)) orelse ((Code >= 16#61)
                andalso (Code =< 16#7A))
            end,
            Is_alpha(gleam_stdlib:identity(First)) andalso gleam@list:all(
                Rest,
                fun(Codepoint) ->
                    Code@1 = gleam_stdlib:identity(Codepoint),
                    (((Is_alpha(Code@1) orelse ((Code@1 >= 16#30) andalso (Code@1
                    =< 16#39)))
                    orelse (Code@1 =:= 16#2E))
                    orelse (Code@1 =:= 16#5F))
                    orelse (Code@1 =:= 16#2D)
                end
            )
    end.

-file("src/glexml.gleam", 1118).
-spec is_all_digits(binary()) -> boolean().
is_all_digits(Text) ->
    _pipe = gleam@string:to_utf_codepoints(Text),
    gleam@list:all(
        _pipe,
        fun(Codepoint) ->
            Code = gleam_stdlib:identity(Codepoint),
            (Code >= 16#30) andalso (Code =< 16#39)
        end
    ).

-file("src/glexml.gleam", 1111).
-spec is_valid_xml_version(binary()) -> boolean().
is_valid_xml_version(Version) ->
    case Version of
        <<"1."/utf8, Minor/binary>> ->
            (Minor /= <<""/utf8>>) andalso is_all_digits(Minor);

        _ ->
            false
    end.

-file("src/glexml.gleam", 1097).
-spec ordered_declaration_attributes(
    list(attribute()),
    fun(() -> {ok, DSJ} | {error, error_kind()})
) -> {ok, DSJ} | {error, error_kind()}.
ordered_declaration_attributes(Attributes, Continue) ->
    Names = gleam@list:map(
        Attributes,
        fun(Attribute) -> erlang:element(2, Attribute) end
    ),
    case Names of
        [<<"version"/utf8>>] ->
            Continue();

        [<<"version"/utf8>>, <<"encoding"/utf8>>] ->
            Continue();

        [<<"version"/utf8>>, <<"standalone"/utf8>>] ->
            Continue();

        [<<"version"/utf8>>, <<"encoding"/utf8>>, <<"standalone"/utf8>>] ->
            Continue();

        _ ->
            {error, {malformed_attribute, <<"xml declaration"/utf8>>}}
    end.

-file("src/glexml.gleam", 1068).
?DOC(
    " The XML declaration allows exactly `version`, then optionally\n"
    " `encoding`, then optionally `standalone`, with restricted values.\n"
).
-spec validate_declaration(list(attribute())) -> {ok,
        {binary(), gleam@option:option(binary()), boolean()}} |
    {error, error_kind()}.
validate_declaration(Attributes) ->
    ordered_declaration_attributes(
        Attributes,
        fun() ->
            gleam@result:'try'(
                case attribute_value(Attributes, <<"version"/utf8>>) of
                    {ok, Version} ->
                        case is_valid_xml_version(Version) of
                            true ->
                                {ok, Version};

                            false ->
                                {error,
                                    {malformed_attribute, <<"version"/utf8>>}}
                        end;

                    {error, nil} ->
                        {error, {malformed_attribute, <<"version"/utf8>>}}
                end,
                fun(Version@1) ->
                    gleam@result:'try'(
                        case attribute_value(Attributes, <<"encoding"/utf8>>) of
                            {error, nil} ->
                                {ok, none};

                            {ok, Encoding} ->
                                case is_valid_encoding_name(Encoding) of
                                    true ->
                                        {ok, {some, Encoding}};

                                    false ->
                                        {error,
                                            {malformed_attribute,
                                                <<"encoding"/utf8>>}}
                                end
                        end,
                        fun(Encoding@1) ->
                            gleam@result:'try'(
                                case attribute_value(
                                    Attributes,
                                    <<"standalone"/utf8>>
                                ) of
                                    {error, nil} ->
                                        {ok, false};

                                    {ok, <<"yes"/utf8>>} ->
                                        {ok, true};

                                    {ok, <<"no"/utf8>>} ->
                                        {ok, false};

                                    {ok, _} ->
                                        {error,
                                            {malformed_attribute,
                                                <<"standalone"/utf8>>}}
                                end,
                                fun(Standalone) ->
                                    {ok, {Version@1, Encoding@1, Standalone}}
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/glexml.gleam", 1146).
-spec parse_declaration_attributes(bitstring(), list(attribute())) -> {ok,
        {list(attribute()), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_declaration_attributes(Input, Acc) ->
    Stripped = skip_whitespace(Input),
    case Stripped of
        <<>> ->
            {error, {unexpected_end_of_input, 0}};

        <<"?>"/utf8, Rest/binary>> ->
            {ok, {lists:reverse(Acc), Rest}};

        _ ->
            Had_space = erlang:byte_size(Stripped) < erlang:byte_size(Input),
            gleam@result:'try'(case Had_space orelse (Acc =:= []) of
                    true ->
                        {ok, Stripped};

                    false ->
                        {error,
                            {missing_whitespace, erlang:byte_size(Stripped)}}
                end, fun(Input@1) ->
                    case parse_attribute(Input@1, empty_dtd()) of
                        {ok, {Attribute, Rest@1}} ->
                            case has_attribute(
                                Acc,
                                erlang:element(2, Attribute)
                            ) of
                                true ->
                                    {error,
                                        {{duplicate_attribute,
                                                erlang:element(2, Attribute)},
                                            erlang:byte_size(Input@1)}};

                                false ->
                                    parse_declaration_attributes(
                                        Rest@1,
                                        [Attribute | Acc]
                                    )
                            end;

                        {error, Failure} ->
                            {error, Failure}
                    end
                end)
    end.

-file("src/glexml.gleam", 1046).
-spec parse_declaration(bitstring()) -> {ok,
        {binary(), gleam@option:option(binary()), boolean(), bitstring()}} |
    {error, {error_kind(), integer()}}.
parse_declaration(Input) ->
    case Input of
        <<"<?xml "/utf8, Rest/binary>> ->
            gleam@result:'try'(
                parse_declaration_attributes(Rest, []),
                fun(_use0) ->
                    {Attributes, Rest@1} = _use0,
                    case validate_declaration(Attributes) of
                        {ok, {Version, Encoding, Standalone}} ->
                            {ok, {Version, Encoding, Standalone, Rest@1}};

                        {error, Kind} ->
                            {error, {Kind, erlang:byte_size(Rest@1)}}
                    end
                end
            );

        <<"<?xml\t"/utf8, Rest/binary>> ->
            gleam@result:'try'(
                parse_declaration_attributes(Rest, []),
                fun(_use0) ->
                    {Attributes, Rest@1} = _use0,
                    case validate_declaration(Attributes) of
                        {ok, {Version, Encoding, Standalone}} ->
                            {ok, {Version, Encoding, Standalone, Rest@1}};

                        {error, Kind} ->
                            {error, {Kind, erlang:byte_size(Rest@1)}}
                    end
                end
            );

        <<"<?xml\n"/utf8, Rest/binary>> ->
            gleam@result:'try'(
                parse_declaration_attributes(Rest, []),
                fun(_use0) ->
                    {Attributes, Rest@1} = _use0,
                    case validate_declaration(Attributes) of
                        {ok, {Version, Encoding, Standalone}} ->
                            {ok, {Version, Encoding, Standalone, Rest@1}};

                        {error, Kind} ->
                            {error, {Kind, erlang:byte_size(Rest@1)}}
                    end
                end
            );

        _ ->
            {ok, {<<"1.0"/utf8>>, none, false, Input}}
    end.

-file("src/glexml.gleam", 986).
-spec parse_document(bitstring(), dtd()) -> {ok, document()} |
    {error, {error_kind(), integer()}}.
parse_document(Input, External) ->
    gleam@result:'try'(
        parse_declaration(Input),
        fun(_use0) ->
            {Version, Encoding, Standalone, Input@1} = _use0,
            gleam@result:'try'(
                parse_prolog(Input@1, none, [], External),
                fun(_use0@1) ->
                    {Doctype_info, Prolog, Input@2} = _use0@1,
                    Doctype = gleam@option:map(
                        Doctype_info,
                        fun(Info) -> erlang:element(1, Info) end
                    ),
                    Dtd = case Doctype of
                        {some, Doctype@1} ->
                            merge_dtds(erlang:element(4, Doctype@1), External);

                        none ->
                            External
                    end,
                    Dtd@1 = case {Standalone, Doctype} of
                        {true, {some, Doctype@2}} ->
                            {dtd,
                                erlang:element(2, Dtd),
                                erlang:element(3, Dtd),
                                erlang:element(4, erlang:element(4, Doctype@2)),
                                erlang:element(5, Dtd),
                                erlang:element(6, Dtd),
                                erlang:element(7, Dtd),
                                erlang:element(8, Dtd)};

                        {true, none} ->
                            {dtd,
                                erlang:element(2, Dtd),
                                erlang:element(3, Dtd),
                                maps:new(),
                                erlang:element(5, Dtd),
                                erlang:element(6, Dtd),
                                erlang:element(7, Dtd),
                                erlang:element(8, Dtd)};

                        {false, _} ->
                            Dtd
                    end,
                    Relaxed_entities = case {Doctype_info, Standalone} of
                        {{some, {Doctype@3, Used_parameter_entities}}, false} ->
                            gleam@option:is_some(erlang:element(3, Doctype@3))
                            orelse Used_parameter_entities;

                        {_, _} ->
                            false
                    end,
                    case Input@2 of
                        <<"<"/utf8, Rest/binary>> ->
                            gleam@result:'try'(
                                parse_element(Rest, Dtd@1, Relaxed_entities),
                                fun(_use0@2) ->
                                    {Root, Input@3} = _use0@2,
                                    gleam@result:'try'(
                                        parse_epilogue(Input@3, []),
                                        fun(_use0@3) ->
                                            {Epilogue, Input@4} = _use0@3,
                                            case Input@4 of
                                                <<>> ->
                                                    {ok,
                                                        {document,
                                                            Version,
                                                            Encoding,
                                                            Standalone,
                                                            Doctype,
                                                            Prolog,
                                                            Root,
                                                            Epilogue}};

                                                _ ->
                                                    {error,
                                                        {content_after_root_element,
                                                            erlang:byte_size(
                                                                Input@4
                                                            )}}
                                            end
                                        end
                                    )
                                end
                            );

                        _ ->
                            {error,
                                {missing_root_element,
                                    erlang:byte_size(Input@2)}}
                    end
                end
            )
        end
    ).

-file("src/glexml.gleam", 556).
-spec scan_to_carriage_return(bitstring(), integer()) -> {ok,
        {integer(), bitstring()}} |
    {error, nil}.
scan_to_carriage_return(Input, Count) ->
    case Input of
        <<"\r"/utf8, Rest/binary>> ->
            {ok, {Count, Rest}};

        <<_, Rest@1/binary>> ->
            scan_to_carriage_return(Rest@1, Count + 1);

        _ ->
            {error, nil}
    end.

-file("src/glexml.gleam", 539).
-spec do_normalise_line_endings(bitstring(), list(bitstring())) -> list(bitstring()).
do_normalise_line_endings(Input, Acc) ->
    case scan_to_carriage_return(Input, 0) of
        {error, nil} ->
            lists:reverse([Input | Acc]);

        {ok, {Count, Rest}} ->
            Before@1 = case gleam_stdlib:bit_array_slice(Input, 0, Count) of
                {ok, Before} -> Before;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                                file => <<?FILEPATH/utf8>>,
                                module => <<"glexml"/utf8>>,
                                function => <<"do_normalise_line_endings"/utf8>>,
                                line => 546,
                                value => _assert_fail,
                                start => 21146,
                                'end' => 21202,
                                pattern_start => 21157,
                                pattern_end => 21167})
            end,
            Rest@1 = case Rest of
                <<"\n"/utf8, Tail/binary>> ->
                    Tail;

                _ ->
                    Rest
            end,
            do_normalise_line_endings(Rest@1, [<<"\n"/utf8>>, Before@1 | Acc])
    end.

-file("src/glexml.gleam", 531).
?DOC(
    " XML 1.0 section 2.11: normalise `\\r\\n` and lone `\\r` to a single line\n"
    " feed. This works on bytes rather than strings because Erlang's string\n"
    " functions treat `\\r\\n` as a single grapheme, which makes sequences like\n"
    " `\\r\\r\\n` impossible to normalise with `string.replace`.\n"
).
-spec normalise_line_endings(bitstring()) -> bitstring().
normalise_line_endings(Input) ->
    case scan_to_carriage_return(Input, 0) of
        {error, nil} ->
            Input;

        {ok, _} ->
            gleam_stdlib:bit_array_concat(do_normalise_line_endings(Input, []))
    end.

-file("src/glexml.gleam", 349).
?DOC(
    " Parse a string of XML with extra DTD declarations available, typically\n"
    " an external DTD subset loaded separately and parsed with `parse_dtd`.\n"
    "\n"
    " Entities declared in the document's own internal subset take precedence\n"
    " over the ones given here, mirroring how XML processors read the internal\n"
    " subset first.\n"
    "\n"
    " ```gleam\n"
    " let assert Ok(xhtml_dtd) = glexml.parse_dtd(\"<!ENTITY nbsp \\\"&#160;\\\">\")\n"
    " glexml.parse_with_dtd(\"<p>a&nbsp;b</p>\", xhtml_dtd)\n"
    " // -> Ok(...)\n"
    " ```\n"
).
-spec parse_with_dtd(binary(), dtd()) -> {ok, document()} |
    {error, parse_error()}.
parse_with_dtd(Input, Dtd) ->
    Input@1 = case Input of
        <<"\x{FEFF}"/utf8, Rest/binary>> ->
            Rest;

        _ ->
            Input
    end,
    Bytes = normalise_line_endings(gleam_stdlib:identity(Input@1)),
    case parse_document(Bytes, Dtd) of
        {ok, Document} ->
            {ok, Document};

        {error, {Kind, Remaining}} ->
            {error, make_error(Bytes, Kind, Remaining)}
    end.

-file("src/glexml.gleam", 333).
?DOC(
    " Parse a string of XML into a `Document`.\n"
    "\n"
    " ```gleam\n"
    " let assert Ok(document) = glexml.parse(\"<greeting lang=\\\"en\\\">Hello</greeting>\")\n"
    " document.root.name\n"
    " // -> \"greeting\"\n"
    " ```\n"
).
-spec parse(binary()) -> {ok, document()} | {error, parse_error()}.
parse(Input) ->
    parse_with_dtd(Input, empty_dtd()).

-file("src/glexml.gleam", 412).
?DOC(
    " Encoding problems have no meaningful position in the decoded text; they\n"
    " are reported at the start of the document.\n"
).
-spec encoding_error(error_kind()) -> parse_error().
encoding_error(Kind) ->
    {parse_error, Kind, 1, 1, 0}.

-file("src/glexml.gleam", 499).
?DOC(
    " It is a fatal error for the encoding declaration to name an encoding\n"
    " other than the one the document is actually in. We only flag\n"
    " contradictions we can be certain of: a UTF-16 document declaring\n"
    " something else, or a UTF-8 document declaring a UTF-16 or UTF-32\n"
    " family encoding.\n"
).
-spec declaration_matches_encoding(
    gleam@option:option(binary()),
    detected_encoding()
) -> {ok, nil} | {error, error_kind()}.
declaration_matches_encoding(Declared, Detected) ->
    case Declared of
        none ->
            {ok, nil};

        {some, Declared@1} ->
            Name = string:lowercase(Declared@1),
            Declares_utf16 = gleam_stdlib:string_starts_with(
                Name,
                <<"utf-16"/utf8>>
            )
            orelse gleam_stdlib:string_starts_with(Name, <<"ucs-2"/utf8>>),
            Declares_utf32 = gleam_stdlib:string_starts_with(
                Name,
                <<"utf-32"/utf8>>
            )
            orelse gleam_stdlib:string_starts_with(Name, <<"ucs-4"/utf8>>),
            case Detected of
                {detected_utf16, _} ->
                    case Declares_utf16 of
                        true ->
                            {ok, nil};

                        false ->
                            {error,
                                {declared_encoding_mismatch,
                                    Declared@1,
                                    <<"UTF-16"/utf8>>}}
                    end;

                detected_utf8 ->
                    case Declares_utf16 orelse Declares_utf32 of
                        true ->
                            {error,
                                {declared_encoding_mismatch,
                                    Declared@1,
                                    <<"UTF-8"/utf8>>}};

                        false ->
                            {ok, nil}
                    end
            end
    end.

-file("src/glexml.gleam", 443).
?DOC(
    " Decode UTF-16 in the given byte order, including surrogate pairs. Odd\n"
    " input lengths and invalid surrogates are errors.\n"
).
-spec decode_utf16(bitstring(), boolean(), list(integer())) -> {ok, binary()} |
    {error, binary()}.
decode_utf16(Input, Big_endian, Acc) ->
    case Input of
        <<>> ->
            {ok, gleam_stdlib:utf_codepoint_list_to_string(lists:reverse(Acc))};

        <<A, B, Rest/binary>> ->
            Unit = case Big_endian of
                true ->
                    (A * 256) + B;

                false ->
                    (B * 256) + A
            end,
            case (Unit >= 16#D800) andalso (Unit =< 16#DBFF) of
                true ->
                    case Rest of
                        <<C, D, Rest@1/binary>> ->
                            Low = case Big_endian of
                                true ->
                                    (C * 256) + D;

                                false ->
                                    (D * 256) + C
                            end,
                            case (Low >= 16#DC00) andalso (Low =< 16#DFFF) of
                                true ->
                                    Code = (16#10000 + ((Unit - 16#D800) * 16#400))
                                    + (Low - 16#DC00),
                                    case gleam@string:utf_codepoint(Code) of
                                        {ok, Codepoint} ->
                                            decode_utf16(
                                                Rest@1,
                                                Big_endian,
                                                [Codepoint | Acc]
                                            );

                                        {error, nil} ->
                                            {error, <<"UTF-16"/utf8>>}
                                    end;

                                false ->
                                    {error, <<"UTF-16"/utf8>>}
                            end;

                        _ ->
                            {error, <<"UTF-16"/utf8>>}
                    end;

                false ->
                    case (Unit >= 16#DC00) andalso (Unit =< 16#DFFF) of
                        true ->
                            {error, <<"UTF-16"/utf8>>};

                        false ->
                            case gleam@string:utf_codepoint(Unit) of
                                {ok, Codepoint@1} ->
                                    decode_utf16(
                                        Rest,
                                        Big_endian,
                                        [Codepoint@1 | Acc]
                                    );

                                {error, nil} ->
                                    {error, <<"UTF-16"/utf8>>}
                            end
                    end
            end;

        _ ->
            {error, <<"UTF-16"/utf8>>}
    end.

-file("src/glexml.gleam", 419).
?DOC(
    " Appendix F encoding detection: byte order marks first, then the byte\n"
    " pattern of a document starting with `<?xml` or `<`. Returns the\n"
    " detected encoding and the input with any byte order mark removed.\n"
).
-spec detect_encoding(bitstring()) -> {ok, {detected_encoding(), bitstring()}} |
    {error, binary()}.
detect_encoding(Input) ->
    case Input of
        <<16#00, 16#00, 16#FE, 16#FF, _/binary>> ->
            {error, <<"UTF-32"/utf8>>};

        <<16#FF, 16#FE, 16#00, 16#00, _/binary>> ->
            {error, <<"UTF-32"/utf8>>};

        <<16#EF, 16#BB, 16#BF, Rest/binary>> ->
            {ok, {detected_utf8, Rest}};

        <<16#FE, 16#FF, Rest@1/binary>> ->
            {ok, {{detected_utf16, true}, Rest@1}};

        <<16#FF, 16#FE, Rest@2/binary>> ->
            {ok, {{detected_utf16, false}, Rest@2}};

        <<16#00, 16#00, 16#00, 16#3C, _/binary>> ->
            {error, <<"UTF-32"/utf8>>};

        <<16#3C, 16#00, 16#00, 16#00, _/binary>> ->
            {error, <<"UTF-32"/utf8>>};

        <<16#00, 16#3C, 16#00, 16#3F, _/binary>> ->
            {ok, {{detected_utf16, true}, Input}};

        <<16#3C, 16#00, 16#3F, 16#00, _/binary>> ->
            {ok, {{detected_utf16, false}, Input}};

        <<16#4C, 16#6F, 16#A7, 16#94, _/binary>> ->
            {error, <<"EBCDIC"/utf8>>};

        _ ->
            {ok, {detected_utf8, Input}}
    end.

-file("src/glexml.gleam", 378).
?DOC(
    " `parse_bytes` with extra DTD declarations available, as with\n"
    " `parse_with_dtd`.\n"
).
-spec parse_bytes_with_dtd(bitstring(), dtd()) -> {ok, document()} |
    {error, parse_error()}.
parse_bytes_with_dtd(Input, Dtd) ->
    case detect_encoding(Input) of
        {error, Encoding} ->
            {error, encoding_error({unsupported_encoding, Encoding})};

        {ok, {Detected, Bytes}} ->
            Text = case Detected of
                detected_utf8 ->
                    _pipe = gleam@bit_array:to_string(Bytes),
                    gleam@result:replace_error(_pipe, <<"UTF-8"/utf8>>);

                {detected_utf16, Big_endian} ->
                    decode_utf16(Bytes, Big_endian, [])
            end,
            case Text of
                {error, Encoding@1} ->
                    {error, encoding_error({unsupported_encoding, Encoding@1})};

                {ok, Text@1} ->
                    gleam@result:'try'(
                        parse_with_dtd(Text@1, Dtd),
                        fun(Document) ->
                            case declaration_matches_encoding(
                                erlang:element(3, Document),
                                Detected
                            ) of
                                {ok, nil} ->
                                    {ok, Document};

                                {error, Kind} ->
                                    {error, encoding_error(Kind)}
                            end
                        end
                    )
            end
    end.

-file("src/glexml.gleam", 372).
?DOC(
    " Parse raw bytes of XML, detecting the character encoding first.\n"
    "\n"
    " Detection follows Appendix F of the XML specification: a byte order\n"
    " mark, or the byte pattern of `<?xml` at the start of the input. UTF-8\n"
    " (the default) and UTF-16 in either byte order are decoded; UTF-32 and\n"
    " EBCDIC are recognised but unsupported, and reported as\n"
    " `UnsupportedEncoding`. An `encoding` declaration that contradicts the\n"
    " detected encoding is an error, as the specification requires.\n"
    "\n"
    " Use this instead of `parse` when reading files whose encoding is not\n"
    " known to be UTF-8, such as XML inside EPUB 2 publications.\n"
).
-spec parse_bytes(bitstring()) -> {ok, document()} | {error, parse_error()}.
parse_bytes(Input) ->
    parse_bytes_with_dtd(Input, empty_dtd()).

-file("src/glexml.gleam", 602).
?DOC(" Parse an external subset from its first byte.\n").
-spec parse_subset(bitstring(), dtd()) -> {ok, {dtd(), boolean()}} |
    {error, {error_kind(), integer()}}.
parse_subset(Bytes, Seed) ->
    Input = {dtd_input, Bytes, none, 0, false, none},
    State = {dtd_state, Seed, true, 1, false, maps:new()},
    case parse_dtd_declarations(Input, State, external_subset, []) of
        {ok, {State@1, _}} ->
            {ok, {erlang:element(2, State@1), erlang:element(5, State@1)}};

        {error, Failure} ->
            {error, Failure}
    end.

-file("src/glexml.gleam", 573).
?DOC(
    " Parse the text of an external DTD subset (a `.dtd` file) into a `Dtd`.\n"
    "\n"
    " Parameter entities, conditional sections (`<![INCLUDE[`/`<![IGNORE[`),\n"
    " and all four declaration kinds are supported. The result can be passed\n"
    " to `parse_with_dtd` so its entities resolve during parsing, and to\n"
    " `glexml/dtd.validate` to validate a document against it.\n"
).
-spec parse_dtd(binary()) -> {ok, dtd()} | {error, parse_error()}.
parse_dtd(Input) ->
    Input@1 = case Input of
        <<"\x{FEFF}"/utf8, Rest/binary>> ->
            Rest;

        _ ->
            Input
    end,
    Bytes = normalise_line_endings(gleam_stdlib:identity(Input@1)),
    case parse_subset(Bytes, empty_dtd()) of
        {ok, {Dtd, _}} ->
            {ok, Dtd};

        {error, {Kind, Remaining}} ->
            {error, make_error(Bytes, Kind, Remaining)}
    end.

-file("src/glexml.gleam", 589).
?DOC(
    " Like `parse_dtd`, but with declarations already in scope: the given\n"
    " DTD's declarations bind first, exactly as if they had been read before\n"
    " this subset. Use this when an external subset refers to parameter\n"
    " entities declared in a document's internal subset, which is read first.\n"
).
-spec parse_dtd_with(binary(), dtd()) -> {ok, dtd()} | {error, parse_error()}.
parse_dtd_with(Input, Seed) ->
    Input@1 = case Input of
        <<"\x{FEFF}"/utf8, Rest/binary>> ->
            Rest;

        _ ->
            Input
    end,
    Bytes = normalise_line_endings(gleam_stdlib:identity(Input@1)),
    case parse_subset(Bytes, Seed) of
        {ok, {Dtd, _}} ->
            {ok, Dtd};

        {error, {Kind, Remaining}} ->
            {error, make_error(Bytes, Kind, Remaining)}
    end.

-file("src/glexml.gleam", 708).
?DOC(
    " Convert a `ParseError` into a human readable message, suitable for\n"
    " showing to users of your tool.\n"
).
-spec error_to_string(parse_error()) -> binary().
error_to_string(Error) ->
    Message = case erlang:element(2, Error) of
        unexpected_end_of_input ->
            <<"unexpected end of input"/utf8>>;

        missing_root_element ->
            <<"expected a root element"/utf8>>;

        content_after_root_element ->
            <<"unexpected content after the root element"/utf8>>;

        invalid_name ->
            <<"expected a valid name"/utf8>>;

        {malformed_attribute, Name} ->
            <<<<"expected =\"value\" after attribute \""/utf8, Name/binary>>/binary,
                "\""/utf8>>;

        {duplicate_attribute, Name@1} ->
            <<<<"duplicate attribute \""/utf8, Name@1/binary>>/binary,
                "\""/utf8>>;

        {mismatched_closing_tag, Opening, Closing} ->
            <<<<<<<<"expected closing tag for \""/utf8, Opening/binary>>/binary,
                        "\" but found \""/utf8>>/binary,
                    Closing/binary>>/binary,
                "\""/utf8>>;

        malformed_entity ->
            <<"entity reference is missing a closing semicolon"/utf8>>;

        {unknown_entity, Entity} ->
            <<<<"unknown entity \"&"/utf8, Entity/binary>>/binary, ";\""/utf8>>;

        {invalid_character_reference, Reference} ->
            <<<<"invalid character reference \"&"/utf8, Reference/binary>>/binary,
                ";\""/utf8>>;

        malformed_doctype ->
            <<"malformed DOCTYPE or DTD declaration"/utf8>>;

        {recursive_entity, Entity@1} ->
            <<<<"entity \"&"/utf8, Entity@1/binary>>/binary,
                ";\" expands to itself"/utf8>>;

        {unresolvable_entity, Entity@2} ->
            <<<<"the content of entity \"&"/utf8, Entity@2/binary>>/binary,
                ";\" is external and not available"/utf8>>;

        {markup_in_attribute_value, Entity@3} ->
            <<<<"entity \"&"/utf8, Entity@3/binary>>/binary,
                ";\" puts a \"<\" inside an attribute value"/utf8>>;

        {unsupported_encoding, Encoding} ->
            <<"cannot decode the input as "/utf8, Encoding/binary>>;

        {declared_encoding_mismatch, Declared, Detected} ->
            <<<<<<"the declaration says encoding=\""/utf8, Declared/binary>>/binary,
                    "\" but the document is encoded as "/utf8>>/binary,
                Detected/binary>>;

        invalid_character ->
            <<"character not allowed here"/utf8>>;

        malformed_comment ->
            <<"comments may not contain \"--\""/utf8>>;

        cdata_end_in_content ->
            <<"character data may not contain \"]]>\""/utf8>>;

        {unbalanced_entity, Entity@4} ->
            <<<<"the content of entity \"&"/utf8, Entity@4/binary>>/binary,
                ";\" is not balanced"/utf8>>;

        missing_whitespace ->
            <<"whitespace is required here"/utf8>>
    end,
    <<<<<<<<Message/binary, " at line "/utf8>>/binary,
                (erlang:integer_to_binary(erlang:element(3, Error)))/binary>>/binary,
            ", column "/utf8>>/binary,
        (erlang:integer_to_binary(erlang:element(4, Error)))/binary>>.

-file("src/glexml.gleam", 758).
?DOC(" Get the value of the named attribute of an element.\n").
-spec attribute(element(), binary()) -> {ok, binary()} | {error, nil}.
attribute(Element, Name) ->
    attribute_value(erlang:element(3, Element), Name).

-file("src/glexml.gleam", 764).
?DOC(
    " Get the element children of an element, skipping text, comments, and\n"
    " processing instructions.\n"
).
-spec child_elements(element()) -> list(element()).
child_elements(Element) ->
    gleam@list:filter_map(erlang:element(4, Element), fun(Node) -> case Node of
                {element_node, Child} ->
                    {ok, Child};

                _ ->
                    {error, nil}
            end end).

-file("src/glexml.gleam", 774).
?DOC(" Get the element children of an element that have the given name.\n").
-spec children_named(element(), binary()) -> list(element()).
children_named(Element, Name) ->
    gleam@list:filter(
        child_elements(Element),
        fun(Child) -> erlang:element(2, Child) =:= Name end
    ).

-file("src/glexml.gleam", 779).
?DOC(" Get the first element child of an element with the given name.\n").
-spec first_child_named(element(), binary()) -> {ok, element()} | {error, nil}.
first_child_named(Element, Name) ->
    gleam@list:find_map(erlang:element(4, Element), fun(Node) -> case Node of
                {element_node, Child} ->
                    case erlang:element(2, Child) =:= Name of
                        true ->
                            {ok, Child};

                        false ->
                            {error, nil}
                    end;

                _ ->
                    {error, nil}
            end end).

-file("src/glexml.gleam", 801).
?DOC(
    " Get every descendant element with the given name, in document order.\n"
    "\n"
    " ```gleam\n"
    " glexml.descendants_named(package, \"item\")\n"
    " // -> every <item> anywhere below <package>\n"
    " ```\n"
).
-spec descendants_named(element(), binary()) -> list(element()).
descendants_named(Element, Name) ->
    gleam@list:flat_map(
        child_elements(Element),
        fun(Child) -> case erlang:element(2, Child) =:= Name of
                true ->
                    [Child | descendants_named(Child, Name)];

                false ->
                    descendants_named(Child, Name)
            end end
    ).

-file("src/glexml.gleam", 817).
?DOC(
    " Follow a path of element names from an element, taking the first matching\n"
    " child at each step.\n"
    "\n"
    " ```gleam\n"
    " glexml.at(package, [\"metadata\", \"dc:title\"])\n"
    " // -> Ok(the <dc:title> element inside <metadata>)\n"
    " ```\n"
).
-spec at(element(), list(binary())) -> {ok, element()} | {error, nil}.
at(Element, Path) ->
    case Path of
        [] ->
            {ok, Element};

        [Name | Rest] ->
            gleam@result:'try'(
                first_child_named(Element, Name),
                fun(Child) -> at(Child, Rest) end
            )
    end.

-file("src/glexml.gleam", 829).
?DOC(
    " Concatenate all text in an element and its descendants, in document\n"
    " order. Comments and processing instructions contribute nothing.\n"
).
-spec text_content(element()) -> binary().
text_content(Element) ->
    _pipe = erlang:element(4, Element),
    _pipe@1 = gleam@list:map(_pipe, fun(Node) -> case Node of
                {text_node, Text, _} ->
                    Text;

                {element_node, Child} ->
                    text_content(Child);

                {comment_node, _} ->
                    <<""/utf8>>;

                {processing_instruction_node, _, _} ->
                    <<""/utf8>>;

                {entity_reference_node, _} ->
                    <<""/utf8>>
            end end),
    erlang:list_to_binary(_pipe@1).

-file("src/glexml.gleam", 851).
?DOC(
    " The part of a qualified name after any namespace prefix.\n"
    "\n"
    " ```gleam\n"
    " glexml.local_name(\"dc:title\")\n"
    " // -> \"title\"\n"
    " glexml.local_name(\"title\")\n"
    " // -> \"title\"\n"
    " ```\n"
).
-spec local_name(binary()) -> binary().
local_name(Name) ->
    case gleam@string:split_once(Name, <<":"/utf8>>) of
        {ok, {_, Local}} ->
            Local;

        {error, nil} ->
            Name
    end.

-file("src/glexml.gleam", 864).
?DOC(
    " The namespace prefix of a qualified name, if it has one.\n"
    "\n"
    " ```gleam\n"
    " glexml.namespace_prefix(\"dc:title\")\n"
    " // -> Some(\"dc\")\n"
    " ```\n"
).
-spec namespace_prefix(binary()) -> gleam@option:option(binary()).
namespace_prefix(Name) ->
    case gleam@string:split_once(Name, <<":"/utf8>>) of
        {ok, {Prefix, _}} ->
            {some, Prefix};

        {error, nil} ->
            none
    end.

-file("src/glexml.gleam", 971).
-spec escape_text(binary()) -> binary().
escape_text(Text) ->
    _pipe = Text,
    _pipe@1 = gleam@string:replace(_pipe, <<"&"/utf8>>, <<"&amp;"/utf8>>),
    _pipe@2 = gleam@string:replace(_pipe@1, <<"<"/utf8>>, <<"&lt;"/utf8>>),
    gleam@string:replace(_pipe@2, <<">"/utf8>>, <<"&gt;"/utf8>>).

-file("src/glexml.gleam", 978).
-spec escape_attribute(binary()) -> binary().
escape_attribute(Value) ->
    _pipe = Value,
    _pipe@1 = escape_text(_pipe),
    gleam@string:replace(_pipe@1, <<"\""/utf8>>, <<"&quot;"/utf8>>).

-file("src/glexml.gleam", 958).
-spec node_to_tree(node_()) -> gleam@string_tree:string_tree().
node_to_tree(Node) ->
    case Node of
        {element_node, Element} ->
            element_to_tree(Element);

        {text_node, Text, _} ->
            gleam_stdlib:identity(escape_text(Text));

        {comment_node, Content} ->
            gleam_stdlib:identity(
                <<<<"<!--"/utf8, Content/binary>>/binary, "-->"/utf8>>
            );

        {processing_instruction_node, Target, <<""/utf8>>} ->
            gleam_stdlib:identity(
                <<<<"<?"/utf8, Target/binary>>/binary, "?>"/utf8>>
            );

        {processing_instruction_node, Target@1, Content@1} ->
            gleam_stdlib:identity(
                <<<<<<<<"<?"/utf8, Target@1/binary>>/binary, " "/utf8>>/binary,
                        Content@1/binary>>/binary,
                    "?>"/utf8>>
            );

        {entity_reference_node, Entity} ->
            gleam_stdlib:identity(
                <<<<"&"/utf8, Entity/binary>>/binary, ";"/utf8>>
            )
    end.

-file("src/glexml.gleam", 930).
-spec element_to_tree(element()) -> gleam@string_tree:string_tree().
element_to_tree(Element) ->
    {element, Name, Attributes, Children} = Element,
    Open = gleam@list:fold(
        Attributes,
        gleam_stdlib:identity(<<"<"/utf8, Name/binary>>),
        fun(Tree, Attribute) ->
            gleam@string_tree:append(
                Tree,
                <<<<<<<<" "/utf8, (erlang:element(2, Attribute))/binary>>/binary,
                            "=\""/utf8>>/binary,
                        (escape_attribute(erlang:element(3, Attribute)))/binary>>/binary,
                    "\""/utf8>>
            )
        end
    ),
    case Children of
        [] ->
            gleam@string_tree:append(Open, <<"/>"/utf8>>);

        _ ->
            _pipe = Children,
            _pipe@1 = gleam@list:fold(
                _pipe,
                gleam@string_tree:append(Open, <<">"/utf8>>),
                fun(Tree@1, Child) ->
                    gleam_stdlib:iodata_append(Tree@1, node_to_tree(Child))
                end
            ),
            gleam@string_tree:append(
                _pipe@1,
                <<<<"</"/utf8, Name/binary>>/binary, ">"/utf8>>
            )
    end.

-file("src/glexml.gleam", 924).
?DOC(" Serialise an element and its children to a string.\n").
-spec element_to_string(element()) -> binary().
element_to_string(Element) ->
    _pipe = Element,
    _pipe@1 = element_to_tree(_pipe),
    unicode:characters_to_binary(_pipe@1).

-file("src/glexml.gleam", 912).
?DOC(
    " Serialise a DOCTYPE declaration. The internal subset is not rendered,\n"
    " only the root name and any external identifier.\n"
).
-spec doctype_to_string(doctype()) -> binary().
doctype_to_string(Doctype) ->
    External = case erlang:element(3, Doctype) of
        none ->
            <<""/utf8>>;

        {some, {system, System}} ->
            <<<<" SYSTEM \""/utf8, System/binary>>/binary, "\""/utf8>>;

        {some, {public, Public, none}} ->
            <<<<" PUBLIC \""/utf8, Public/binary>>/binary, "\""/utf8>>;

        {some, {public, Public@1, {some, System@1}}} ->
            <<<<<<<<" PUBLIC \""/utf8, Public@1/binary>>/binary, "\" \""/utf8>>/binary,
                    System@1/binary>>/binary,
                "\""/utf8>>
    end,
    <<<<<<"<!DOCTYPE "/utf8, (erlang:element(2, Doctype))/binary>>/binary,
            External/binary>>/binary,
        ">"/utf8>>.

-file("src/glexml.gleam", 877).
?DOC(
    " Serialise a document to a string, including an XML declaration.\n"
    "\n"
    " Text and attribute values are escaped as needed. Elements with no\n"
    " children are rendered self-closing.\n"
).
-spec document_to_string(document()) -> binary().
document_to_string(Document) ->
    Encoding@1 = case erlang:element(3, Document) of
        {some, Encoding} ->
            <<<<" encoding=\""/utf8, Encoding/binary>>/binary, "\""/utf8>>;

        none ->
            <<""/utf8>>
    end,
    Standalone = case erlang:element(4, Document) of
        true ->
            <<" standalone=\"yes\""/utf8>>;

        false ->
            <<""/utf8>>
    end,
    Doctype@1 = case erlang:element(5, Document) of
        {some, Doctype} ->
            <<(doctype_to_string(Doctype))/binary, "\n"/utf8>>;

        none ->
            <<""/utf8>>
    end,
    Prolog = begin
        _pipe = erlang:element(6, Document),
        _pipe@1 = gleam@list:map(
            _pipe,
            fun(Node) ->
                <<(unicode:characters_to_binary(node_to_tree(Node)))/binary,
                    "\n"/utf8>>
            end
        ),
        erlang:list_to_binary(_pipe@1)
    end,
    Epilogue = begin
        _pipe@2 = erlang:element(8, Document),
        _pipe@3 = gleam@list:map(
            _pipe@2,
            fun(Node@1) ->
                <<"\n"/utf8,
                    (unicode:characters_to_binary(node_to_tree(Node@1)))/binary>>
            end
        ),
        erlang:list_to_binary(_pipe@3)
    end,
    <<<<<<<<<<<<<<<<<<"<?xml version=\""/utf8,
                                        (erlang:element(2, Document))/binary>>/binary,
                                    "\""/utf8>>/binary,
                                Encoding@1/binary>>/binary,
                            Standalone/binary>>/binary,
                        "?>\n"/utf8>>/binary,
                    Doctype@1/binary>>/binary,
                Prolog/binary>>/binary,
            (element_to_string(erlang:element(7, Document)))/binary>>/binary,
        Epilogue/binary>>.
