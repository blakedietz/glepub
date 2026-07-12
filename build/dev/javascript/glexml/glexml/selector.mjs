import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../gleam_stdlib/gleam/option.mjs";
import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $string from "../../gleam_stdlib/gleam/string.mjs";
import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  remainderInt,
  divideInt,
  isEqual,
} from "../gleam.mjs";
import * as $glexml from "../glexml.mjs";
import { ElementNode, TextNode } from "../glexml.mjs";

class Selector extends $CustomType {
  constructor(alternatives) {
    super();
    this.alternatives = alternatives;
  }
}

export class EmptySelector extends $CustomType {}
export const SelectorError$EmptySelector = () => new EmptySelector();
export const SelectorError$isEmptySelector = (value) =>
  value instanceof EmptySelector;

export class UnexpectedEndOfSelector extends $CustomType {}
export const SelectorError$UnexpectedEndOfSelector = () =>
  new UnexpectedEndOfSelector();
export const SelectorError$isUnexpectedEndOfSelector = (value) =>
  value instanceof UnexpectedEndOfSelector;

export class UnexpectedCharacter extends $CustomType {
  constructor(character) {
    super();
    this.character = character;
  }
}
export const SelectorError$UnexpectedCharacter = (character) =>
  new UnexpectedCharacter(character);
export const SelectorError$isUnexpectedCharacter = (value) =>
  value instanceof UnexpectedCharacter;
export const SelectorError$UnexpectedCharacter$character = (value) =>
  value.character;
export const SelectorError$UnexpectedCharacter$0 = (value) => value.character;

export class UnknownPseudoClass extends $CustomType {
  constructor(name) {
    super();
    this.name = name;
  }
}
export const SelectorError$UnknownPseudoClass = (name) =>
  new UnknownPseudoClass(name);
export const SelectorError$isUnknownPseudoClass = (value) =>
  value instanceof UnknownPseudoClass;
export const SelectorError$UnknownPseudoClass$name = (value) => value.name;
export const SelectorError$UnknownPseudoClass$0 = (value) => value.name;

export class InvalidNth extends $CustomType {
  constructor(argument) {
    super();
    this.argument = argument;
  }
}
export const SelectorError$InvalidNth = (argument) => new InvalidNth(argument);
export const SelectorError$isInvalidNth = (value) =>
  value instanceof InvalidNth;
export const SelectorError$InvalidNth$argument = (value) => value.argument;
export const SelectorError$InvalidNth$0 = (value) => value.argument;

class Complex extends $CustomType {
  constructor(key, trail) {
    super();
    this.key = key;
    this.trail = trail;
  }
}

class Descendant extends $CustomType {}

class Child extends $CustomType {}

class NextSibling extends $CustomType {}

class SubsequentSibling extends $CustomType {}

class Tag extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Class extends $CustomType {
  constructor(name) {
    super();
    this.name = name;
  }
}

class Id extends $CustomType {
  constructor(name) {
    super();
    this.name = name;
  }
}

class Attr extends $CustomType {
  constructor(name, value_test) {
    super();
    this.name = name;
    this.value_test = value_test;
  }
}

class FirstChild extends $CustomType {}

class LastChild extends $CustomType {}

class OnlyChild extends $CustomType {}

class Empty extends $CustomType {}

class Root extends $CustomType {}

class NthChild extends $CustomType {
  constructor(a, b) {
    super();
    this.a = a;
    this.b = b;
  }
}

class Not extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class ExactName extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class LocalName extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class AnyName extends $CustomType {}

class Present extends $CustomType {}

class Equals extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Includes extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class DashMatch extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class StartsWith extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class EndsWith extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Contains extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Context extends $CustomType {
  constructor(element, parent, preceding, following) {
    super();
    this.element = element;
    this.parent = parent;
    this.preceding = preceding;
    this.following = following;
  }
}

function unexpected(input) {
  let $ = $string.pop_grapheme(input);
  if ($ instanceof Ok) {
    let grapheme = $[0][0];
    return new Error(new UnexpectedCharacter(grapheme));
  } else {
    return new Error(new UnexpectedEndOfSelector());
  }
}

function skip_space(loop$input) {
  while (true) {
    let input = loop$input;
    let $ = input.charCodeAt(0);
    if ($ === 32) {
      let rest = input.slice(1);
      loop$input = rest;
    } else if ($ === 9) {
      let rest = input.slice(1);
      loop$input = rest;
    } else if ($ === 10) {
      let rest = input.slice(1);
      loop$input = rest;
    } else {
      return input;
    }
  }
}

