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
} from "../gleam.mjs";
import * as $glepub from "../glepub.mjs";

export class Step extends $CustomType {
  constructor(index, assertion) {
    super();
    this.index = index;
    this.assertion = assertion;
  }
}
export const Step$Step = (index, assertion) => new Step(index, assertion);
export const Step$isStep = (value) => value instanceof Step;
export const Step$Step$index = (value) => value.index;
export const Step$Step$0 = (value) => value.index;
export const Step$Step$assertion = (value) => value.assertion;
export const Step$Step$1 = (value) => value.assertion;

export class Cfi extends $CustomType {
  constructor(parts, offset) {
    super();
    this.parts = parts;
    this.offset = offset;
  }
}
export const Cfi$Cfi = (parts, offset) => new Cfi(parts, offset);
export const Cfi$isCfi = (value) => value instanceof Cfi;
export const Cfi$Cfi$parts = (value) => value.parts;
export const Cfi$Cfi$0 = (value) => value.parts;
export const Cfi$Cfi$offset = (value) => value.offset;
export const Cfi$Cfi$1 = (value) => value.offset;

function finish(parts, steps, offset) {
  if (steps instanceof $Empty) {
    if (parts instanceof $Empty) {
      return new Error(undefined);
    } else {
      return new Error(undefined);
    }
  } else {
    return new Ok(
      new Cfi($list.reverse(listPrepend($list.reverse(steps), parts)), offset),
    );
  }
}

function span_digits(loop$text, loop$taken) {
  while (true) {
    let text = loop$text;
    let taken = loop$taken;
    let $ = $string.pop_grapheme(text);
    if ($ instanceof Ok) {
      let grapheme = $[0][0];
      let rest = $[0][1];
      if (grapheme === "0") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else if (grapheme === "1") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else if (grapheme === "2") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else if (grapheme === "3") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else if (grapheme === "4") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else if (grapheme === "5") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else if (grapheme === "6") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else if (grapheme === "7") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else if (grapheme === "8") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else if (grapheme === "9") {
        loop$text = rest;
        loop$taken = taken + grapheme;
      } else {
        return [taken, text];
      }
    } else {
      return [taken, text];
    }
  }
}

function take_int(text) {
  let $ = span_digits(text, "");
  let digits = $[0];
  let rest = $[1];
  return $result.try$(
    $int.parse(digits),
    (number) => { return new Ok([number, rest]); },
  );
}

function span_assertion(loop$text, loop$taken) {
  while (true) {
    let text = loop$text;
    let taken = loop$taken;
    let $ = $string.pop_grapheme(text);
    if ($ instanceof Ok) {
      let $1 = $[0][0];
      if ($1 === "]") {
        let rest = $[0][1];
        return new Ok([taken, rest]);
      } else if ($1 === "^") {
        let rest = $[0][1];
        let $2 = $string.pop_grapheme(rest);
        if ($2 instanceof Ok) {
          let escaped = $2[0][0];
          let rest$1 = $2[0][1];
          loop$text = rest$1;
          loop$taken = taken + escaped;
        } else {
          return $2;
        }
      } else {
        let grapheme = $1;
        let rest = $[0][1];
        loop$text = rest;
        loop$taken = taken + grapheme;
      }
    } else {
      return $;
    }
  }
}

function take_assertion(text) {
  if (text.charCodeAt(0) === 91) {
    let rest = text.slice(1);
    return $result.try$(
      span_assertion(rest, ""),
      (_use0) => {
        let assertion = _use0[0];
        let rest$1 = _use0[1];
        return new Ok([new Some(assertion), rest$1]);
      },
    );
  } else {
    return new Ok([new None(), text]);
  }
}

