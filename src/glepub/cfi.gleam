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
//// A range CFI — `epubcfi(/6/4!/4/10/2,:1,:5)` — addresses a stretch of
//// content between two such points: a shared parent path followed by two
//// local paths, one per endpoint. `Range` models one as its two absolute
//// endpoints, which is the shape every consumer wants — resolve either
//// endpoint like any point, compare points to sort ranges by document
//// position — and the shared-parent split is recomputed on printing.
////
//// This module parses and prints point and range CFIs and locates them in
//// a book's spine. The temporal/spatial offsets used for audio and images
//// are not supported.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
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

/// A range CFI: two points in the same document, in document order. Build
/// one with `range` or `parse_range`; both uphold the invariants printing
/// relies on, so construction is the only place a range can fail.
pub opaque type Range {
  Range(from: Cfi, to: Cfi)
}

/// The point a range starts at, as an ordinary absolute CFI.
pub fn range_start(range: Range) -> Cfi {
  range.from
}

/// The point a range ends at, as an ordinary absolute CFI.
pub fn range_end(range: Range) -> Cfi {
  range.to
}

/// Build a range from two points, normalising them into document order.
/// The points must lie in the same document: every part but the last must
/// match, and the final parts must share their first step — endpoints in
/// different chapters do not form a range.
pub fn range(from from: Cfi, to to: Cfi) -> Result(Range, Nil) {
  use _ <- result.try(shared_split(from, to))
  case compare(from, to) {
    order.Gt -> Ok(Range(from: to, to: from))
    _ -> Ok(Range(from:, to:))
  }
}

/// Parse an `epubcfi(...)` string addressing a single point. Range CFIs
/// are rejected here; use `parse_range` for them.
pub fn parse(text: String) -> Result(Cfi, Nil) {
  use inner <- result.try(unwrap(text))
  use #(cfi, rest) <- result.try(parse_path(inner))
  case rest {
    "" -> Ok(cfi)
    _ -> Error(Nil)
  }
}

/// Parse an `epubcfi(parent,start,end)` range string. The two local paths
/// are joined onto the parent to make absolute endpoints; each may be a
/// run of steps, a bare `:n` offset, or empty (the endpoint is the parent
/// itself). Locals may not cross a `!` indirection of their own.
pub fn parse_range(text: String) -> Result(Range, Nil) {
  use inner <- result.try(unwrap(text))
  use #(parent, rest) <- result.try(parse_path(inner))
  use rest <- result.try(expect_comma(rest))
  use #(start_steps, start_offset, rest) <- result.try(parse_local(rest, []))
  use rest <- result.try(expect_comma(rest))
  use #(end_steps, end_offset, rest) <- result.try(parse_local(rest, []))
  case rest, parent.offset {
    "", None ->
      range(
        from: join(parent, start_steps, start_offset),
        to: join(parent, end_steps, end_offset),
      )
    _, _ -> Error(Nil)
  }
}

fn unwrap(text: String) -> Result(String, Nil) {
  case string.starts_with(text, "epubcfi("), string.ends_with(text, ")") {
    True, True -> Ok(text |> string.drop_start(8) |> string.drop_end(1))
    _, _ -> Error(Nil)
  }
}

/// Parse a path up to the end of input or a top-level `,`, which is left
/// in the remainder for the caller.
fn parse_path(text: String) -> Result(#(Cfi, String), Nil) {
  parse_parts(text, [], [])
}

