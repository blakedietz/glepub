-module(glexml@dtd).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/glexml/dtd.gleam").
-export([content_model_to_string/1, validate/2, violation_to_string/1, with_default_attributes/2, standalone_violations/2]).
-export_type([violation/0, problem/0, state/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " Validate parsed XML documents against a DTD.\n"
    "\n"
    " `validate` checks a `glexml.Document` against the declarations of a\n"
    " `glexml.Dtd`: element content models, attribute declarations (including\n"
    " required attributes, fixed values, enumerations, and ID/IDREF\n"
    " integrity), and notation references. `with_default_attributes` applies\n"
    " the attribute defaults a validating processor would supply.\n"
    "\n"
    " ```gleam\n"
    " import glexml\n"
    " import glexml/dtd\n"
    "\n"
    " let assert Ok(document) = glexml.parse(source)\n"
    " let assert Some(doctype) = document.doctype\n"
    " case dtd.validate(document, doctype.declarations) {\n"
    "   [] -> // valid\n"
    "   violations -> // each one says what is wrong and where\n"
    " }\n"
    " ```\n"
).

-type violation() :: {violation, binary(), problem()}.

-type problem() :: {root_element_mismatch, binary(), binary()} |
    {undeclared_element, binary()} |
    {invalid_content, binary(), binary()} |
    {text_not_allowed, binary()} |
    {undeclared_attribute, binary(), binary()} |
    {missing_required_attribute, binary(), binary()} |
    {invalid_attribute_value, binary(), binary(), binary(), binary()} |
    {duplicate_id, binary()} |
    {unknown_id_reference, binary()} |
    {undeclared_entity, binary()} |
    {not_standalone, binary()} |
    {improper_pe_nesting, binary()} |
    {invalid_dtd_declaration, binary(), binary()}.

-type state() :: {state,
        list(violation()),
        gleam@set:set(binary()),
        list({binary(), binary()})}.

-file("src/glexml/dtd.gleam", 271).
-spec is_unparsed_entity(glexml:dtd(), binary()) -> boolean().
is_unparsed_entity(Dtd, Name) ->
    case gleam_stdlib:map_get(erlang:element(4, Dtd), Name) of
        {ok, {external_entity, _, {some, _}, _}} ->
            true;

        _ ->
            false
    end.

-file("src/glexml/dtd.gleam", 941).
-spec tokens(binary()) -> list(binary()).
tokens(Value) ->
    _pipe = Value,
    _pipe@1 = gleam@string:split(_pipe, <<" "/utf8>>),
    gleam@list:filter(_pipe@1, fun(Token) -> Token /= <<""/utf8>> end).

-file("src/glexml/dtd.gleam", 937).
?DOC(
    " Trim and collapse internal whitespace, the normalisation applied to\n"
    " tokenized attribute types before checking them.\n"
).
-spec collapse(binary()) -> binary().
collapse(Value) ->
    _pipe = tokens(Value),
    gleam@string:join(_pipe, <<" "/utf8>>).

-file("src/glexml/dtd.gleam", 968).
-spec is_name_start_code(integer()) -> boolean().
is_name_start_code(Code) ->
    (((((Code >= 97) andalso (Code =< 122)) orelse ((Code >= 65) andalso (Code
    =< 90)))
    orelse (Code =:= 95))
    orelse (Code =:= 58))
    orelse (Code > 127).

-file("src/glexml/dtd.gleam", 976).
-spec is_name_code(integer()) -> boolean().
is_name_code(Code) ->
    ((is_name_start_code(Code) orelse ((Code >= 48) andalso (Code =< 57)))
    orelse (Code =:= 45))
    orelse (Code =:= 46).

-file("src/glexml/dtd.gleam", 958).
-spec is_nmtoken(binary()) -> boolean().
is_nmtoken(Value) ->
    case gleam@string:to_utf_codepoints(Value) of
        [] ->
            false;

        Codepoints ->
            gleam@list:all(
                Codepoints,
                fun(Codepoint) ->
                    is_name_code(gleam_stdlib:identity(Codepoint))
                end
            )
    end.

-file("src/glexml/dtd.gleam", 947).
-spec is_name(binary()) -> boolean().
is_name(Value) ->
    case gleam@string:to_utf_codepoints(Value) of
        [] ->
            false;

        [First | Rest] ->
            is_name_start_code(gleam_stdlib:identity(First)) andalso gleam@list:all(
                Rest,
                fun(Codepoint) ->
                    is_name_code(gleam_stdlib:identity(Codepoint))
                end
            )
    end.

-file("src/glexml/dtd.gleam", 250).
-spec default_satisfies_kind(binary(), glexml:attribute_kind(), glexml:dtd()) -> boolean().
default_satisfies_kind(Value, Kind, Dtd) ->
    case Kind of
        cdata_attribute ->
            true;

        id_attribute ->
            true;

        id_ref_attribute ->
            is_name(collapse(Value));

        id_refs_attribute ->
            (tokens(Value) /= []) andalso gleam@list:all(
                tokens(Value),
                fun is_name/1
            );

        nmtoken_attribute ->
            is_nmtoken(collapse(Value));

        nmtokens_attribute ->
            (tokens(Value) /= []) andalso gleam@list:all(
                tokens(Value),
                fun is_nmtoken/1
            );

        {enumerated_attribute, Allowed} ->
            gleam@list:contains(Allowed, collapse(Value));

        {notation_attribute, Allowed} ->
            gleam@list:contains(Allowed, collapse(Value));

        entity_attribute ->
            is_unparsed_entity(Dtd, collapse(Value));

        entities_attribute ->
            (tokens(Value) /= []) andalso gleam@list:all(
                tokens(Value),
                fun(_capture) -> is_unparsed_entity(Dtd, _capture) end
            )
    end.

-file("src/glexml/dtd.gleam", 278).
-spec declaration_violation(binary(), binary()) -> violation().
declaration_violation(Element, Description) ->
    {violation, Element, {invalid_dtd_declaration, Element, Description}}.

-file("src/glexml/dtd.gleam", 202).
-spec validate_attribute_declaration(
    binary(),
    glexml:attribute_declaration(),
    glexml:dtd()
) -> list(violation()).
validate_attribute_declaration(Element, Declaration, Dtd) ->
    Named = fun(Description) ->
        declaration_violation(
            Element,
            <<<<<<"attribute \""/utf8, (erlang:element(2, Declaration))/binary>>/binary,
                    "\" "/utf8>>/binary,
                Description/binary>>
        )
    end,
    Id_rule = case {erlang:element(3, Declaration),
        erlang:element(4, Declaration)} of
        {id_attribute, {fixed, _}} ->
            [Named(
                    <<"is an ID, so its default must be #IMPLIED or #REQUIRED"/utf8>>
                )];

        {id_attribute, {default, _}} ->
            [Named(
                    <<"is an ID, so its default must be #IMPLIED or #REQUIRED"/utf8>>
                )];

        {_, _} ->
            []
    end,
    Tokens_rule = case erlang:element(3, Declaration) of
        {notation_attribute, Allowed} ->
            Undeclared = gleam@list:filter(
                Allowed,
                fun(Name) ->
                    not gleam@list:contains(erlang:element(6, Dtd), Name)
                end
            ),
            Missing = gleam@list:map(
                Undeclared,
                fun(Name@1) ->
                    Named(
                        <<<<"names the undeclared notation \""/utf8,
                                Name@1/binary>>/binary,
                            "\""/utf8>>
                    )
                end
            ),
            case gleam@list:unique(Allowed) =:= Allowed of
                true ->
                    Missing;

                false ->
                    [Named(<<"repeats a notation name"/utf8>>) | Missing]
            end;

        {enumerated_attribute, Allowed@1} ->
            case gleam@list:unique(Allowed@1) =:= Allowed@1 of
                true ->
                    [];

                false ->
                    [Named(<<"repeats an enumeration token"/utf8>>)]
            end;

        _ ->
            []
    end,
    Default_rule = case erlang:element(4, Declaration) of
        {fixed, Value} ->
            case default_satisfies_kind(
                Value,
                erlang:element(3, Declaration),
                Dtd
            ) of
                true ->
                    [];

                false ->
                    [Named(
                            <<"has a default value that does not match its type"/utf8>>
                        )]
            end;

        {default, Value} ->
            case default_satisfies_kind(
                Value,
                erlang:element(3, Declaration),
                Dtd
            ) of
                true ->
                    [];

                false ->
                    [Named(
                            <<"has a default value that does not match its type"/utf8>>
                        )]
            end;

        _ ->
            []
    end,
    lists:append([Id_rule, Tokens_rule, Default_rule]).

-file("src/glexml/dtd.gleam", 131).
?DOC(" Validity constraints on the DTD's own declarations.\n").
-spec validate_declarations(glexml:dtd()) -> list(violation()).
validate_declarations(Dtd) ->
    Nesting = begin
        _pipe = erlang:element(8, Dtd),
        _pipe@1 = lists:reverse(_pipe),
        gleam@list:map(
            _pipe@1,
            fun(Description) ->
                {violation,
                    <<"(dtd)"/utf8>>,
                    {improper_pe_nesting, Description}}
            end
        )
    end,
    Duplicates = begin
        _pipe@2 = erlang:element(7, Dtd),
        _pipe@3 = gleam@list:unique(_pipe@2),
        gleam@list:map(
            _pipe@3,
            fun(Name) ->
                declaration_violation(
                    Name,
                    <<"element declared more than once"/utf8>>
                )
            end
        )
    end,
    Entity_notations = begin
        _pipe@4 = maps:to_list(erlang:element(4, Dtd)),
        gleam@list:flat_map(
            _pipe@4,
            fun(Pair) -> case erlang:element(2, Pair) of
                    {external_entity, _, {some, Notation}, _} ->
                        case gleam@list:contains(
                            erlang:element(6, Dtd),
                            Notation
                        ) of
                            true ->
                                [];

                            false ->
                                [declaration_violation(
                                        erlang:element(1, Pair),
                                        <<<<"the entity's notation \""/utf8,
                                                Notation/binary>>/binary,
                                            "\" is not declared"/utf8>>
                                    )]
                        end;

                    _ ->
                        []
                end end
        )
    end,
    Mixed = begin
        _pipe@5 = maps:to_list(erlang:element(2, Dtd)),
        gleam@list:flat_map(
            _pipe@5,
            fun(Pair@1) -> case erlang:element(2, Pair@1) of
                    {mixed_content, Allowed} ->
                        case gleam@list:unique(Allowed) =:= Allowed of
                            true ->
                                [];

                            false ->
                                [declaration_violation(
                                        erlang:element(1, Pair@1),
                                        <<"the same element may not be named twice in mixed content"/utf8>>
                                    )]
                        end;

                    _ ->
                        []
                end end
        )
    end,
    Attributes = begin
        _pipe@6 = maps:to_list(erlang:element(3, Dtd)),
        gleam@list:flat_map(
            _pipe@6,
            fun(Pair@2) ->
                {Element, Declarations} = Pair@2,
                Ids = gleam@list:filter(
                    Declarations,
                    fun(D) -> erlang:element(3, D) =:= id_attribute end
                ),
                Multiple_ids = case Ids of
                    [_, _ | _] ->
                        [declaration_violation(
                                Element,
                                <<"an element may declare only one ID attribute"/utf8>>
                            )];

                    _ ->
                        []
                end,
                lists:append(
                    Multiple_ids,
                    gleam@list:flat_map(
                        Declarations,
                        fun(Declaration) ->
                            validate_attribute_declaration(
                                Element,
                                Declaration,
                                Dtd
                            )
                        end
                    )
                )
            end
        )
    end,
    lists:append([Nesting, Duplicates, Entity_notations, Mixed, Attributes]).

-file("src/glexml/dtd.gleam", 533).
-spec add(state(), binary(), problem()) -> state().
add(State, Path, Problem) ->
    {state,
        [{violation, Path, Problem} | erlang:element(2, State)],
        erlang:element(3, State),
        erlang:element(4, State)}.

-file("src/glexml/dtd.gleam", 877).
?DOC(
    " ENTITY and ENTITIES attributes must name declared unparsed entities:\n"
    " external entities with an `NDATA` notation.\n"
).
-spec validate_entity_tokens(
    binary(),
    binary(),
    binary(),
    list(binary()),
    binary(),
    glexml:dtd(),
    state()
) -> state().
validate_entity_tokens(Element, Attribute, Value, Names, Path, Dtd, State) ->
    gleam@list:fold(
        Names,
        State,
        fun(State@1, Name) ->
            case gleam_stdlib:map_get(erlang:element(4, Dtd), Name) of
                {ok, {external_entity, _, {some, _}, _}} ->
                    State@1;

                _ ->
                    add(
                        State@1,
                        Path,
                        {invalid_attribute_value,
                            Element,
                            Attribute,
                            Value,
                            <<"the name of a declared unparsed entity"/utf8>>}
                    )
            end
        end
    ).

-file("src/glexml/dtd.gleam", 774).
-spec validate_attribute_kind(
    binary(),
    binary(),
    binary(),
    glexml:attribute_kind(),
    binary(),
    glexml:dtd(),
    state()
) -> state().
validate_attribute_kind(Element, Attribute, Value, Kind, Path, Dtd, State) ->
    Invalid = fun(State@1, Expected) ->
        add(
            State@1,
            Path,
            {invalid_attribute_value, Element, Attribute, Value, Expected}
        )
    end,
    case Kind of
        cdata_attribute ->
            State;

        id_attribute ->
            Id = collapse(Value),
            case is_name(Id) of
                false ->
                    Invalid(State, <<"a single XML name"/utf8>>);

                true ->
                    case gleam@set:contains(erlang:element(3, State), Id) of
                        true ->
                            add(State, Path, {duplicate_id, Id});

                        false ->
                            {state,
                                erlang:element(2, State),
                                gleam@set:insert(erlang:element(3, State), Id),
                                erlang:element(4, State)}
                    end
            end;

        id_ref_attribute ->
            Id@1 = collapse(Value),
            case is_name(Id@1) of
                false ->
                    Invalid(State, <<"a single XML name"/utf8>>);

                true ->
                    {state,
                        erlang:element(2, State),
                        erlang:element(3, State),
                        [{Path, Id@1} | erlang:element(4, State)]}
            end;

        id_refs_attribute ->
            case tokens(Value) of
                [] ->
                    Invalid(State, <<"one or more XML names"/utf8>>);

                Ids ->
                    gleam@list:fold(
                        Ids,
                        State,
                        fun(State@2, Id@2) -> case is_name(Id@2) of
                                false ->
                                    Invalid(State@2, <<"XML names"/utf8>>);

                                true ->
                                    {state,
                                        erlang:element(2, State@2),
                                        erlang:element(3, State@2),
                                        [{Path, Id@2} |
                                            erlang:element(4, State@2)]}
                            end end
                    )
            end;

        entity_attribute ->
            validate_entity_tokens(
                Element,
                Attribute,
                Value,
                [collapse(Value)],
                Path,
                Dtd,
                State
            );

        entities_attribute ->
            case tokens(Value) of
                [] ->
                    Invalid(State, <<"one or more unparsed entity names"/utf8>>);

                Names ->
                    validate_entity_tokens(
                        Element,
                        Attribute,
                        Value,
                        Names,
                        Path,
                        Dtd,
                        State
                    )
            end;

        nmtoken_attribute ->
            case is_nmtoken(collapse(Value)) of
                true ->
                    State;

                false ->
                    Invalid(State, <<"a name token"/utf8>>)
            end;

        nmtokens_attribute ->
            case tokens(Value) of
                [] ->
                    Invalid(State, <<"one or more name tokens"/utf8>>);

                Names@1 ->
                    case gleam@list:all(Names@1, fun is_nmtoken/1) of
                        true ->
                            State;

                        false ->
                            Invalid(State, <<"name tokens"/utf8>>)
                    end
            end;

        {notation_attribute, Allowed} ->
            Name = collapse(Value),
            case gleam@list:contains(Allowed, Name) andalso gleam@list:contains(
                erlang:element(6, Dtd),
                Name
            ) of
                true ->
                    State;

                false ->
                    Invalid(
                        State,
                        <<"one of the declared notations "/utf8,
                            (gleam@string:join(Allowed, <<", "/utf8>>))/binary>>
                    )
            end;

        {enumerated_attribute, Allowed@1} ->
            case gleam@list:contains(Allowed@1, collapse(Value)) of
                true ->
                    State;

                false ->
                    Invalid(
                        State,
                        <<"one of "/utf8,
                            (gleam@string:join(Allowed@1, <<", "/utf8>>))/binary>>
                    )
            end
    end.

-file("src/glexml/dtd.gleam", 736).
-spec validate_attribute_value(
    binary(),
    binary(),
    binary(),
    glexml:attribute_declaration(),
    binary(),
    glexml:dtd(),
    state()
) -> state().
validate_attribute_value(
    Element,
    Attribute,
    Value,
    Declaration,
    Path,
    Dtd,
    State
) ->
    State@1 = case erlang:element(4, Declaration) of
        {fixed, Expected} ->
            case Value =:= Expected of
                true ->
                    State;

                false ->
                    add(
                        State,
                        Path,
                        {invalid_attribute_value,
                            Element,
                            Attribute,
                            Value,
                            <<<<"the fixed value \""/utf8, Expected/binary>>/binary,
                                "\""/utf8>>}
                    )
            end;

        _ ->
            State
    end,
    validate_attribute_kind(
        Element,
        Attribute,
        Value,
        erlang:element(3, Declaration),
        Path,
        Dtd,
        State@1
    ).

-file("src/glexml/dtd.gleam", 687).
-spec validate_attributes(glexml:element(), binary(), glexml:dtd(), state()) -> state().
validate_attributes(Element, Path, Dtd, State) ->
    Declarations = begin
        _pipe = gleam_stdlib:map_get(
            erlang:element(3, Dtd),
            erlang:element(2, Element)
        ),
        gleam@result:unwrap(_pipe, [])
    end,
    State@2 = gleam@list:fold(
        erlang:element(3, Element),
        State,
        fun(State@1, Attribute) ->
            {attribute, Name, Value} = Attribute,
            case gleam@list:find(
                Declarations,
                fun(D) -> erlang:element(2, D) =:= Name end
            ) of
                {error, nil} ->
                    add(
                        State@1,
                        Path,
                        {undeclared_attribute, erlang:element(2, Element), Name}
                    );

                {ok, Declaration} ->
                    validate_attribute_value(
                        erlang:element(2, Element),
                        Name,
                        Value,
                        Declaration,
                        Path,
                        Dtd,
                        State@1
                    )
            end
        end
    ),
    gleam@list:fold(
        Declarations,
        State@2,
        fun(State@3, Declaration@1) -> case erlang:element(4, Declaration@1) of
                required ->
                    case gleam@list:any(
                        erlang:element(3, Element),
                        fun(A) ->
                            erlang:element(2, A) =:= erlang:element(
                                2,
                                Declaration@1
                            )
                        end
                    ) of
                        true ->
                            State@3;

                        false ->
                            add(
                                State@3,
                                Path,
                                {missing_required_attribute,
                                    erlang:element(2, Element),
                                    erlang:element(2, Declaration@1)}
                            )
                    end;

                _ ->
                    State@3
            end end
    ).

-file("src/glexml/dtd.gleam", 510).
-spec occurrence_suffix(glexml:occurrence()) -> binary().
occurrence_suffix(Occurrence) ->
    case Occurrence of
        exactly_one ->
            <<""/utf8>>;

        zero_or_one ->
            <<"?"/utf8>>;

        zero_or_more ->
            <<"*"/utf8>>;

        one_or_more ->
            <<"+"/utf8>>
    end.

-file("src/glexml/dtd.gleam", 494).
-spec particle_to_string(glexml:particle()) -> binary().
particle_to_string(Particle) ->
    case Particle of
        {name_particle, Name, Occurrence} ->
            <<Name/binary, (occurrence_suffix(Occurrence))/binary>>;

        {sequence, Particles, Occurrence@1} ->
            <<<<<<"("/utf8,
                        (gleam@string:join(
                            gleam@list:map(Particles, fun particle_to_string/1),
                            <<", "/utf8>>
                        ))/binary>>/binary,
                    ")"/utf8>>/binary,
                (occurrence_suffix(Occurrence@1))/binary>>;

        {choice, Particles@1, Occurrence@2} ->
            <<<<<<"("/utf8,
                        (gleam@string:join(
                            gleam@list:map(
                                Particles@1,
                                fun particle_to_string/1
                            ),
                            <<" | "/utf8>>
                        ))/binary>>/binary,
                    ")"/utf8>>/binary,
                (occurrence_suffix(Occurrence@2))/binary>>
    end.

-file("src/glexml/dtd.gleam", 644).
?DOC(
    " Match the particle itself exactly once, ignoring its own occurrence\n"
    " suffix.\n"
).
-spec match_once(glexml:particle(), list(binary())) -> list(list(binary())).
match_once(Particle, Names) ->
    case Particle of
        {name_particle, Name, _} ->
            case Names of
                [First | Rest] ->
                    case First =:= Name of
                        true ->
                            [Rest];

                        false ->
                            []
                    end;

                [] ->
                    []
            end;

        {sequence, Particles, _} ->
            gleam@list:fold(
                Particles,
                [Names],
                fun(Frontier, Item) ->
                    _pipe = gleam@list:flat_map(
                        Frontier,
                        fun(Remaining) -> match_particle(Item, Remaining) end
                    ),
                    gleam@list:unique(_pipe)
                end
            );

        {choice, Particles@1, _} ->
            _pipe@1 = gleam@list:flat_map(
                Particles@1,
                fun(Option) -> match_particle(Option, Names) end
            ),
            gleam@list:unique(_pipe@1)
    end.

-file("src/glexml/dtd.gleam", 670).
?DOC(
    " Keep matching the particle against every frontier remainder until no new\n"
    " remainders appear.\n"
).
-spec match_repeatedly(
    glexml:particle(),
    list(list(binary())),
    list(list(binary()))
) -> list(list(binary())).
match_repeatedly(Particle, Frontier, Seen) ->
    Next = begin
        _pipe = gleam@list:flat_map(
            Frontier,
            fun(Names) -> match_once(Particle, Names) end
        ),
        gleam@list:unique(_pipe)
    end,
    New = gleam@list:filter(
        Next,
        fun(Names@1) -> not gleam@list:contains(Seen, Names@1) end
    ),
    case New of
        [] ->
            Seen;

        _ ->
            match_repeatedly(Particle, New, lists:append(Seen, New))
    end.

-file("src/glexml/dtd.gleam", 627).
?DOC(
    " Match a particle against a list of child element names, returning every\n"
    " possible remainder. The children match the particle exactly when `[]` is\n"
    " among the remainders.\n"
).
-spec match_particle(glexml:particle(), list(binary())) -> list(list(binary())).
match_particle(Particle, Names) ->
    case erlang:element(3, Particle) of
        exactly_one ->
            match_once(Particle, Names);

        zero_or_one ->
            _pipe = [Names | match_once(Particle, Names)],
            gleam@list:unique(_pipe);

        zero_or_more ->
            match_repeatedly(Particle, [Names], [Names]);

        one_or_more ->
            First = begin
                _pipe@1 = match_once(Particle, Names),
                gleam@list:unique(_pipe@1)
            end,
            match_repeatedly(Particle, First, First)
    end.

-file("src/glexml/dtd.gleam", 615).
?DOC(
    " In element-only content, text is allowed only as separator whitespace:\n"
    " it must be whitespace and it must be literal (not from a CDATA section\n"
    " or a character reference recognised in content).\n"
).
-spec has_significant_text(glexml:element()) -> boolean().
has_significant_text(Element) ->
    gleam@list:any(erlang:element(4, Element), fun(Node) -> case Node of
                {text_node, Text, Literal} ->
                    (gleam@string:trim(Text) /= <<""/utf8>>) orelse not Literal;

                _ ->
                    false
            end end).

-file("src/glexml/dtd.gleam", 483).
?DOC(
    " Render a content model the way it would appear in an `<!ELEMENT>`\n"
    " declaration, e.g. `(head, body)` or `(#PCDATA | em)*`.\n"
).
-spec content_model_to_string(glexml:content_model()) -> binary().
content_model_to_string(Model) ->
    case Model of
        empty_content ->
            <<"EMPTY"/utf8>>;

        any_content ->
            <<"ANY"/utf8>>;

        {mixed_content, []} ->
            <<"(#PCDATA)"/utf8>>;

        {mixed_content, Allowed} ->
            <<<<"(#PCDATA | "/utf8,
                    (gleam@string:join(Allowed, <<" | "/utf8>>))/binary>>/binary,
                ")*"/utf8>>;

        {element_content, Particle} ->
            particle_to_string(Particle)
    end.

-file("src/glexml/dtd.gleam", 560).
-spec validate_content(glexml:element(), binary(), glexml:dtd(), state()) -> state().
validate_content(Element, Path, Dtd, State) ->
    case gleam_stdlib:map_get(
        erlang:element(2, Dtd),
        erlang:element(2, Element)
    ) of
        {error, nil} ->
            add(State, Path, {undeclared_element, erlang:element(2, Element)});

        {ok, any_content} ->
            State;

        {ok, empty_content} ->
            case erlang:element(4, Element) of
                [] ->
                    State;

                _ ->
                    add(
                        State,
                        Path,
                        {invalid_content,
                            erlang:element(2, Element),
                            <<"EMPTY"/utf8>>}
                    )
            end;

        {ok, {mixed_content, Allowed}} ->
            Stray = begin
                _pipe = glexml:child_elements(Element),
                gleam@list:filter(
                    _pipe,
                    fun(Child) ->
                        not gleam@list:contains(
                            Allowed,
                            erlang:element(2, Child)
                        )
                    end
                )
            end,
            case Stray of
                [] ->
                    State;

                _ ->
                    add(
                        State,
                        Path,
                        {invalid_content,
                            erlang:element(2, Element),
                            content_model_to_string({mixed_content, Allowed})}
                    )
            end;

        {ok, {element_content, Particle}} ->
            State@1 = case has_significant_text(Element) of
                true ->
                    add(
                        State,
                        Path,
                        {text_not_allowed, erlang:element(2, Element)}
                    );

                false ->
                    State
            end,
            Names = begin
                _pipe@1 = glexml:child_elements(Element),
                gleam@list:map(
                    _pipe@1,
                    fun(Child@1) -> erlang:element(2, Child@1) end
                )
            end,
            case gleam@list:contains(match_particle(Particle, Names), []) of
                true ->
                    State@1;

                false ->
                    add(
                        State@1,
                        Path,
                        {invalid_content,
                            erlang:element(2, Element),
                            particle_to_string(Particle)}
                    )
            end
    end.

-file("src/glexml/dtd.gleam", 537).
-spec validate_element(glexml:element(), binary(), glexml:dtd(), state()) -> state().
validate_element(Element, Path, Dtd, State) ->
    State@1 = validate_content(Element, Path, Dtd, State),
    State@2 = validate_attributes(Element, Path, Dtd, State@1),
    State@4 = gleam@list:fold(
        erlang:element(4, Element),
        State@2,
        fun(State@3, Node) -> case Node of
                {entity_reference_node, Entity} ->
                    add(State@3, Path, {undeclared_entity, Entity});

                _ ->
                    State@3
            end end
    ),
    gleam@list:fold(
        glexml:child_elements(Element),
        State@4,
        fun(State@5, Child) ->
            validate_element(
                Child,
                <<<<Path/binary, "/"/utf8>>/binary,
                    (erlang:element(2, Child))/binary>>,
                Dtd,
                State@5
            )
        end
    ).

-file("src/glexml/dtd.gleam", 99).
?DOC(
    " Validate a document against a DTD, returning every violation found. An\n"
    " empty list means the document is valid.\n"
    "\n"
    " The DTD is passed separately from the document so you can decide what to\n"
    " validate against: the internal subset (`doctype.declarations`), a loaded\n"
    " external DTD (`glexml.parse_dtd`), or both merged with\n"
    " `glexml.merge_dtds`.\n"
).
-spec validate(glexml:document(), glexml:dtd()) -> list(violation()).
validate(Document, Dtd) ->
    Root = erlang:element(7, Document),
    State = {state, [], gleam@set:new(), []},
    State@1 = case erlang:element(5, Document) of
        {some, Doctype} ->
            case erlang:element(2, Doctype) =:= erlang:element(2, Root) of
                true ->
                    State;

                false ->
                    add(
                        State,
                        erlang:element(2, Root),
                        {root_element_mismatch,
                            erlang:element(2, Doctype),
                            erlang:element(2, Root)}
                    )
            end;

        _ ->
            State
    end,
    State@2 = validate_element(Root, erlang:element(2, Root), Dtd, State@1),
    Unresolved = begin
        _pipe = erlang:element(4, State@2),
        _pipe@1 = lists:reverse(_pipe),
        _pipe@2 = gleam@list:filter(
            _pipe@1,
            fun(Reference) ->
                not gleam@set:contains(
                    erlang:element(3, State@2),
                    erlang:element(2, Reference)
                )
            end
        ),
        gleam@list:map(
            _pipe@2,
            fun(Reference@1) ->
                {violation,
                    erlang:element(1, Reference@1),
                    {unknown_id_reference, erlang:element(2, Reference@1)}}
            end
        )
    end,
    lists:append(
        [validate_declarations(Dtd),
            lists:reverse(erlang:element(2, State@2)),
            Unresolved]
    ).

-file("src/glexml/dtd.gleam", 283).
?DOC(" Render a violation as a human readable message.\n").
-spec violation_to_string(violation()) -> binary().
violation_to_string(Violation) ->
    Message = case erlang:element(3, Violation) of
        {root_element_mismatch, Expected, Found} ->
            <<<<<<<<"the root element is <"/utf8, Found/binary>>/binary,
                        "> but the DOCTYPE names \""/utf8>>/binary,
                    Expected/binary>>/binary,
                "\""/utf8>>;

        {undeclared_element, Element} ->
            <<<<"element <"/utf8, Element/binary>>/binary,
                "> is not declared"/utf8>>;

        {invalid_content, Element@1, Model} ->
            <<<<<<"the content of <"/utf8, Element@1/binary>>/binary,
                    "> does not match "/utf8>>/binary,
                Model/binary>>;

        {text_not_allowed, Element@2} ->
            <<<<"element <"/utf8, Element@2/binary>>/binary,
                "> may not contain text"/utf8>>;

        {undeclared_attribute, Element@3, Attribute} ->
            <<<<<<<<"attribute \""/utf8, Attribute/binary>>/binary,
                        "\" is not declared on <"/utf8>>/binary,
                    Element@3/binary>>/binary,
                ">"/utf8>>;

        {missing_required_attribute, Element@4, Attribute@1} ->
            <<<<<<<<"element <"/utf8, Element@4/binary>>/binary,
                        "> is missing the required attribute \""/utf8>>/binary,
                    Attribute@1/binary>>/binary,
                "\""/utf8>>;

        {invalid_attribute_value, Element@5, Attribute@2, Value, Expected@1} ->
            <<<<<<<<<<<<<<"the value \""/utf8, Value/binary>>/binary,
                                    "\" of attribute \""/utf8>>/binary,
                                Attribute@2/binary>>/binary,
                            "\" on <"/utf8>>/binary,
                        Element@5/binary>>/binary,
                    "> is not valid: expected "/utf8>>/binary,
                Expected@1/binary>>;

        {duplicate_id, Id} ->
            <<<<"the ID \""/utf8, Id/binary>>/binary,
                "\" is used more than once"/utf8>>;

        {unknown_id_reference, Id@1} ->
            <<<<"no element has the ID \""/utf8, Id@1/binary>>/binary,
                "\""/utf8>>;

        {undeclared_entity, Entity} ->
            <<<<"the entity \"&"/utf8, Entity/binary>>/binary,
                ";\" is not declared"/utf8>>;

        {not_standalone, Description} ->
            <<"the document says standalone=\"yes\" but "/utf8,
                Description/binary>>;

        {improper_pe_nesting, Description@1} ->
            Description@1;

        {invalid_dtd_declaration, Element@6, Description@2} ->
            <<<<<<"in the declarations for <"/utf8, Element@6/binary>>/binary,
                    ">: "/utf8>>/binary,
                Description@2/binary>>
    end,
    <<<<<<Message/binary, " (at "/utf8>>/binary,
            (erlang:element(2, Violation))/binary>>/binary,
        ")"/utf8>>.

-file("src/glexml/dtd.gleam", 906).
-spec element_with_defaults(glexml:element(), glexml:dtd()) -> glexml:element().
element_with_defaults(Element, Dtd) ->
    Declarations = begin
        _pipe = gleam_stdlib:map_get(
            erlang:element(3, Dtd),
            erlang:element(2, Element)
        ),
        gleam@result:unwrap(_pipe, [])
    end,
    Missing = gleam@list:filter_map(
        Declarations,
        fun(Declaration) -> case erlang:element(4, Declaration) of
                {fixed, Value} ->
                    case gleam@list:any(
                        erlang:element(3, Element),
                        fun(A) ->
                            erlang:element(2, A) =:= erlang:element(
                                2,
                                Declaration
                            )
                        end
                    ) of
                        true ->
                            {error, nil};

                        false ->
                            {ok,
                                {attribute,
                                    erlang:element(2, Declaration),
                                    Value}}
                    end;

                {default, Value} ->
                    case gleam@list:any(
                        erlang:element(3, Element),
                        fun(A) ->
                            erlang:element(2, A) =:= erlang:element(
                                2,
                                Declaration
                            )
                        end
                    ) of
                        true ->
                            {error, nil};

                        false ->
                            {ok,
                                {attribute,
                                    erlang:element(2, Declaration),
                                    Value}}
                    end;

                _ ->
                    {error, nil}
            end end
    ),
    Children = gleam@list:map(
        erlang:element(4, Element),
        fun(Node) -> case Node of
                {element_node, Child} ->
                    {element_node, element_with_defaults(Child, Dtd)};

                Other ->
                    Other
            end end
    ),
    {element,
        erlang:element(2, Element),
        lists:append(erlang:element(3, Element), Missing),
        Children}.

-file("src/glexml/dtd.gleam", 329).
?DOC(
    " Return a copy of the document with attribute defaults from the DTD\n"
    " filled in: any attribute declared with a default or `#FIXED` value that\n"
    " is absent from an element is added, as a validating XML processor would.\n"
).
-spec with_default_attributes(glexml:document(), glexml:dtd()) -> glexml:document().
with_default_attributes(Document, Dtd) ->
    {document,
        erlang:element(2, Document),
        erlang:element(3, Document),
        erlang:element(4, Document),
        erlang:element(5, Document),
        erlang:element(6, Document),
        element_with_defaults(erlang:element(7, Document), Dtd),
        erlang:element(8, Document)}.

-file("src/glexml/dtd.gleam", 369).
-spec standalone_check(
    glexml:element(),
    binary(),
    glexml:dtd(),
    glexml:dtd(),
    list(violation())
) -> list(violation()).
standalone_check(Element, Path, Internal, External, Violations) ->
    External_attributes = begin
        _pipe = gleam_stdlib:map_get(
            erlang:element(3, External),
            erlang:element(2, Element)
        ),
        _pipe@1 = gleam@result:unwrap(_pipe, []),
        gleam@list:filter(
            _pipe@1,
            fun(Declaration) ->
                Internal_declarations = begin
                    _pipe@2 = gleam_stdlib:map_get(
                        erlang:element(3, Internal),
                        erlang:element(2, Element)
                    ),
                    gleam@result:unwrap(_pipe@2, [])
                end,
                not gleam@list:any(
                    Internal_declarations,
                    fun(D) ->
                        erlang:element(2, D) =:= erlang:element(2, Declaration)
                    end
                )
            end
        )
    end,
    Violations@2 = gleam@list:fold(
        External_attributes,
        Violations,
        fun(Violations@1, Declaration@1) ->
            Specified = gleam@list:any(
                erlang:element(3, Element),
                fun(A) ->
                    erlang:element(2, A) =:= erlang:element(2, Declaration@1)
                end
            ),
            case {erlang:element(4, Declaration@1), Specified} of
                {{default, _}, false} ->
                    [{violation,
                            Path,
                            {not_standalone,
                                <<<<<<<<"the attribute \""/utf8,
                                                (erlang:element(
                                                    2,
                                                    Declaration@1
                                                ))/binary>>/binary,
                                            "\" on <"/utf8>>/binary,
                                        (erlang:element(2, Element))/binary>>/binary,
                                    "> takes its default from an external declaration"/utf8>>}} |
                        Violations@1];

                {{fixed, _}, false} ->
                    [{violation,
                            Path,
                            {not_standalone,
                                <<<<<<<<"the attribute \""/utf8,
                                                (erlang:element(
                                                    2,
                                                    Declaration@1
                                                ))/binary>>/binary,
                                            "\" on <"/utf8>>/binary,
                                        (erlang:element(2, Element))/binary>>/binary,
                                    "> takes its default from an external declaration"/utf8>>}} |
                        Violations@1];

                {_, _} ->
                    Violations@1
            end
        end
    ),
    Violations@4 = gleam@list:fold(
        erlang:element(3, Element),
        Violations@2,
        fun(Violations@3, Attribute) ->
            case gleam@list:find(
                External_attributes,
                fun(D@1) ->
                    erlang:element(2, D@1) =:= erlang:element(2, Attribute)
                end
            ) of
                {ok, Declaration@2} ->
                    case (erlang:element(3, Declaration@2) /= cdata_attribute)
                    andalso (collapse(erlang:element(3, Attribute)) /= erlang:element(
                        3,
                        Attribute
                    )) of
                        true ->
                            [{violation,
                                    Path,
                                    {not_standalone,
                                        <<<<<<<<<<"the value of attribute \""/utf8,
                                                            (erlang:element(
                                                                2,
                                                                Attribute
                                                            ))/binary>>/binary,
                                                        "\" on <"/utf8>>/binary,
                                                    (erlang:element(2, Element))/binary>>/binary,
                                                "> is changed by the normalisation its external "/utf8>>/binary,
                                            "declaration requires"/utf8>>}} |
                                Violations@3];

                        false ->
                            Violations@3
                    end;

                {error, nil} ->
                    Violations@3
            end
        end
    ),
    Externally_declared_model = not gleam@dict:has_key(
        erlang:element(2, Internal),
        erlang:element(2, Element)
    )
    andalso case gleam_stdlib:map_get(
        erlang:element(2, External),
        erlang:element(2, Element)
    ) of
        {ok, {element_content, _}} ->
            true;

        _ ->
            false
    end,
    Has_whitespace_content = gleam@list:any(
        erlang:element(4, Element),
        fun(Node) -> case Node of
                {text_node, Text, _} ->
                    (gleam@string:trim(Text) =:= <<""/utf8>>) andalso (Text /= <<""/utf8>>);

                _ ->
                    false
            end end
    ),
    Violations@5 = case Externally_declared_model andalso Has_whitespace_content of
        true ->
            [{violation,
                    Path,
                    {not_standalone,
                        <<<<"whitespace occurs in the content of <"/utf8,
                                (erlang:element(2, Element))/binary>>/binary,
                            ">, whose element content model is declared externally"/utf8>>}} |
                Violations@4];

        false ->
            Violations@4
    end,
    gleam@list:fold(
        glexml:child_elements(Element),
        Violations@5,
        fun(Violations@6, Child) ->
            standalone_check(
                Child,
                <<<<Path/binary, "/"/utf8>>/binary,
                    (erlang:element(2, Child))/binary>>,
                Internal,
                External,
                Violations@6
            )
        end
    ).

-file("src/glexml/dtd.gleam", 346).
?DOC(
    " Check the Standalone Document Declaration validity constraint: a\n"
    " document declaring `standalone=\"yes\"` may not depend on markup\n"
    " declarations made outside it. Pass the external declarations (an\n"
    " external subset loaded with `glexml.parse_dtd`, and any external\n"
    " parameter entities); declarations also made in the document's own\n"
    " internal subset do not count as external.\n"
    "\n"
    " Violations are reported when the document is standalone and, per\n"
    " section 2.9 of the specification: an element lacks an attribute whose\n"
    " default value is declared externally; a specified attribute value\n"
    " would be changed by the normalisation its externally declared type\n"
    " requires; or whitespace occurs directly in the content of an element\n"
    " whose element-only content model is declared externally.\n"
).
-spec standalone_violations(glexml:document(), glexml:dtd()) -> list(violation()).
standalone_violations(Document, External) ->
    case erlang:element(4, Document) of
        false ->
            [];

        true ->
            Internal = case erlang:element(5, Document) of
                {some, Doctype} ->
                    erlang:element(4, Doctype);

                _ ->
                    glexml:empty_dtd()
            end,
            _pipe = standalone_check(
                erlang:element(7, Document),
                erlang:element(2, erlang:element(7, Document)),
                Internal,
                External,
                []
            ),
            lists:reverse(_pipe)
    end.