/**
 * Parse the `an+b` argument of `:nth-child()`.
 * 
 * @ignore
 */
function parse_nth(argument) {
  let _block;
  let _pipe = argument;
  let _pipe$1 = $string.replace(_pipe, " ", "");
  _block = $string.lowercase(_pipe$1);
  let cleaned = _block;
  if (cleaned === "odd") {
    return new Ok([2, 1]);
  } else if (cleaned === "even") {
    return new Ok([2, 0]);
  } else {
    let $ = $string.split_once(cleaned, "n");
    if ($ instanceof Ok) {
      let a_part = $[0][0];
      let b_part = $[0][1];
      let _block$1;
      if (a_part === "") {
        _block$1 = new Ok(1);
      } else if (a_part === "+") {
        _block$1 = new Ok(1);
      } else if (a_part === "-") {
        _block$1 = new Ok(-1);
      } else if (a_part.charCodeAt(0) === 43) {
        let digits = a_part.slice(1);
        _block$1 = $int.parse(digits);
      } else {
        _block$1 = $int.parse(a_part);
      }
      let a = _block$1;
      let _block$2;
      if (b_part === "") {
        _block$2 = new Ok(0);
      } else if (b_part.charCodeAt(0) === 43) {
        let digits = b_part.slice(1);
        _block$2 = $int.parse(digits);
      } else {
        _block$2 = $int.parse(b_part);
      }
      let b = _block$2;
      if (a instanceof Ok && b instanceof Ok) {
        let a$1 = a[0];
        let b$1 = b[0];
        return new Ok([a$1, b$1]);
      } else {
        return new Error(new InvalidNth(argument));
      }
    } else {
      let $1 = $int.parse(cleaned);
      if ($1 instanceof Ok) {
        let b = $1[0];
        return new Ok([0, b]);
      } else {
        return new Error(new InvalidNth(argument));
      }
    }
  }
}

function is_ident_grapheme(grapheme, allow_colon) {
  if (grapheme === "-") {
    return true;
  } else if (grapheme === "_") {
    return true;
  } else if (grapheme === ":") {
    return allow_colon;
  } else {
    let $ = $string.to_utf_codepoints(grapheme);
    if ($ instanceof $Empty) {
      return true;
    } else {
      let $1 = $.tail;
      if ($1 instanceof $Empty) {
        let codepoint = $.head;
        let code = $string.utf_codepoint_to_int(codepoint);
        return ((((code >= 48) && (code <= 57)) || ((code >= 65) && (code <= 90))) || ((code >= 97) && (code <= 122))) || (code > 127);
      } else {
        return true;
      }
    }
  }
}

function do_parse_ident(loop$input, loop$allow_colon, loop$acc) {
  while (true) {
    let input = loop$input;
    let allow_colon = loop$allow_colon;
    let acc = loop$acc;
    let $ = $string.pop_grapheme(input);
    if ($ instanceof Ok) {
      let grapheme = $[0][0];
      let rest = $[0][1];
      let $1 = is_ident_grapheme(grapheme, allow_colon);
      if ($1) {
        loop$input = rest;
        loop$allow_colon = allow_colon;
        loop$acc = listPrepend(grapheme, acc);
      } else {
        return [$string.concat($list.reverse(acc)), input];
      }
    } else {
      return [$string.concat($list.reverse(acc)), input];
    }
  }
}

function parse_ident(input, allow_colon) {
  return do_parse_ident(input, allow_colon, toList([]));
}

function expect_ident(input, allow_colon) {
  let $ = parse_ident(input, allow_colon);
  let $1 = $[0];
  if ($1 === "") {
    return unexpected(input);
  } else {
    let name = $1;
    let rest = $[1];
    return new Ok([name, rest]);
  }
}

function parse_unquoted_value(loop$input, loop$acc) {
  while (true) {
    let input = loop$input;
    let acc = loop$acc;
    let $ = $string.pop_grapheme(input);
    if ($ instanceof Ok) {
      let grapheme = $[0][0];
      let rest = $[0][1];
      if (grapheme === "]") {
        return [$string.concat($list.reverse(acc)), input];
      } else if (grapheme === " ") {
        return [$string.concat($list.reverse(acc)), input];
      } else if (grapheme === "\t") {
        return [$string.concat($list.reverse(acc)), input];
      } else if (grapheme === "\n") {
        return [$string.concat($list.reverse(acc)), input];
      } else if (grapheme === "\"") {
        return [$string.concat($list.reverse(acc)), input];
      } else if (grapheme === "'") {
        return [$string.concat($list.reverse(acc)), input];
      } else {
        loop$input = rest;
        loop$acc = listPrepend(grapheme, acc);
      }
    } else {
      return [$string.concat($list.reverse(acc)), input];
    }
  }
}

