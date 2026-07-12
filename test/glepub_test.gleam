import gleam/bit_array
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleeunit
import glepub.{Contributor, TocEntry}
import glexml

pub fn main() -> Nil {
  gleeunit.main()
}

/// A loader backed by an in-memory dictionary, as a test container.
fn loader_of(files: List(#(String, String))) -> glepub.Loader {
  let files =
    files
    |> list.map(fn(file) { #(file.0, bit_array.from_string(file.1)) })
    |> dict.from_list
  fn(path) { dict.get(files, path) }
}

const container_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">
  <rootfiles>
    <rootfile full-path=\"OEBPS/content.opf\" media-type=\"application/oebps-package+xml\"/>
  </rootfiles>
</container>"

fn epub3() -> glepub.Loader {
  loader_of([
    #("META-INF/container.xml", container_xml),
    #(
      "OEBPS/content.opf",
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
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
</package>",
    ),
    #(
      "OEBPS/nav.xhtml",
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
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
</html>",
    ),
    #(
      "OEBPS/text/chapter1.xhtml",
      "<?xml version=\"1.0\"?>
<html xmlns=\"http://www.w3.org/1999/xhtml\"><body><p>Call me Ishmael.</p></body></html>",
    ),
  ])
}

pub fn open_epub3_test() {
  let assert Ok(book) = glepub.open(epub3())
  assert book.version == "3.0"
  assert book.metadata.identifier == "urn:uuid:1234"
  assert book.metadata.title == "Moby-Dick"
  assert book.metadata.language == "en-US"
  assert book.metadata.publisher == Some("Harper & Brothers")
  assert book.metadata.subjects == ["Whaling", "Obsession"]
  assert book.metadata.modified == Some("2026-07-07T00:00:00Z")
  assert book.metadata.creators
    == [Contributor("Herman Melville", Some("aut"), Some("MELVILLE, HERMAN"))]
}

pub fn manifest_and_spine_test() {
  let assert Ok(book) = glepub.open(epub3())

  // Hrefs are resolved against the package directory and percent-decoded.
  let assert Ok(cover) = list.find(book.manifest, fn(i) { i.id == "cover-img" })
  assert cover.href == "OEBPS/images/cover art.jpg"
  assert book.cover == Some(cover)

  assert list.map(book.spine, fn(s) { s.item.href })
    == ["OEBPS/text/chapter1.xhtml", "OEBPS/text/chapter2.xhtml"]
  assert list.map(book.spine, fn(s) { s.linear }) == [True, False]
  // Package children: metadata /2, manifest /4, spine /6.
  assert list.map(book.spine, fn(s) { s.cfi }) == ["/6/2", "/6/4"]
  let assert [_, second] = book.spine
  assert second.item.properties == ["scripted"]
  assert book.direction == glepub.RightToLeft
}

pub fn rendition_test() {
  let assert Ok(book) = glepub.open(epub3())
  assert book.rendition.layout == glepub.PrePaginated
  assert book.rendition.spread == Some("landscape")
  assert book.rendition.orientation == None
}

pub fn toc_test() {
  let assert Ok(book) = glepub.open(epub3())
  // Nav hrefs resolve relative to the nav document, not the package.
  assert book.toc
    == [
      TocEntry("Loomings", Some("OEBPS/text/chapter1.xhtml"), [
        TocEntry("Call me Ishmael", Some("OEBPS/text/chapter1.xhtml#part2"), []),
      ]),
      TocEntry("Unlinked heading", None, []),
    ]
  assert book.landmarks
    == [TocEntry("Start", Some("OEBPS/text/chapter1.xhtml"), [])]
}

pub fn resources_test() {
  let assert Ok(book) = glepub.open(epub3())
  let assert [first, ..] = book.spine
  let assert Ok(chapter) = glepub.document(book, first.item)
  assert glexml.text_content(chapter.root) == "Call me Ishmael."

  let assert Ok(item) =
    glepub.item_for_href(book, "OEBPS/text/chapter1.xhtml#part2")
  assert item.id == "c1"

  let assert [_, missing] = book.spine
  let assert Error(glepub.MissingFile("OEBPS/text/chapter2.xhtml")) =
    glepub.document(book, missing.item)
}

pub fn epub2_test() {
  let files = [
    #("META-INF/container.xml", container_xml),
    #(
      "OEBPS/content.opf",
      "<?xml version=\"1.0\"?>
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
</package>",
    ),
    #(
      "OEBPS/toc.ncx",
      "<?xml version=\"1.0\"?>
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
</ncx>",
    ),
  ]
  let assert Ok(book) = glepub.open(loader_of(files))
  assert book.version == "2.0"
  assert book.metadata.creators
    == [Contributor("Ann Author", Some("aut"), Some("Author, Ann"))]

  // The NCX becomes the same tree shape as an EPUB 3 nav.
  assert book.toc
    == [
      TocEntry("Chapter One", Some("OEBPS/ch1.xhtml"), [
        TocEntry("Part Two", Some("OEBPS/ch1.xhtml#p2"), []),
      ]),
    ]

  // Cover via <meta name="cover">, landmarks from the guide.
  let assert Some(cover) = book.cover
  assert cover.id == "cover-picture"
  assert book.landmarks == [TocEntry("Cover", Some("OEBPS/cover.jpg"), [])]
}

pub fn resolve_test() {
  assert glepub.resolve("OEBPS/text", "../images/a.png") == "OEBPS/images/a.png"
  assert glepub.resolve("OEBPS", "./ch%201.xhtml#top") == "OEBPS/ch 1.xhtml#top"
  assert glepub.resolve("", "ch1.xhtml") == "ch1.xhtml"
  assert glepub.resolve("OEBPS", "/absolute.css") == "absolute.css"
  assert glepub.is_external("https://example.com/x")
  assert !glepub.is_external("text/chapter1.xhtml")
}

pub fn missing_container_test() {
  let assert Error(glepub.MissingFile("META-INF/container.xml")) =
    glepub.open(loader_of([]))
}
