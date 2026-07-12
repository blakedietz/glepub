//// An EPUB toolkit for the Erlang and JavaScript targets.
////
//// glepub is the format layer of an EPUB reader: it opens the container,
//// parses the package document (OPF), navigation (EPUB 3 nav documents and
//// EPUB 2 NCX), and exposes a typed `Book` — metadata, manifest, spine,
//// table of contents, landmarks, and cover.
////
//// Like `glexml` underneath it, glepub performs no I/O of its own. Opening
//// a book takes a `Loader`: a function from a path inside the container to
//// its bytes. Supply one backed by whatever suits the platform — a zip
//// library on the server, a `JSZip`-style reader in the browser, a
//// directory on disk, or a dictionary in tests.
////
//// ```gleam
//// let assert Ok(book) = glepub.open(loader)
//// book.metadata.title            // -> "Moby-Dick; or, The Whale"
//// list.map(book.spine, fn(s) { s.item.href })
//// book.toc                       // -> nested TocEntry tree
//// ```

import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import glexml.{type Document, type Element}
import glexml/selector

/// Reads the bytes of a file inside the container, by its path from the
/// container root (e.g. `"OEBPS/content.opf"`). Paths are given
/// percent-decoded and normalised, with no leading slash.
pub type Loader =
  fn(String) -> Result(BitArray, Nil)

/// An opened EPUB publication.
pub type Book {
  Book(
    /// The package version, e.g. `"3.0"` or `"2.0"`.
    version: String,
    metadata: Metadata,
    /// Every resource the package declares.
    manifest: List(ManifestItem),
    /// The reading order.
    spine: List(SpineItem),
    /// The table of contents, from the EPUB 3 nav document or the EPUB 2
    /// NCX, whichever the book provides.
    toc: List(TocEntry),
    /// The page list, if the book provides one.
    page_list: List(TocEntry),
    /// Landmarks (EPUB 3) or the guide (EPUB 2).
    landmarks: List(TocEntry),
    /// Reading direction of the spine.
    direction: Direction,
    rendition: Rendition,
    /// The cover image, when one is identified.
    cover: Option(ManifestItem),
    /// The loader the book was opened with, used by `resource` and
    /// `document`.
    loader: Loader,
  )
}

pub type Metadata {
  Metadata(
    /// The package's unique identifier.
    identifier: String,
    title: String,
    language: String,
    creators: List(Contributor),
    contributors: List(Contributor),
    publisher: Option(String),
    description: Option(String),
    /// The publication date (`dc:date`).
    published: Option(String),
    /// The last-modified timestamp (`dcterms:modified`).
    modified: Option(String),
    subjects: List(String),
    rights: Option(String),
  )
}

pub type Contributor {
  Contributor(
    name: String,
    /// A MARC relator code such as `"aut"` or `"ill"`, when given.
    role: Option(String),
    /// The name normalised for sorting, when given.
    file_as: Option(String),
  )
}

pub type ManifestItem {
  ManifestItem(
    id: String,
    /// The path within the container, resolved from the package document
    /// and percent-decoded, ready to pass to the loader.
    href: String,
    media_type: String,
    properties: List(String),
  )
}

pub type SpineItem {
  SpineItem(
    item: ManifestItem,
    linear: Bool,
    properties: List(String),
    /// The CFI path to this itemref in the package document, e.g.
    /// `/6/4[chap01ref]` — the part of an `epubcfi(...)` locator before
    /// the `!` indirection. See `glepub/cfi`.
    cfi: String,
  )
}

/// One entry of a table of contents, page list, or landmarks navigation.
pub type TocEntry {
  TocEntry(
    label: String,
    /// The target as a container path plus optional fragment, resolved
    /// relative to the document that declared it. None for entries that
    /// are only headings.
    href: Option(String),
    children: List(TocEntry),
  )
}

pub type Direction {
  LeftToRight
  RightToLeft
  DefaultDirection
}

pub type Layout {
  Reflowable
  PrePaginated
}

pub type Rendition {
  Rendition(layout: Layout, orientation: Option(String), spread: Option(String))
}