function parse_attribute_value(input) {
  let $ = input.charCodeAt(0);
  if ($ === 34) {
    let rest = input.slice(1);
    let $1 = $string.split_once(rest, "\"");
    if ($1 instanceof Ok) {
      return $1;
    } else {
      return new Error(new UnexpectedEndOfSelector());
    }
  } else if ($ === 39) {
    let rest = input.slice(1);
    let $1 = $string.split_once(rest, "'");
    if ($1 instanceof Ok) {
      return $1;
    } else {
      return new Error(new UnexpectedEndOfSelector());
    }
  } else {
    let $1 = parse_unquoted_value(input, toList([]));
    let value = $1[0];
    let rest = $1[1];
    if (value === "") {
      return unexpected(input);
    } else {
      return new Ok([value, rest]);
    }
  }
}

function finish_attribute(input, name, value_test) {
  return $result.try$(
    parse_attribute_value(skip_space(input)),
    (_use0) => {
      let value = _use0[0];
      let input$1 = _use0[1];
      let input$2 = skip_space(input$1);
      if (input$2.charCodeAt(0) === 93) {
        let rest = input$2.slice(1);
        return new Ok([new Attr(name, value_test(value)), rest]);
      } else {
        return unexpected(input$2);
      }
    },
  );
}

function parse_attribute_name(input) {
  if (input.startsWith("*|")) {
    let rest = input.slice(2);
    return $result.try$(
      expect_ident(rest, false),
      (_use0) => {
        let name = _use0[0];
        let rest$1 = _use0[1];
        return new Ok([new LocalName(name), rest$1]);
      },
    );
  } else if (input.charCodeAt(0) === 124) {
    let rest = input.slice(1);
    return $result.try$(
      expect_ident(rest, false),
      (_use0) => {
        let name = _use0[0];
        let rest$1 = _use0[1];
        return new Ok([new LocalName(name), rest$1]);
      },
    );
  } else {
    return $result.try$(
      expect_ident(input, true),
      (_use0) => {
        let name = _use0[0];
        let rest = _use0[1];
        if (rest.startsWith("|=")) {
          return new Ok([new ExactName(name), rest]);
        } else if (rest.charCodeAt(0) === 124) {
          let after = rest.slice(1);
          return $result.try$(
            expect_ident(after, false),
            (_use0) => {
              let local = _use0[0];
              let after$1 = _use0[1];
              return new Ok([new ExactName((name + ":") + local), after$1]);
            },
          );
        } else {
          return new Ok([new ExactName(name), rest]);
        }
      },
    );
  }
}

/**
 * Parse an attribute selector. The input begins after the `[`.
 * 
 * @ignore
 */
function parse_attribute_selector(input) {
  let input$1 = skip_space(input);
  return $result.try$(
    parse_attribute_name(input$1),
    (_use0) => {
      let name = _use0[0];
      let input$2 = _use0[1];
      let input$3 = skip_space(input$2);
      let $ = input$3.charCodeAt(0);
      if ($ === 93) {
        let rest = input$3.slice(1);
        return new Ok([new Attr(name, new Present()), rest]);
      } else if (input$3.startsWith("~=")) {
        let rest = input$3.slice(2);
        return finish_attribute(
          rest,
          name,
          (var0) => { return new Includes(var0); },
        );
      } else if (input$3.startsWith("|=")) {
        let rest = input$3.slice(2);
        return finish_attribute(
          rest,
          name,
          (var0) => { return new DashMatch(var0); },
        );
      } else if (input$3.startsWith("^=")) {
        let rest = input$3.slice(2);
        return finish_attribute(
          rest,
          name,
          (var0) => { return new StartsWith(var0); },
        );
      } else if (input$3.startsWith("$=")) {
        let rest = input$3.slice(2);
        return finish_attribute(
          rest,
          name,
          (var0) => { return new EndsWith(var0); },
        );
      } else if (input$3.startsWith("*=")) {
        let rest = input$3.slice(2);
        return finish_attribute(
          rest,
          name,
          (var0) => { return new Contains(var0); },
        );
      } else if ($ === 61) {
        let rest = input$3.slice(1);
        return finish_attribute(
          rest,
          name,
          (var0) => { return new Equals(var0); },
        );
      } else {
        return unexpected(input$3);
      }
    },
  );
}

