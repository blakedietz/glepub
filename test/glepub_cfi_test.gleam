import gleam/bit_array
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import glepub
import glepub/cfi.{Cfi, Step}

pub fn parse_test() {
  let assert Ok(parsed) =
    cfi.parse("epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)")
  assert parsed
    == Cfi(
      [
        [Step(6, None), Step(4, Some("chap01ref"))],
        [Step(4, Some("body01")), Step(10, Some("para05")), Step(3, None)],
      ],
      Some(10),
    )
  assert cfi.to_string(parsed)
    == "epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)"
}

pub fn parse_escaped_assertion_test() {
  let assert Ok(parsed) = cfi.parse("epubcfi(/6/2[a^]b])")
  assert parsed == Cfi([[Step(6, None), Step(2, Some("a]b"))]], None)
  // The `]` is re-escaped on the way out.
  assert cfi.to_string(parsed) == "epubcfi(/6/2[a^]b])"
}

pub fn parse_rejects_test() {
  assert cfi.parse("not a cfi") == Error(Nil)
  assert cfi.parse("epubcfi()") == Error(Nil)
  assert cfi.parse("epubcfi(6/4)") == Error(Nil)
  // Range CFIs are out of scope.
  assert cfi.parse("epubcfi(/6/4!/4,/10/2:1,/10/2:5)") == Error(Nil)
  // Offsets only come last.
  assert cfi.parse("epubcfi(/6/4:2/2)") == Error(Nil)
}

pub fn locate_test() {
  let assert Ok(full) = cfi.parse("epubcfi(/6/4!/4/10/3:10)")
  let assert Ok(#(1, Some(intra))) = cfi.locate(full)
  assert cfi.to_string(intra) == "epubcfi(/4/10/3:10)"

  // A CFI can stop at the chapter itself.
  let assert Ok(chapter_only) = cfi.parse("epubcfi(/6/2)")
  assert cfi.locate(chapter_only) == Ok(#(0, None))

  // Odd indices are text nodes, which cannot be itemrefs.
  let assert Ok(odd) = cfi.parse("epubcfi(/6/3)")
  assert cfi.locate(odd) == Error(Nil)
}

pub fn spine_item_test() {
  let assert Ok(book) = glepub.open(fixture())
  let assert Ok(parsed) = cfi.parse("epubcfi(/6/4!/4/2)")
  let assert Ok(#(item, Some(_))) = cfi.spine_item(book, parsed)
  assert item.item.id == "c2"
}

fn fixture() -> glepub.Loader {
  let files =
    [
      #(
        "META-INF/container.xml",
        "<?xml version=\"1.0\"?>
<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">
  <rootfiles>
    <rootfile full-path=\"content.opf\" media-type=\"application/oebps-package+xml\"/>
  </rootfiles>
</container>",
      ),
      #(
        "content.opf",
        "<?xml version=\"1.0\"?>
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
</package>",
      ),
    ]
    |> list.map(fn(file) { #(file.0, bit_array.from_string(file.1)) })
    |> dict.from_list
  fn(path) { dict.get(files, path) }
}