fn parse_parts(
  text: String,
  parts: List(List(Step)),
  steps: List(Step),
) -> Result(#(Cfi, String), Nil) {
  case text {
    "" -> finish(parts, steps, None) |> with_rest("")
    "," <> _ -> finish(parts, steps, None) |> with_rest(text)
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
        "" -> finish(parts, steps, Some(offset)) |> with_rest("")
        "," <> _ -> finish(parts, steps, Some(offset)) |> with_rest(rest)
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn with_rest(
  parsed: Result(Cfi, Nil),
  rest: String,
) -> Result(#(Cfi, String), Nil) {
  result.map(parsed, fn(cfi) { #(cfi, rest) })
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

/// A range's local path: steps within the parent's document — never a `!`
/// indirection — possibly empty, possibly just an offset. Stops at the end
/// of input or a top-level `,`, left in the remainder.
fn parse_local(
  text: String,
  steps: List(Step),
) -> Result(#(List(Step), Option(Int), String), Nil) {
  case text {
    "" -> Ok(#(list.reverse(steps), None, ""))
    "," <> _ -> Ok(#(list.reverse(steps), None, text))
    "/" <> rest -> {
      use #(index, rest) <- result.try(take_int(rest))
      use #(assertion, rest) <- result.try(take_assertion(rest))
      parse_local(rest, [Step(index, assertion), ..steps])
    }
    ":" <> rest -> {
      use #(offset, rest) <- result.try(take_int(rest))
      case rest {
        "" -> Ok(#(list.reverse(steps), Some(offset), ""))
        "," <> _ -> Ok(#(list.reverse(steps), Some(offset), rest))
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn expect_comma(text: String) -> Result(String, Nil) {
  case text {
    "," <> rest -> Ok(rest)
    _ -> Error(Nil)
  }
}

/// A local path appended to the parent it is relative to: its steps extend
/// the parent's final part, and its offset becomes the result's.
fn join(parent: Cfi, steps: List(Step), offset: Option(Int)) -> Cfi {
  case steps {
    [] -> Cfi(parent.parts, offset)
    steps ->
      case list.reverse(parent.parts) {
        [last, ..init] ->
          Cfi(list.reverse([list.append(last, steps), ..init]), offset)
        [] -> Cfi([steps], offset)
      }
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
  parts_to_string(cfi.parts) <> offset_to_string(cfi.offset)
}

/// Print a range back out as an `epubcfi(parent,start,end)` string. The
/// printed form is canonical: the parent takes the maximal shared prefix
/// of the two endpoints, whatever split the range was parsed from.
pub fn range_to_string(range: Range) -> String {
  "epubcfi(" <> range_path_to_string(range) <> ")"
}

/// The range's path without the `epubcfi(...)` wrapper, for fragment use
/// and for joining onto a spine item's base path with `!`.
pub fn range_path_to_string(range: Range) -> String {
  case shared_split(range.from, range.to) {
    Ok(#(parent, from_local, to_local)) ->
      parts_to_string(parent)
      <> ","
      <> local_to_string(from_local)
      <> ","
      <> local_to_string(to_local)
    // Unreachable: construction guarantees the endpoints share a parent.
    Error(Nil) -> path_to_string(range.from)
  }
}

fn parts_to_string(parts: List(List(Step))) -> String {
  parts
  |> list.map(fn(steps) { steps |> list.map(step_to_string) |> string.concat })
  |> string.join("!")
}

fn local_to_string(local: #(List(Step), Option(Int))) -> String {
  let #(steps, offset) = local
  string.concat(list.map(steps, step_to_string)) <> offset_to_string(offset)
}

fn offset_to_string(offset: Option(Int)) -> String {
  case offset {
    Some(offset) -> ":" <> int.to_string(offset)
    None -> ""
  }
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

// SPLITTING A RANGE AT ITS SHARED PARENT --------------------------------------------

/// Split two endpoints into their maximal shared parent and one local per
/// endpoint. Errors when the points do not share a document: every part
/// but the last must match, and the final parts must share a first step.
fn shared_split(
  from: Cfi,
  to: Cfi,
) -> Result(
  #(List(List(Step)), #(List(Step), Option(Int)), #(List(Step), Option(Int))),
  Nil,
) {
  split_parts(from.parts, to.parts, [], from.offset, to.offset)
}

fn split_parts(
  from_parts: List(List(Step)),
  to_parts: List(List(Step)),
  shared: List(List(Step)),
  from_offset: Option(Int),
  to_offset: Option(Int),
) -> Result(
  #(List(List(Step)), #(List(Step), Option(Int)), #(List(Step), Option(Int))),
  Nil,
) {
  case from_parts, to_parts {
    [from_last], [to_last] -> {
      let #(common, from_rest, to_rest) = split_steps(from_last, to_last, [])
      case common {
        [] -> Error(Nil)
        common -> {
          // An empty local whose endpoint carries no offset would print as
          // nothing at all; give both locals a step back off the shared
          // prefix instead, when a step can be spared — the parent must
          // keep at least one step of this part, or the locals would have
          // to cross its `!` boundary.
          let empty_local =
            { from_rest == [] && from_offset == None }
            || { to_rest == [] && to_offset == None }
          let #(common, from_rest, to_rest) = case
            empty_local,
            list.reverse(common)
          {
            True, [borrowed, ..kept] if kept != [] -> #(
              list.reverse(kept),
              [borrowed, ..from_rest],
              [borrowed, ..to_rest],
            )
            _, _ -> #(common, from_rest, to_rest)
          }
          Ok(#(
            list.reverse([common, ..shared]),
            #(from_rest, from_offset),
            #(to_rest, to_offset),
          ))
        }
      }
    }
    [from_first, ..from_rest], [to_first, ..to_rest] ->
      case from_first == to_first {
        True ->
          split_parts(
            from_rest,
            to_rest,
            [from_first, ..shared],
            from_offset,
            to_offset,
          )
        False -> Error(Nil)
      }
    _, _ -> Error(Nil)
  }
}

fn split_steps(
  from: List(Step),
  to: List(Step),
  common: List(Step),
) -> #(List(Step), List(Step), List(Step)) {
  case from, to {
    [x, ..from_rest], [y, ..to_rest] ->
      case x == y {
        True -> split_steps(from_rest, to_rest, [x, ..common])
        False -> #(list.reverse(common), from, to)
      }
    _, _ -> #(list.reverse(common), from, to)
  }
}

// ORDERING --------------------------------------------------------------------------

/// Document order over points: step by step down the tree, with a node
/// sorting before its own contents, and character offsets breaking ties
/// between points on the same node. Assertions do not participate.
pub fn compare(a: Cfi, b: Cfi) -> Order {
  compare_parts(a.parts, b.parts, a.offset, b.offset)
}

fn compare_parts(
  a: List(List(Step)),
  b: List(List(Step)),
  a_offset: Option(Int),
  b_offset: Option(Int),
) -> Order {
  case a, b {
    [], [] -> compare_offsets(a_offset, b_offset)
    [], _ -> order.Lt
    _, [] -> order.Gt
    [x, ..a_rest], [y, ..b_rest] ->
      case compare_steps(x, y) {
        order.Eq -> compare_parts(a_rest, b_rest, a_offset, b_offset)
        decided -> decided
      }
  }
}

fn compare_steps(a: List(Step), b: List(Step)) -> Order {
  case a, b {
    [], [] -> order.Eq
    [], _ -> order.Lt
    _, [] -> order.Gt
    [x, ..a_rest], [y, ..b_rest] ->
      case int.compare(x.index, y.index) {
        order.Eq -> compare_steps(a_rest, b_rest)
        decided -> decided
      }
  }
}

fn compare_offsets(a: Option(Int), b: Option(Int)) -> Order {
  case a, b {
    None, None -> order.Eq
    None, Some(_) -> order.Lt
    Some(_), None -> order.Gt
    Some(a), Some(b) -> int.compare(a, b)
  }
}

// LOCATING IN THE SPINE -------------------------------------------------------------

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