function parse_type_selector(input) {
  let $ = input.charCodeAt(0);
  if (input.startsWith("*|*")) {
    let rest = input.slice(3);
    return new Ok([toList([new Tag(new AnyName())]), rest]);
  } else if (input.startsWith("*|")) {
    let rest = input.slice(2);
    return $result.try$(
      expect_ident(rest, false),
      (_use0) => {
        let name = _use0[0];
        let rest$1 = _use0[1];
        return new Ok([toList([new Tag(new LocalName(name))]), rest$1]);
      },
    );
  } else if ($ === 42) {
    let rest = input.slice(1);
    return new Ok([toList([new Tag(new AnyName())]), rest]);
  } else if ($ === 124) {
    let rest = input.slice(1);
    return $result.try$(
      expect_ident(rest, false),
      (_use0) => {
        let name = _use0[0];
        let rest$1 = _use0[1];
        return new Ok([toList([new Tag(new LocalName(name))]), rest$1]);
      },
    );
  } else {
    let $1 = parse_ident(input, false);
    let name = $1[0];
    let rest = $1[1];
    if (name === "") {
      return new Ok([toList([]), input]);
    } else {
      if (rest.charCodeAt(0) === 124) {
        let after = rest.slice(1);
        return $result.try$(
          expect_ident(after, false),
          (_use0) => {
            let local = _use0[0];
            let after$1 = _use0[1];
            return new Ok(
              [toList([new Tag(new ExactName((name + ":") + local))]), after$1],
            );
          },
        );
      } else {
        return new Ok([toList([new Tag(new ExactName(name))]), rest]);
      }
    }
  }
}

function parse_not_list(input, acc) {
  let input$1 = skip_space(input);
  return $result.try$(
    parse_compound(input$1),
    (_use0) => {
      let compound = _use0[0];
      let input$2 = _use0[1];
      let input$3 = skip_space(input$2);
      let $ = input$3.charCodeAt(0);
      if ($ === 41) {
        let rest = input$3.slice(1);
        return new Ok(
          [new Not($list.reverse(listPrepend(compound, acc))), rest],
        );
      } else if ($ === 44) {
        let rest = input$3.slice(1);
        return parse_not_list(rest, listPrepend(compound, acc));
      } else {
        return unexpected(input$3);
      }
    },
  );
}

/**
 * Parse a pseudo-class. The input begins after the `:`.
 * 
 * @ignore
 */
function parse_pseudo_class(input) {
  return $result.try$(
    expect_ident(input, false),
    (_use0) => {
      let name = _use0[0];
      let input$1 = _use0[1];
      if (name === "first-child") {
        return new Ok([new FirstChild(), input$1]);
      } else if (name === "last-child") {
        return new Ok([new LastChild(), input$1]);
      } else if (name === "only-child") {
        return new Ok([new OnlyChild(), input$1]);
      } else if (name === "empty") {
        return new Ok([new Empty(), input$1]);
      } else if (name === "root") {
        return new Ok([new Root(), input$1]);
      } else if (name === "nth-child") {
        if (input$1.charCodeAt(0) === 40) {
          let rest = input$1.slice(1);
          let $ = $string.split_once(rest, ")");
          if ($ instanceof Ok) {
            let argument = $[0][0];
            let rest$1 = $[0][1];
            return $result.try$(
              parse_nth(argument),
              (_use0) => {
                let a = _use0[0];
                let b = _use0[1];
                return new Ok([new NthChild(a, b), rest$1]);
              },
            );
          } else {
            return new Error(new UnexpectedEndOfSelector());
          }
        } else {
          return unexpected(input$1);
        }
      } else if (name === "not") {
        if (input$1.charCodeAt(0) === 40) {
          let rest = input$1.slice(1);
          return parse_not_list(rest, toList([]));
        } else {
          return unexpected(input$1);
        }
      } else {
        return new Error(new UnknownPseudoClass(name));
      }
    },
  );
}