function parse_parts(loop$text, loop$parts, loop$steps) {
  while (true) {
    let text = loop$text;
    let parts = loop$parts;
    let steps = loop$steps;
    let $ = text.charCodeAt(0);
    if (text === "") {
      return finish(parts, steps, new None());
    } else if ($ === 33) {
      let rest = text.slice(1);
      if (steps instanceof $Empty) {
        return new Error(undefined);
      } else {
        let steps$1 = steps;
        loop$text = rest;
        loop$parts = listPrepend($list.reverse(steps$1), parts);
        loop$steps = toList([]);
      }
    } else if ($ === 47) {
      let rest = text.slice(1);
      return $result.try$(
        take_int(rest),
        (_use0) => {
          let index = _use0[0];
          let rest$1 = _use0[1];
          return $result.try$(
            take_assertion(rest$1),
            (_use0) => {
              let assertion = _use0[0];
              let rest$2 = _use0[1];
              return parse_parts(
                rest$2,
                parts,
                listPrepend(new Step(index, assertion), steps),
              );
            },
          );
        },
      );
    } else if ($ === 58) {
      let rest = text.slice(1);
      return $result.try$(
        take_int(rest),
        (_use0) => {
          let offset = _use0[0];
          let rest$1 = _use0[1];
          if (rest$1 === "") {
            return finish(parts, steps, new Some(offset));
          } else {
            return new Error(undefined);
          }
        },
      );
    } else {
      return new Error(undefined);
    }
  }
}

/**
 * Parse an `epubcfi(...)` string.
 */
export function parse(text) {
  let $ = $string.starts_with(text, "epubcfi(");
  let $1 = $string.ends_with(text, ")");
  if ($ && $1) {
    let _pipe = text;
    let _pipe$1 = $string.drop_start(_pipe, 8);
    let _pipe$2 = $string.drop_end(_pipe$1, 1);
    return parse_parts(_pipe$2, toList([]), toList([]));
  } else {
    return new Error(undefined);
  }
}

function escape_assertion(assertion) {
  let _pipe = toList(["^", "[", "]", "(", ")", ",", ";", "="]);
  return $list.fold(
    _pipe,
    assertion,
    (text, special) => { return $string.replace(text, special, "^" + special); },
  );
}

function step_to_string(step) {
  let _block;
  let $ = step.assertion;
  if ($ instanceof Some) {
    let assertion = $[0];
    _block = ("[" + escape_assertion(assertion)) + "]";
  } else {
    _block = "";
  }
  let assertion = _block;
  return ("/" + $int.to_string(step.index)) + assertion;
}

/**
 * The CFI path without the `epubcfi(...)` wrapper — the form used for
 * the intra-document part of a fragment, and for joining onto a spine
 * item's base path with `!`.
 */
export function path_to_string(cfi) {
  let _block;
  let _pipe = cfi.parts;
  let _pipe$1 = $list.map(
    _pipe,
    (steps) => {
      let _pipe$1 = steps;
      let _pipe$2 = $list.map(_pipe$1, step_to_string);
      return $string.concat(_pipe$2);
    },
  );
  _block = $string.join(_pipe$1, "!");
  let path = _block;
  let _block$1;
  let $ = cfi.offset;
  if ($ instanceof Some) {
    let offset = $[0];
    _block$1 = ":" + $int.to_string(offset);
  } else {
    _block$1 = "";
  }
  let offset = _block$1;
  return path + offset;
}

/**
 * Print a CFI back out as an `epubcfi(...)` string.
 */
export function to_string(cfi) {
  return ("epubcfi(" + path_to_string(cfi)) + ")";
}

function spine_position(index) {
  let $ = (index >= 2) && ((index % 2) === 0);
  if ($) {
    return new Ok((globalThis.Math.trunc(index / 2)) - 1);
  } else {
    return new Error(undefined);
  }
}

/**
 * Split a publication-level CFI into the spine position it addresses and
 * the remainder pointing within that chapter's document, if any.
 */
export function locate(cfi) {
  let $ = cfi.parts;
  if ($ instanceof $Empty) {
    return new Error(undefined);
  } else {
    let package_steps = $.head;
    let rest = $.tail;
    return $result.try$(
      $list.last(package_steps),
      (last) => {
        return $result.try$(
          spine_position(last.index),
          (index) => {
            if (rest instanceof $Empty) {
              return new Ok([index, new None()]);
            } else {
              let parts = rest;
              return new Ok([index, new Some(new Cfi(parts, cfi.offset))]);
            }
          },
        );
      },
    );
  }
}

/**
 * The spine item a CFI addresses, with the remainder of the CFI pointing
 * within that chapter's document, if any.
 */
export function spine_item(book, cfi) {
  return $result.try$(
    locate(cfi),
    (_use0) => {
      let index = _use0[0];
      let rest = _use0[1];
      return $result.try$(
        (() => {
          let _pipe = book.spine;
          let _pipe$1 = $list.drop(_pipe, index);
          return $list.first(_pipe$1);
        })(),
        (item) => { return new Ok([item, rest]); },
      );
    },
  );
}