pub type EpubError {
  /// The loader had no file at this path.
  MissingFile(path: String)
  /// A file exists but is not well-formed XML.
  InvalidXml(path: String, error: glexml.ParseError)
  /// The container or package is structurally wrong; the description says
  /// how.
  InvalidPackage(description: String)
}

/// Convert an `EpubError` into a human readable message.
pub fn error_to_string(error: EpubError) -> String {
  case error {
    MissingFile(path) -> "the container has no file at \"" <> path <> "\""
    InvalidXml(path, error) ->
      "\""
      <> path
      <> "\" is not well-formed XML: "
      <> glexml.error_to_string(error)
    InvalidPackage(description) -> description
  }
}

// Opening -----------------------------------------------------------------------

/// Open a publication: read `META-INF/container.xml`, find the package
/// document, and parse the package, navigation, and cover information.
pub fn open(loader: Loader) -> Result(Book, EpubError) {
  use container <- result.try(read_xml(loader, "META-INF/container.xml"))
  use package_path <- result.try(
    selector_all(container.root, "rootfiles > rootfile")
    |> list.filter_map(fn(rootfile) {
      case glexml.attribute(rootfile, "media-type") {
        Ok("application/oebps-package+xml") ->
          glexml.attribute(rootfile, "full-path")
        _ -> Error(Nil)
      }
    })
    |> list.first
    |> result.replace_error(InvalidPackage(
      "container.xml names no package document",
    )),
  )
  let package_path = normalise(percent_decode(package_path))
  use package <- result.try(read_xml(loader, package_path))
  build_book(loader, package_path, package.root)
}