function parse_simple_suffixes(input, acc) {
  let $ = input.charCodeAt(0);
  if ($ === 46) {
    let rest = input.slice(1);
    return $result.try$(
      expect_ident(rest, false),
      (_use0) => {
        let name = _use0[0];
        let rest$1 = _use0[1];
        return parse_simple_suffixes(rest$1, listPrepend(new Class(name), acc));
      },
    );
  } else if ($ === 35) {
    let rest = input.slice(1);
    return $result.try$(
      expect_ident(rest, false),
      (_use0) => {
        let name = _use0[0];
        let rest$1 = _use0[1];
        return parse_simple_suffixes(rest$1, listPrepend(new Id(name), acc));
      },
    );
  } else if ($ === 91) {
    let rest = input.slice(1);
    return $result.try$(
      parse_attribute_selector(rest),
      (_use0) => {
        let part = _use0[0];
        let rest$1 = _use0[1];
        return parse_simple_suffixes(rest$1, listPrepend(part, acc));
      },
    );
  } else if ($ === 58) {
    let rest = input.slice(1);
    return $result.try$(
      parse_pseudo_class(rest),
      (_use0) => {
        let part = _use0[0];
        let rest$1 = _use0[1];
        return parse_simple_suffixes(rest$1, listPrepend(part, acc));
      },
    );
  } else {
    return new Ok([acc, input]);
  }
}

function parse_compound(input) {
  return $result.try$(
    parse_type_selector(input),
    (_use0) => {
      let parts = _use0[0];
      let rest = _use0[1];
      return $result.try$(
        parse_simple_suffixes(rest, parts),
        (_use0) => {
          let parts$1 = _use0[0];
          let rest$1 = _use0[1];
          if (parts$1 instanceof $Empty) {
            return unexpected(input);
          } else {
            return new Ok([$list.reverse(parts$1), rest$1]);
          }
        },
      );
    },
  );
}

function skip_space_counted(input) {
  let rest = skip_space(input);
  return [rest !== input, rest];
}

function parse_combined(input, combinator, key, trail) {
  let input$1 = skip_space(input);
  return $result.try$(
    parse_compound(input$1),
    (_use0) => {
      let compound = _use0[0];
      let input$2 = _use0[1];
      return parse_trail(
        input$2,
        compound,
        listPrepend([combinator, key], trail),
      );
    },
  );
}

function parse_trail(input, key, trail) {
  let $ = skip_space_counted(input);
  let spaced = $[0];
  let rest = $[1];
  let $1 = rest.charCodeAt(0);
  if (rest === "") {
    return new Ok([new Complex(key, trail), rest]);
  } else if ($1 === 44) {
    return new Ok([new Complex(key, trail), rest]);
  } else if ($1 === 62) {
    let next = rest.slice(1);
    return parse_combined(next, new Child(), key, trail);
  } else if ($1 === 43) {
    let next = rest.slice(1);
    return parse_combined(next, new NextSibling(), key, trail);
  } else if ($1 === 126) {
    let next = rest.slice(1);
    return parse_combined(next, new SubsequentSibling(), key, trail);
  } else {
    if (spaced) {
      return parse_combined(rest, new Descendant(), key, trail);
    } else {
      return unexpected(rest);
    }
  }
}

function parse_complex(input) {
  return $result.try$(
    parse_compound(input),
    (_use0) => {
      let compound = _use0[0];
      let input$1 = _use0[1];
      return parse_trail(input$1, compound, toList([]));
    },
  );
}

function parse_alternatives(input, acc) {
  let input$1 = skip_space(input);
  return $result.try$(
    parse_complex(input$1),
    (_use0) => {
      let complex = _use0[0];
      let input$2 = _use0[1];
      let input$3 = skip_space(input$2);
      if (input$3 === "") {
        return new Ok(new Selector($list.reverse(listPrepend(complex, acc))));
      } else if (input$3.charCodeAt(0) === 44) {
        let rest = input$3.slice(1);
        return parse_alternatives(rest, listPrepend(complex, acc));
      } else {
        return unexpected(input$3);
      }
    },
  );
}

/**
 * Parse a selector string.
 */
export function parse(input) {
  let $ = $string.trim(input);
  if ($ === "") {
    return new Error(new EmptySelector());
  } else {
    let input$1 = $;
    return parse_alternatives(input$1, toList([]));
  }
}

function root_context(element) {
  return new Context(element, new None(), toList([]), toList([]));
}

/**
 * Whether a 1-based child index satisfies an `an+b` pattern for some
 * non-negative integer n.
 * 
 * @ignore
 */
