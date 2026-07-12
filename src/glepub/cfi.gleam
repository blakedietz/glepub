//// EPUB Canonical Fragment Identifiers — `epubcfi(/6/4!/4/10/2:3)` — the
//// standard way to address a point inside a publication.
////
//// A CFI is a path of child steps. Even indices address element children
//// (`/2` is the first element child, `/4` the second, …), odd indices the
//// text between them, and `!` steps out of the package document into the
//// content document the itemref references. The part before the first `!`
//// identifies the spine item — `SpineItem.cfi` holds exactly that path —
//// and the rest addresses a node inside the chapter, optionally ending in
//// a `:n` character offset into a text node. A step may carry an
//// `[assertion]`, usually the id the addressed element is expected to
//// have.
////
//// This module parses and prints point CFIs and locates them in a book's
//// spine. Range CFIs (`epubcfi(/6/4!/4,/10/2:1,/10/2:5)`) and the
//// temporal/spatial offsets used for audio and images are not supported.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import glepub.{type Book, type SpineItem}

pub type Step {
  Step(
    /// Even for element children, odd for the text between them.
    index: Int,
    /// The id the addressed element is asserted to have, from `[...]`.
    assertion: Option(String),
  )
}

pub type Cfi {
  Cfi(
    /// One list of steps per document: the first walks the package
    /// document to an itemref, and each subsequent list follows a `!`
    /// indirection into the referenced content document.
    parts: List(List(Step)),
    /// The `:n` character offset into the text node the last step lands
    /// on.
    offset: Option(Int),
  )
}

/// Parse an `epubcfi(...)` string.
pub fn parse(text: String) -> Result(Cfi, Nil) {
  case string.starts_with(text, "epubcfi("), string.ends_with(text, ")") {
    True, True ->
      text
      |> string.drop_start(8)
      |> string.drop_end(1)
      |> parse_parts([], [])
    _, _ -> Error(Nil)
  }
}

fn parse_parts(
  text: String,
  parts: List(List(Step)),
  steps: List(Step),
) -> Result(Cfi, Nil) {
  case text {
    "" -> finish(parts, steps, None)
    "!" <> rest ->
      case steps {
        [] -> Error(Nil)
        steps -> parse_parts(rest, [list.reverse(steps), ..parts], [])
      }
    "/" <> rest -> {
      use #(index, rest) <- result.try(take_int(rest))
      use #(assertion, rest) <- result.try(take_assertion(rest))
      parse_parts(rest, parts, [Step(index, assertion), ..steps])
    }
    ":" <> rest -> {
      use #(offset, rest) <- result.try(take_int(rest))
      case rest {
        "" -> finish(parts, steps, Some(offset))
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn finish(
  parts: List(List(Step)),
  steps: List(Step),
  offset: Option(Int),
) -> Result(Cfi, Nil) {
  case parts, steps {
    [], [] -> Error(Nil)
    _, [] -> Error(Nil)
    _, _ -> Ok(Cfi(list.reverse([list.reverse(steps), ..parts]), offset))
  }
}

fn take_int(text: String) -> Result(#(Int, String), Nil) {
  let #(digits, rest) = span_digits(text, "")
  use number <- result.try(int.parse(digits))
  Ok(#(number, rest))
}

fn span_digits(text: String, taken: String) -> #(String, String) {
  case string.pop_grapheme(text) {
    Ok(#(grapheme, rest)) ->
      case grapheme {
        "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
          span_digits(rest, taken <> grapheme)
        _ -> #(taken, text)
      }
    Error(Nil) -> #(taken, text)
  }
}

fn take_assertion(text: String) -> Result(#(Option(String), String), Nil) {
  case text {
    "[" <> rest -> {
      use #(assertion, rest) <- result.try(span_assertion(rest, ""))
      Ok(#(Some(assertion), rest))
    }
    _ -> Ok(#(None, text))
  }
}

fn span_assertion(
  text: String,
  taken: String,
) -> Result(#(String, String), Nil) {
  case string.pop_grapheme(text) {
    Ok(#("]", rest)) -> Ok(#(taken, rest))
    // `^` escapes the next character inside an assertion.
    Ok(#("^", rest)) ->
      case string.pop_grapheme(rest) {
        Ok(#(escaped, rest)) -> span_assertion(rest, taken <> escaped)
        Error(Nil) -> Error(Nil)
      }
    Ok(#(grapheme, rest)) -> span_assertion(rest, taken <> grapheme)
    Error(Nil) -> Error(Nil)
  }
}

/// Print a CFI back out as an `epubcfi(...)` string.
pub fn to_string(cfi: Cfi) -> String {
  "epubcfi(" <> path_to_string(cfi) <> ")"
}

/// The CFI path without the `epubcfi(...)` wrapper — the form used for
/// the intra-document part of a fragment, and for joining onto a spine
/// item's base path with `!`.
pub fn path_to_string(cfi: Cfi) -> String {
  let path =
    cfi.parts
    |> list.map(fn(steps) { steps |> list.map(step_to_string) |> string.concat })
    |> string.join("!")
  let offset = case cfi.offset {
    Some(offset) -> ":" <> int.to_string(offset)
    None -> ""
  }
  path <> offset
}

fn step_to_string(step: Step) -> String {
  let assertion = case step.assertion {
    Some(assertion) -> "[" <> escape_assertion(assertion) <> "]"
    None -> ""
  }
  "/" <> int.to_string(step.index) <> assertion
}

fn escape_assertion(assertion: String) -> String {
  ["^", "[", "]", "(", ")", ",", ";", "="]
  |> list.fold(assertion, fn(text, special) {
    string.replace(text, special, "^" <> special)
  })
}

/// Split a publication-level CFI into the spine position it addresses and
/// the remainder pointing within that chapter's document, if any.
pub fn locate(cfi: Cfi) -> Result(#(Int, Option(Cfi)), Nil) {
  case cfi.parts {
    [package_steps, ..rest] -> {
      use last <- result.try(list.last(package_steps))
      use index <- result.try(spine_position(last.index))
      case rest {
        [] -> Ok(#(index, None))
        parts -> Ok(#(index, Some(Cfi(parts, cfi.offset))))
      }
    }
    [] -> Error(Nil)
  }
}

/// The spine item a CFI addresses, with the remainder of the CFI pointing
/// within that chapter's document, if any.
pub fn spine_item(
  book: Book,
  cfi: Cfi,
) -> Result(#(SpineItem, Option(Cfi)), Nil) {
  use #(index, rest) <- result.try(locate(cfi))
  use item <- result.try(book.spine |> list.drop(index) |> list.first)
  Ok(#(item, rest))
}

fn spine_position(index: Int) -> Result(Int, Nil) {
  // Itemrefs are elements, so only even indices address one.
  case index >= 2 && index % 2 == 0 {
    True -> Ok(index / 2 - 1)
    False -> Error(Nil)
  }
}