fn build_book(
  loader: Loader,
  package_path: String,
  package: Element,
) -> Result(Book, EpubError) {
  let base = dirname(package_path)
  let version = glexml.attribute(package, "version") |> result.unwrap("3.0")

  use metadata_element <- result.try(
    first_local(package, "metadata")
    |> result.replace_error(InvalidPackage(
      "the package document has no <metadata>",
    )),
  )
  use manifest_element <- result.try(
    first_local(package, "manifest")
    |> result.replace_error(InvalidPackage(
      "the package document has no <manifest>",
    )),
  )
  use spine_element <- result.try(
    first_local(package, "spine")
    |> result.replace_error(InvalidPackage(
      "the package document has no <spine>",
    )),
  )

  let manifest =
    children_local(manifest_element, "item")
    |> list.filter_map(fn(item) {
      case glexml.attribute(item, "id"), glexml.attribute(item, "href") {
        Ok(id), Ok(href) ->
          Ok(ManifestItem(
            id: id,
            href: resolve(base, href) |> strip_fragment,
            media_type: glexml.attribute(item, "media-type")
              |> result.unwrap(""),
            properties: properties_of(item),
          ))
        _, _ -> Error(Nil)
      }
    })
  let by_id =
    manifest
    |> list.map(fn(item) { #(item.id, item) })
    |> dict.from_list

  // CFI child steps count element children only, before any filtering, so
  // the paths stay valid even when an itemref is broken and dropped.
  let spine_cfi = cfi_step(package, spine_element)
  let spine =
    glexml.child_elements(spine_element)
    |> list.index_map(fn(itemref, position) {
      use <- require(glexml.local_name(itemref.name) == "itemref")
      use idref <- result.try(glexml.attribute(itemref, "idref"))
      use item <- result.try(dict.get(by_id, idref))
      Ok(SpineItem(
        item: item,
        linear: glexml.attribute(itemref, "linear") != Ok("no"),
        properties: properties_of(itemref),
        cfi: spine_cfi
          <> "/"
          <> int.to_string(2 * { position + 1 })
          <> cfi_assertion(itemref),
      ))
    })
    |> result.values

  let metadata = parse_metadata(package, metadata_element)
  let #(toc, page_list, landmarks) =
    load_navigation(loader, base, manifest, spine_element, package)

  Ok(Book(
    version: version,
    metadata: metadata,
    manifest: manifest,
    spine: spine,
    toc: toc,
    page_list: page_list,
    landmarks: landmarks,
    direction: case
      glexml.attribute(spine_element, "page-progression-direction")
    {
      Ok("rtl") -> RightToLeft
      Ok("ltr") -> LeftToRight
      _ -> DefaultDirection
    },
    rendition: parse_rendition(metadata_element),
    cover: find_cover(metadata_element, manifest),
    loader: loader,
  ))
}

fn properties_of(element: Element) -> List(String) {
  glexml.attribute(element, "properties")
  |> result.unwrap("")
  |> string.split(" ")
  |> list.filter(fn(property) { property != "" })
}

// Resources ---------------------------------------------------------------------

/// Read a manifest item's bytes from the container.
pub fn resource(book: Book, item: ManifestItem) -> Result(BitArray, EpubError) {
  book.loader(item.href)
  |> result.replace_error(MissingFile(item.href))
}

/// Read and parse a manifest item as XML — a content document, for
/// instance. EPUB 2 XHTML may use the named entities of the XHTML DTD;
/// supply them with `document_with_dtd` if you need them.
pub fn document(book: Book, item: ManifestItem) -> Result(Document, EpubError) {
  document_with_dtd(book, item, glexml.empty_dtd())
}

/// Like `document`, with extra DTD declarations available — typically the
/// XHTML entity set for EPUB 2 content documents.
pub fn document_with_dtd(
  book: Book,
  item: ManifestItem,
  dtd: glexml.Dtd,
) -> Result(Document, EpubError) {
  use bytes <- result.try(resource(book, item))
  glexml.parse_bytes_with_dtd(bytes, dtd)
  |> result.map_error(InvalidXml(item.href, _))
}

/// Find the manifest item a container path (as produced in `TocEntry.href`,
/// fragment ignored) refers to.
pub fn item_for_href(book: Book, href: String) -> Result(ManifestItem, Nil) {
  let path = strip_fragment(href)
  list.find(book.manifest, fn(item) { item.href == path })
}

/// Whether a reference in a content document points outside the container.
pub fn is_external(reference: String) -> Bool {
  case string.split_once(reference, ":") {
    Ok(#(scheme, _)) -> !string.contains(scheme, "/")
    Error(Nil) -> False
  }
}

// Metadata ----------------------------------------------------------------------

/// `<meta refines="#id" property="p">value</meta>` associations, by the id
/// they refine.
fn refinements_of(metadata: Element) -> Dict(String, List(#(String, String))) {
  children_local(metadata, "meta")
  |> list.filter_map(fn(meta) {
    case glexml.attribute(meta, "refines"), glexml.attribute(meta, "property") {
      Ok("#" <> id), Ok(property) -> Ok(#(id, property, text_of(meta)))
      _, _ -> Error(Nil)
    }
  })
  |> list.fold(dict.new(), fn(acc, entry) {
    let #(id, property, value) = entry
    dict.upsert(acc, id, fn(existing) {
      [#(property, value), ..option.unwrap(existing, [])]
    })
  })
}

fn parse_metadata(package: Element, metadata: Element) -> Metadata {
  let refinements = refinements_of(metadata)
  let refinement = fn(element: Element, property: String) -> Option(String) {
    case glexml.attribute(element, "id") {
      Ok(id) ->
        dict.get(refinements, id)
        |> result.unwrap([])
        |> list.find(fn(pair) { pair.0 == property })
        |> result.map(fn(pair) { Some(pair.1) })
        |> result.unwrap(None)
      Error(Nil) -> None
    }
  }

  // The unique identifier is the dc:identifier the package points at.
  let identifiers = children_local(metadata, "identifier")
  let identifier = case glexml.attribute(package, "unique-identifier") {
    Ok(wanted) ->
      identifiers
      |> list.find(fn(element) { glexml.attribute(element, "id") == Ok(wanted) })
      |> result.map(text_of)
    Error(Nil) -> Error(Nil)
  }
  let identifier = case identifier {
    Ok(identifier) -> identifier
    Error(Nil) ->
      identifiers |> list.first |> result.map(text_of) |> result.unwrap("")
  }

  // Prefer the title refined as the main one; otherwise the first.
  let titles = children_local(metadata, "title")
  let title =
    titles
    |> list.find(fn(element) {
      refinement(element, "title-type") == Some("main")
    })
    |> result.lazy_or(fn() { list.first(titles) })
    |> result.map(text_of)
    |> result.unwrap("")

  let contributor = fn(element: Element) -> Contributor {
    Contributor(
      name: text_of(element),
      // EPUB 3 refinements, with the EPUB 2 opf: attributes as fallback.
      role: refinement(element, "role")
        |> option.lazy_or(fn() {
          glexml.attribute(element, "opf:role") |> option.from_result
        }),
      file_as: refinement(element, "file-as")
        |> option.lazy_or(fn() {
          glexml.attribute(element, "opf:file-as") |> option.from_result
        }),
    )
  }

  let property_meta = fn(property: String) -> Option(String) {
    children_local(metadata, "meta")
    |> list.find(fn(meta) { glexml.attribute(meta, "property") == Ok(property) })
    |> result.map(fn(meta) { Some(text_of(meta)) })
    |> result.unwrap(None)
  }

  Metadata(
    identifier: identifier,
    title: title,
    language: first_local_text(metadata, "language") |> option.unwrap(""),
    creators: children_local(metadata, "creator") |> list.map(contributor),
    contributors: children_local(metadata, "contributor")
      |> list.map(contributor),
    publisher: first_local_text(metadata, "publisher"),
    description: first_local_text(metadata, "description"),
    published: first_local_text(metadata, "date"),
    modified: property_meta("dcterms:modified"),
    subjects: children_local(metadata, "subject") |> list.map(text_of),
    rights: first_local_text(metadata, "rights"),
  )
}

fn parse_rendition(metadata: Element) -> Rendition {
  let property = fn(name: String) -> Option(String) {
    children_local(metadata, "meta")
    |> list.find(fn(meta) {
      glexml.attribute(meta, "property") == Ok("rendition:" <> name)
    })
    |> result.map(fn(meta) { Some(text_of(meta)) })
    |> result.unwrap(None)
  }
  Rendition(
    layout: case property("layout") {
      Some("pre-paginated") -> PrePaginated
      _ -> Reflowable
    },
    orientation: property("orientation"),
    spread: property("spread"),
  )
}

fn find_cover(
  metadata: Element,
  manifest: List(ManifestItem),
) -> Option(ManifestItem) {
  // EPUB 3: a manifest item with the cover-image property.
  let by_property =
    list.find(manifest, fn(item) {
      list.contains(item.properties, "cover-image")
    })
  case by_property {
    Ok(item) -> Some(item)
    Error(Nil) -> {
      // EPUB 2: <meta name="cover" content="item-id"/>.
      let by_meta =
        children_local(metadata, "meta")
        |> list.find(fn(meta) { glexml.attribute(meta, "name") == Ok("cover") })
        |> result.try(glexml.attribute(_, "content"))
        |> result.try(fn(id) { list.find(manifest, fn(item) { item.id == id }) })
      case by_meta {
        Ok(item) -> Some(item)
        Error(Nil) ->
          // A common convention as a last resort.
          list.find(manifest, fn(item) {
            item.id == "cover-image"
            && string.starts_with(item.media_type, "image/")
          })
          |> option.from_result
      }
    }
  }
}

// Navigation --------------------------------------------------------------------

fn load_navigation(
  loader: Loader,
  base: String,
  manifest: List(ManifestItem),
  spine: Element,
  package: Element,
) -> #(List(TocEntry), List(TocEntry), List(TocEntry)) {
  // EPUB 3: the manifest item with the nav property.
  let from_nav =
    list.find(manifest, fn(item) { list.contains(item.properties, "nav") })
    |> result.try(fn(item) {
      read_xml(loader, item.href)
      |> result.map(fn(document) { #(item.href, document) })
      |> result.replace_error(Nil)
    })
  case from_nav {
    Ok(#(path, document)) -> {
      let nav_base = dirname(path)
      #(
        parse_nav(document.root, nav_base, "toc"),
        parse_nav(document.root, nav_base, "page-list"),
        case parse_nav(document.root, nav_base, "landmarks") {
          [] -> guide_landmarks(package, base)
          landmarks -> landmarks
        },
      )
    }
    Error(Nil) -> {
      // EPUB 2: the NCX named by the spine, or found by media type.
      let ncx_item =
        glexml.attribute(spine, "toc")
        |> result.try(fn(id) { list.find(manifest, fn(i) { i.id == id }) })
        |> result.lazy_or(fn() {
          list.find(manifest, fn(item) {
            item.media_type == "application/x-dtbncx+xml"
          })
        })
      let toc =
        ncx_item
        |> result.try(fn(item) {
          read_xml(loader, item.href)
          |> result.map(fn(document) {
            parse_ncx(document.root, dirname(item.href))
          })
          |> result.replace_error(Nil)
        })
        |> result.unwrap([])
      #(toc, [], guide_landmarks(package, base))
    }
  }
}

/// Parse one `<nav epub:type="...">` of an EPUB 3 navigation document into
/// a tree.
fn parse_nav(root: Element, base: String, kind: String) -> List(TocEntry) {
  case selector_all(root, "nav[epub|type~=" <> kind <> "] > ol") {
    [ol, ..] -> nav_list(ol, base)
    [] -> []
  }
}

fn nav_list(ol: Element, base: String) -> List(TocEntry) {
  glexml.children_named(ol, "li")
  |> list.map(fn(li) {
    let link =
      glexml.first_child_named(li, "a")
      |> result.lazy_or(fn() { glexml.first_child_named(li, "span") })
    let label = link |> result.map(text_of) |> result.unwrap("")
    let href =
      link
      |> result.try(glexml.attribute(_, "href"))
      |> result.map(fn(href) { Some(resolve(base, href)) })
      |> result.unwrap(None)
    let children = case glexml.first_child_named(li, "ol") {
      Ok(ol) -> nav_list(ol, base)
      Error(Nil) -> []
    }
    TocEntry(label: label, href: href, children: children)
  })
}

/// Parse an EPUB 2 NCX `<navMap>` into the same tree shape.
fn parse_ncx(root: Element, base: String) -> List(TocEntry) {
  case first_local(root, "navMap") {
    Ok(nav_map) -> ncx_points(nav_map, base)
    Error(Nil) -> []
  }
}

fn ncx_points(parent: Element, base: String) -> List(TocEntry) {
  children_local(parent, "navPoint")
  |> list.map(fn(point) {
    let label =
      first_local(point, "navLabel")
      |> result.try(first_local(_, "text"))
      |> result.map(text_of)
      |> result.unwrap("")
    let href =
      first_local(point, "content")
      |> result.try(glexml.attribute(_, "src"))
      |> result.map(fn(src) { Some(resolve(base, src)) })
      |> result.unwrap(None)
    TocEntry(label: label, href: href, children: ncx_points(point, base))
  })
}

/// EPUB 2 `<guide>` references presented as landmarks.
fn guide_landmarks(package: Element, base: String) -> List(TocEntry) {
  case first_local(package, "guide") {
    Error(Nil) -> []
    Ok(guide) ->
      children_local(guide, "reference")
      |> list.filter_map(fn(reference) {
        use href <- result.try(glexml.attribute(reference, "href"))
        let label = case glexml.attribute(reference, "title") {
          Ok(title) -> title
          Error(Nil) -> glexml.attribute(reference, "type") |> result.unwrap("")
        }
        Ok(
          TocEntry(label: label, href: Some(resolve(base, href)), children: []),
        )
      })
  }
}

// Paths -------------------------------------------------------------------------

/// Resolve a reference found in the document at directory `base` to a
/// container path: percent-decoded, `.`/`..` normalised, fragment kept.
pub fn resolve(base: String, reference: String) -> String {
  let #(path, fragment) = case string.split_once(reference, "#") {
    Ok(#(path, fragment)) -> #(path, "#" <> fragment)
    Error(Nil) -> #(reference, "")
  }
  let path = percent_decode(path)
  let resolved = case path {
    "" -> ""
    "/" <> absolute -> normalise(absolute)
    _ ->
      case base {
        "" -> normalise(path)
        _ -> normalise(base <> "/" <> path)
      }
  }
  resolved <> fragment
}

/// The container path without any `#fragment`.
pub fn strip_fragment(href: String) -> String {
  case string.split_once(href, "#") {
    Ok(#(path, _)) -> path
    Error(Nil) -> href
  }
}

fn dirname(path: String) -> String {
  case string.split(path, "/") |> list.reverse {
    [_, ..rest] -> rest |> list.reverse |> string.join("/")
    [] -> ""
  }
}

fn normalise(path: String) -> String {
  string.split(path, "/")
  |> list.fold([], fn(acc, part) {
    case part {
      "" | "." -> acc
      ".." ->
        case acc {
          [_, ..rest] -> rest
          [] -> []
        }
      part -> [part, ..acc]
    }
  })
  |> list.reverse
  |> string.join("/")
}

fn percent_decode(text: String) -> String {
  case string.contains(text, "%") {
    False -> text
    True ->
      do_percent_decode(string.to_graphemes(text), [])
      |> bit_array.concat
      |> bit_array.to_string
      |> result.unwrap(text)
  }
}

fn do_percent_decode(
  graphemes: List(String),
  acc: List(BitArray),
) -> List(BitArray) {
  case graphemes {
    [] -> list.reverse(acc)
    ["%", a, b, ..rest] ->
      case int.base_parse(a <> b, 16) {
        Ok(code) -> do_percent_decode(rest, [<<code>>, ..acc])
        Error(Nil) -> do_percent_decode([a, b, ..rest], [<<"%":utf8>>, ..acc])
      }
    [grapheme, ..rest] ->
      do_percent_decode(rest, [bit_array.from_string(grapheme), ..acc])
  }
}

// XML helpers --------------------------------------------------------------------

fn read_xml(loader: Loader, path: String) -> Result(Document, EpubError) {
  use bytes <- result.try(
    loader(path) |> result.replace_error(MissingFile(path)),
  )
  glexml.parse_bytes(bytes)
  |> result.map_error(InvalidXml(path, _))
}

/// The CFI child step addressing `child` within `parent`: element
/// children get even indices 2, 4, 6…, with the element's own id as an
/// assertion when it has one.
fn cfi_step(parent: Element, child: Element) -> String {
  let position =
    glexml.child_elements(parent)
    |> list.take_while(fn(element) { element != child })
    |> list.length
  "/" <> int.to_string(2 * { position + 1 }) <> cfi_assertion(child)
}

fn cfi_assertion(element: Element) -> String {
  case glexml.attribute(element, "id") {
    Ok(id) -> "[" <> id <> "]"
    Error(Nil) -> ""
  }
}

fn require(condition: Bool, next: fn() -> Result(a, Nil)) -> Result(a, Nil) {
  case condition {
    True -> next()
    False -> Error(Nil)
  }
}

/// Element children matched by local name, so `dc:title` and plain `title`
/// both count regardless of the prefix a book chose.
fn children_local(element: Element, name: String) -> List(Element) {
  glexml.child_elements(element)
  |> list.filter(fn(child) { glexml.local_name(child.name) == name })
}

fn first_local(element: Element, name: String) -> Result(Element, Nil) {
  children_local(element, name) |> list.first
}

fn first_local_text(element: Element, name: String) -> Option(String) {
  first_local(element, name)
  |> result.map(fn(found) { Some(text_of(found)) })
  |> result.unwrap(None)
}

/// An element's text with whitespace collapsed, for labels and metadata.
fn text_of(element: Element) -> String {
  glexml.text_content(element)
  |> string.replace("\n", " ")
  |> string.replace("\t", " ")
  |> string.split(" ")
  |> list.filter(fn(part) { part != "" })
  |> string.join(" ")
}

fn selector_all(element: Element, css: String) -> List(Element) {
  case selector.select(element, css) {
    Ok(found) -> found
    Error(_) -> []
  }
}