function nth_matches(a, b, index) {
  let distance = index - b;
  if (a === 0) {
    return distance === 0;
  } else {
    return ((remainderInt(distance, a)) === 0) && ((divideInt(distance, a)) >= 0);
  }
}

function includes_word(value, word) {
  let _pipe = value;
  let _pipe$1 = $string.split(_pipe, " ");
  return $list.any(
    _pipe$1,
    (candidate) => { return (candidate !== "") && (candidate === word); },
  );
}

function matches_attribute(value, value_test) {
  if (value_test instanceof Present) {
    return true;
  } else if (value_test instanceof Equals) {
    let expected = value_test[0];
    return value === expected;
  } else if (value_test instanceof Includes) {
    let word = value_test[0];
    return includes_word(value, word);
  } else if (value_test instanceof DashMatch) {
    let expected = value_test[0];
    return (value === expected) || $string.starts_with(value, expected + "-");
  } else if (value_test instanceof StartsWith) {
    let prefix = value_test[0];
    return (prefix !== "") && $string.starts_with(value, prefix);
  } else if (value_test instanceof EndsWith) {
    let suffix = value_test[0];
    return (suffix !== "") && $string.ends_with(value, suffix);
  } else {
    let inner = value_test[0];
    return (inner !== "") && $string.contains(value, inner);
  }
}

function matches_name(name, name_test) {
  if (name_test instanceof ExactName) {
    let expected = name_test[0];
    return name === expected;
  } else if (name_test instanceof LocalName) {
    let expected = name_test[0];
    return $glexml.local_name(name) === expected;
  } else {
    return true;
  }
}

function matches_simple(context, simple) {
  let element = context.element;
  if (simple instanceof Tag) {
    let name_test = simple[0];
    return matches_name(element.name, name_test);
  } else if (simple instanceof Class) {
    let class$ = simple.name;
    let $ = $glexml.attribute(element, "class");
    if ($ instanceof Ok) {
      let value = $[0];
      return includes_word(value, class$);
    } else {
      return false;
    }
  } else if (simple instanceof Id) {
    let id = simple.name;
    return isEqual($glexml.attribute(element, "id"), new Ok(id));
  } else if (simple instanceof Attr) {
    let name_test = simple.name;
    let value_test = simple.value_test;
    return $list.any(
      element.attributes,
      (attribute) => {
        return matches_name(attribute.name, name_test) && matches_attribute(
          attribute.value,
          value_test,
        );
      },
    );
  } else if (simple instanceof FirstChild) {
    return isEqual(context.preceding, toList([]));
  } else if (simple instanceof LastChild) {
    return isEqual(context.following, toList([]));
  } else if (simple instanceof OnlyChild) {
    return (isEqual(context.preceding, toList([]))) && (isEqual(
      context.following,
      toList([])
    ));
  } else if (simple instanceof Empty) {
    return !$list.any(
      element.children,
      (node) => {
        if (node instanceof ElementNode) {
          return true;
        } else if (node instanceof TextNode) {
          return true;
        } else if (node instanceof $glexml.EntityReferenceNode) {
          return true;
        } else {
          return false;
        }
      },
    );
  } else if (simple instanceof Root) {
    let $ = context.parent;
    if ($ instanceof Some) {
      return false;
    } else {
      return true;
    }
  } else if (simple instanceof NthChild) {
    let a = simple.a;
    let b = simple.b;
    return nth_matches(a, b, $list.length(context.preceding) + 1);
  } else {
    let compounds = simple[0];
    return !$list.any(
      compounds,
      (compound) => { return matches_compound(context, compound); },
    );
  }
}

function matches_compound(context, compound) {
  return $list.all(
    compound,
    (simple) => { return matches_simple(context, simple); },
  );
}

function previous_sibling(context) {
  let $ = context.preceding;
  if ($ instanceof $Empty) {
    return new None();
  } else {
    let previous = $.head;
    let older = $.tail;
    return new Some(
      new Context(
        previous,
        context.parent,
        older,
        listPrepend(context.element, context.following),
      ),
    );
  }
}

function matches_some_preceding_sibling(context, compound, rest) {
  let $ = previous_sibling(context);
  if ($ instanceof Some) {
    let previous = $[0];
    return (matches_compound(previous, compound) && matches_trail(
      previous,
      rest,
    )) || matches_some_preceding_sibling(previous, compound, rest);
  } else {
    return false;
  }
}

function matches_some_ancestor(context, compound, rest) {
  let $ = context.parent;
  if ($ instanceof Some) {
    let parent = $[0];
    return (matches_compound(parent, compound) && matches_trail(parent, rest)) || matches_some_ancestor(
      parent,
      compound,
      rest,
    );
  } else {
    return false;
  }
}

function matches_trail(context, trail) {
  if (trail instanceof $Empty) {
    return true;
  } else {
    let $ = trail.head[0];
    if ($ instanceof Descendant) {
      let rest = trail.tail;
      let compound = trail.head[1];
      return matches_some_ancestor(context, compound, rest);
    } else if ($ instanceof Child) {
      let rest = trail.tail;
      let compound = trail.head[1];
      let $1 = context.parent;
      if ($1 instanceof Some) {
        let parent = $1[0];
        return matches_compound(parent, compound) && matches_trail(parent, rest);
      } else {
        return false;
      }
    } else if ($ instanceof NextSibling) {
      let rest = trail.tail;
      let compound = trail.head[1];
      let $1 = previous_sibling(context);
      if ($1 instanceof Some) {
        let previous = $1[0];
        return matches_compound(previous, compound) && matches_trail(
          previous,
          rest,
        );
      } else {
        return false;
      }
    } else {
      let rest = trail.tail;
      let compound = trail.head[1];
      return matches_some_preceding_sibling(context, compound, rest);
    }
  }
}

function matches_complex(context, complex) {
  return matches_compound(context, complex.key) && matches_trail(
    context,
    complex.trail,
  );
}

function matches_context(context, selector) {
  let alternatives = selector.alternatives;
  return $list.any(
    alternatives,
    (complex) => { return matches_complex(context, complex); },
  );
}

function walk_children(
  loop$children,
  loop$parent,
  loop$preceding,
  loop$selector,
  loop$acc
) {
  while (true) {
    let children = loop$children;
    let parent = loop$parent;
    let preceding = loop$preceding;
    let selector = loop$selector;
    let acc = loop$acc;
    if (children instanceof $Empty) {
      return acc;
    } else {
      let child = children.head;
      let rest = children.tail;
      let context = new Context(child, new Some(parent), preceding, rest);
      let acc$1 = walk(context, selector, acc);
      loop$children = rest;
      loop$parent = parent;
      loop$preceding = listPrepend(child, preceding);
      loop$selector = selector;
      loop$acc = acc$1;
    }
  }
}

function walk(context, selector, acc) {
  let _block;
  let $ = matches_context(context, selector);
  if ($) {
    _block = listPrepend(context.element, acc);
  } else {
    _block = acc;
  }
  let acc$1 = _block;
  return walk_children(
    $glexml.child_elements(context.element),
    context,
    toList([]),
    selector,
    acc$1,
  );
}

/**
 * Find every element in the tree matching the selector, in document order.
 * The given element is part of the tree being searched, so `query(root,
 * ":root")` returns the root itself.
 */
export function query(element, selector) {
  let _pipe = walk(root_context(element), selector, toList([]));
  return $list.reverse(_pipe);
}

/**
 * Find the first element in document order matching the selector.
 */
export function query_first(element, selector) {
  let _pipe = query(element, selector);
  return $list.first(_pipe);
}

/**
 * Parse and run a selector in one step. Prefer `parse` + `query` when the
 * same selector is used repeatedly.
 */
export function select(element, selector) {
  return $result.try$(
    parse(selector),
    (selector) => { return new Ok(query(element, selector)); },
  );
}

/**
 * Whether the element itself matches the selector, treating it as the root
 * of its own tree.
 */
export function matches(element, selector) {
  return matches_context(root_context(element), selector);
}

/**
 * Convert a `SelectorError` into a human readable message.
 */
export function error_to_string(error) {
  if (error instanceof EmptySelector) {
    return "the selector is empty";
  } else if (error instanceof UnexpectedEndOfSelector) {
    return "the selector ended unexpectedly";
  } else if (error instanceof UnexpectedCharacter) {
    let character = error.character;
    return ("unexpected \"" + character) + "\" in selector";
  } else if (error instanceof UnknownPseudoClass) {
    let name = error.name;
    return ("unknown pseudo-class \":" + name) + "\"";
  } else {
    let argument = error.argument;
    return ("invalid :nth-child argument \"" + argument) + "\"";
  }
}
