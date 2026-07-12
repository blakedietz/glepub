import * as $bit_array from "../gleam_stdlib/gleam/bit_array.mjs";
import * as $dict from "../gleam_stdlib/gleam/dict.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../gleam_stdlib/gleam/option.mjs";
import * as $gleeunit from "../gleeunit/gleeunit.mjs";
import * as $glexml from "../glexml/glexml.mjs";
import { Ok, Error, toList, Empty as $Empty, makeError, isEqual } from "./gleam.mjs";
import * as $glepub from "./glepub.mjs";
import { Contributor, TocEntry } from "./glepub.mjs";

const FILEPATH = "test/glepub_test.gleam";

const container_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">\n  <rootfiles>\n    <rootfile full-path=\"OEBPS/content.opf\" media-type=\"application/oebps-package+xml\"/>\n  </rootfiles>\n</container>";

export function main() {
  return $gleeunit.main();
}

/**
 * A loader backed by an in-memory dictionary, as a test container.
 * 
 * @ignore
 */
function loader_of(files) {
  let _block;
  let _pipe = files;
  let _pipe$1 = $list.map(
    _pipe,
    (file) => { return [file[0], $bit_array.from_string(file[1])]; },
  );
  _block = $dict.from_list(_pipe$1);
  let files$1 = _block;
  return (path) => { return $dict.get(files$1, path); };
}

function epub3() {
  return loader_of(
    toList([
      ["META-INF/container.xml", container_xml],
      [
        "OEBPS/content.opf",
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<package xmlns=\"http://www.idpf.org/2007/opf\" version=\"3.0\" unique-identifier=\"pub-id\">\n  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">\n    <dc:identifier id=\"pub-id\">urn:uuid:1234</dc:identifier>\n    <dc:identifier>isbn:999</dc:identifier>\n    <dc:title id=\"t2\">A Subtitle</dc:title>\n    <dc:title id=\"t1\">Moby-Dick</dc:title>\n    <meta refines=\"#t1\" property=\"title-type\">main</meta>\n    <meta refines=\"#t2\" property=\"title-type\">subtitle</meta>\n    <dc:language>en-US</dc:language>\n    <dc:creator id=\"c1\">Herman Melville</dc:creator>\n    <meta refines=\"#c1\" property=\"role\" scheme=\"marc:relators\">aut</meta>\n    <meta refines=\"#c1\" property=\"file-as\">MELVILLE, HERMAN</meta>\n    <dc:publisher>Harper &amp; Brothers</dc:publisher>\n    <dc:date>1851-11-14</dc:date>\n    <dc:subject>Whaling</dc:subject>\n    <dc:subject>Obsession</dc:subject>\n    <meta property=\"dcterms:modified\">2026-07-07T00:00:00Z</meta>\n    <meta property=\"rendition:layout\">pre-paginated</meta>\n    <meta property=\"rendition:spread\">landscape</meta>\n  </metadata>\n  <manifest>\n    <item id=\"nav\" href=\"nav.xhtml\" media-type=\"application/xhtml+xml\" properties=\"nav\"/>\n    <item id=\"cover-img\" href=\"images/cover%20art.jpg\" media-type=\"image/jpeg\" properties=\"cover-image\"/>\n    <item id=\"c1\" href=\"text/chapter1.xhtml\" media-type=\"application/xhtml+xml\"/>\n    <item id=\"c2\" href=\"text/chapter2.xhtml\" media-type=\"application/xhtml+xml\" properties=\"scripted\"/>\n  </manifest>\n  <spine page-progression-direction=\"rtl\">\n    <itemref idref=\"c1\"/>\n    <itemref idref=\"c2\" linear=\"no\"/>\n  </spine>\n</package>",
      ],
      [
        "OEBPS/nav.xhtml",
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\">\n<head><title>Nav</title></head>\n<body>\n<nav epub:type=\"toc\">\n  <ol>\n    <li><a href=\"text/chapter1.xhtml\">Loomings</a>\n      <ol>\n        <li><a href=\"text/chapter1.xhtml#part2\">Call me Ishmael</a></li>\n      </ol>\n    </li>\n    <li><span>Unlinked heading</span></li>\n  </ol>\n</nav>\n<nav epub:type=\"landmarks\">\n  <ol>\n    <li><a epub:type=\"bodymatter\" href=\"text/chapter1.xhtml\">Start</a></li>\n  </ol>\n</nav>\n</body>\n</html>",
      ],
      [
        "OEBPS/text/chapter1.xhtml",
        "<?xml version=\"1.0\"?>\n<html xmlns=\"http://www.w3.org/1999/xhtml\"><body><p>Call me Ishmael.</p></body></html>",
      ],
    ]),
  );
}

export function open_epub3_test() {
  let $ = $glepub.open(epub3());
  let book;
  if ($ instanceof Ok) {
    book = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      100,
      "open_epub3_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 3458,
        end: 3500,
        pattern_start: 3469,
        pattern_end: 3477
      }
    )
  }
  let $1 = book.version;
  let $2 = "3.0";
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      101,
      "open_epub3_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 3510, end: 3522 },
        right: { kind: "literal", value: $2, start: 3526, end: 3531 },
        start: 3503,
        end: 3531,
        expression_start: 3510
      }
    )
  }
  let $3 = book.metadata.identifier;
  let $4 = "urn:uuid:1234";
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      102,
      "open_epub3_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 3541, end: 3565 },
        right: { kind: "literal", value: $4, start: 3569, end: 3584 },
        start: 3534,
        end: 3584,
        expression_start: 3541
      }
    )
  }
  let $5 = book.metadata.title;
  let $6 = "Moby-Dick";
  if (!($5 === $6)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      103,
      "open_epub3_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $5, start: 3594, end: 3613 },
        right: { kind: "literal", value: $6, start: 3617, end: 3628 },
        start: 3587,
        end: 3628,
        expression_start: 3594
      }
    )
  }
  let $7 = book.metadata.language;
  let $8 = "en-US";
  if (!($7 === $8)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      104,
      "open_epub3_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $7, start: 3638, end: 3660 },
        right: { kind: "literal", value: $8, start: 3664, end: 3671 },
        start: 3631,
        end: 3671,
        expression_start: 3638
      }
    )
  }
  let $9 = book.metadata.publisher;
  let $10 = new Some("Harper & Brothers");
  if (!(isEqual($9, $10))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      105,
      "open_epub3_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $9, start: 3681, end: 3704 },
        right: { kind: "literal", value: $10, start: 3708, end: 3733 },
        start: 3674,
        end: 3733,
        expression_start: 3681
      }
    )
  }
  let $11 = book.metadata.subjects;
  let $12 = toList(["Whaling", "Obsession"]);
  if (!(isEqual($11, $12))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      106,
      "open_epub3_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $11, start: 3743, end: 3765 },
        right: { kind: "literal", value: $12, start: 3769, end: 3793 },
        start: 3736,
        end: 3793,
        expression_start: 3743
      }
    )
  }
  let $13 = book.metadata.modified;
  let $14 = new Some("2026-07-07T00:00:00Z");
  if (!(isEqual($13, $14))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      107,
      "open_epub3_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $13, start: 3803, end: 3825 },
        right: { kind: "literal", value: $14, start: 3829, end: 3857 },
        start: 3796,
        end: 3857,
        expression_start: 3803
      }
    )
  }
  let $15 = book.metadata.creators;
  let $16 = toList([
    new Contributor(
      "Herman Melville",
      new Some("aut"),
      new Some("MELVILLE, HERMAN"),
    ),
  ]);
  if (!(isEqual($15, $16))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      108,
      "open_epub3_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $15, start: 3867, end: 3889 },
        right: { kind: "literal", value: $16, start: 3897, end: 3968 },
        start: 3860,
        end: 3968,
        expression_start: 3867
      }
    )
  }
  return undefined;
}

export function manifest_and_spine_test() {
  let $ = $glepub.open(epub3());
  let book;
  if ($ instanceof Ok) {
    book = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      113,
      "manifest_and_spine_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 4009,
        end: 4051,
        pattern_start: 4020,
        pattern_end: 4028
      }
    )
  }
  let $1 = $list.find(book.manifest, (i) => { return i.id === "cover-img"; });
  let cover;
  if ($1 instanceof Ok) {
    cover = $1[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      116,
      "manifest_and_spine_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 4130,
        end: 4208,
        pattern_start: 4141,
        pattern_end: 4150
      }
    )
  }
  let $2 = cover.href;
  let $3 = "OEBPS/images/cover art.jpg";
  if (!($2 === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      117,
      "manifest_and_spine_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $2, start: 4218, end: 4228 },
        right: { kind: "literal", value: $3, start: 4232, end: 4260 },
        start: 4211,
        end: 4260,
        expression_start: 4218
      }
    )
  }
  let $4 = book.cover;
  let $5 = new Some(cover);
  if (!(isEqual($4, $5))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      118,
      "manifest_and_spine_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 4270, end: 4280 },
        right: { kind: "expression", value: $5, start: 4284, end: 4295 },
        start: 4263,
        end: 4295,
        expression_start: 4270
      }
    )
  }
  let $6 = $list.map(book.spine, (s) => { return s.item.href; });
  let $7 = toList(["OEBPS/text/chapter1.xhtml", "OEBPS/text/chapter2.xhtml"]);
  if (!(isEqual($6, $7))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      120,
      "manifest_and_spine_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $6, start: 4306, end: 4349 },
        right: { kind: "literal", value: $7, start: 4357, end: 4415 },
        start: 4299,
        end: 4415,
        expression_start: 4306
      }
    )
  }
  let $8 = $list.map(book.spine, (s) => { return s.linear; });
  let $9 = toList([true, false]);
  if (!(isEqual($8, $9))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      122,
      "manifest_and_spine_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $8, start: 4425, end: 4465 },
        right: { kind: "literal", value: $9, start: 4469, end: 4482 },
        start: 4418,
        end: 4482,
        expression_start: 4425
      }
    )
  }
  let $10 = book.spine;
  let second;
  if ($10 instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      123,
      "manifest_and_spine_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $10,
        start: 4485,
        end: 4520,
        pattern_start: 4496,
        pattern_end: 4507
      }
    )
  } else {
    let $11 = $10.tail;
    if ($11 instanceof $Empty) {
      throw makeError(
        "let_assert",
        FILEPATH,
        "glepub_test",
        123,
        "manifest_and_spine_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $10,
          start: 4485,
          end: 4520,
          pattern_start: 4496,
          pattern_end: 4507
        }
      )
    } else {
      let $12 = $11.tail;
      if ($12 instanceof $Empty) {
        second = $11.head;
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "glepub_test",
          123,
          "manifest_and_spine_test",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $10,
            start: 4485,
            end: 4520,
            pattern_start: 4496,
            pattern_end: 4507
          }
        )
      }
    }
  }
  let $13 = second.item.properties;
  let $14 = toList(["scripted"]);
  if (!(isEqual($13, $14))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      124,
      "manifest_and_spine_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $13, start: 4530, end: 4552 },
        right: { kind: "literal", value: $14, start: 4556, end: 4568 },
        start: 4523,
        end: 4568,
        expression_start: 4530
      }
    )
  }
  let $15 = book.direction;
  let $16 = new $glepub.RightToLeft();
  if (!(isEqual($15, $16))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      125,
      "manifest_and_spine_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $15, start: 4578, end: 4592 },
        right: { kind: "expression", value: $16, start: 4596, end: 4614 },
        start: 4571,
        end: 4614,
        expression_start: 4578
      }
    )
  }
  return undefined;
}

export function rendition_test() {
  let $ = $glepub.open(epub3());
  let book;
  if ($ instanceof Ok) {
    book = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      129,
      "rendition_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 4646,
        end: 4688,
        pattern_start: 4657,
        pattern_end: 4665
      }
    )
  }
  let $1 = book.rendition.layout;
  let $2 = new $glepub.PrePaginated();
  if (!(isEqual($1, $2))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      130,
      "rendition_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 4698, end: 4719 },
        right: { kind: "expression", value: $2, start: 4723, end: 4742 },
        start: 4691,
        end: 4742,
        expression_start: 4698
      }
    )
  }
  let $3 = book.rendition.spread;
  let $4 = new Some("landscape");
  if (!(isEqual($3, $4))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      131,
      "rendition_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 4752, end: 4773 },
        right: { kind: "literal", value: $4, start: 4777, end: 4794 },
        start: 4745,
        end: 4794,
        expression_start: 4752
      }
    )
  }
  let $5 = book.rendition.orientation;
  if (!(isEqual($5, new None()))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      132,
      "rendition_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $5, start: 4804, end: 4830 },
        right: { kind: "literal", value: new None(), start: 4834, end: 4838 },
        start: 4797,
        end: 4838,
        expression_start: 4804
      }
    )
  }
  return undefined;
}

export function toc_test() {
  let $ = $glepub.open(epub3());
  let book;
  if ($ instanceof Ok) {
    book = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      136,
      "toc_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 4864,
        end: 4906,
        pattern_start: 4875,
        pattern_end: 4883
      }
    )
  }
  let $1 = book.toc;
  let $2 = toList([
    new TocEntry(
      "Loomings",
      new Some("OEBPS/text/chapter1.xhtml"),
      toList([
        new TocEntry(
          "Call me Ishmael",
          new Some("OEBPS/text/chapter1.xhtml#part2"),
          toList([]),
        ),
      ]),
    ),
    new TocEntry("Unlinked heading", new None(), toList([])),
  ]);
  if (!(isEqual($1, $2))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      138,
      "toc_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 4986, end: 4994 },
        right: { kind: "literal", value: $2, start: 5002, end: 5211 },
        start: 4979,
        end: 5211,
        expression_start: 4986
      }
    )
  }
  let $3 = book.landmarks;
  let $4 = toList([
    new TocEntry("Start", new Some("OEBPS/text/chapter1.xhtml"), toList([])),
  ]);
  if (!(isEqual($3, $4))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      145,
      "toc_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 5221, end: 5235 },
        right: { kind: "literal", value: $4, start: 5243, end: 5301 },
        start: 5214,
        end: 5301,
        expression_start: 5221
      }
    )
  }
  return undefined;
}

export function resources_test() {
  let $ = $glepub.open(epub3());
  let book;
  if ($ instanceof Ok) {
    book = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      150,
      "resources_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 5333,
        end: 5375,
        pattern_start: 5344,
        pattern_end: 5352
      }
    )
  }
  let $1 = book.spine;
  let first;
  if ($1 instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      151,
      "resources_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 5378,
        end: 5413,
        pattern_start: 5389,
        pattern_end: 5400
      }
    )
  } else {
    first = $1.head;
  }
  let $2 = $glepub.document(book, first.item);
  let chapter;
  if ($2 instanceof Ok) {
    chapter = $2[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      152,
      "resources_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 5416,
        end: 5474,
        pattern_start: 5427,
        pattern_end: 5438
      }
    )
  }
  let $3 = $glexml.text_content(chapter.root);
  let $4 = "Call me Ishmael.";
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      153,
      "resources_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 5484, end: 5517 },
        right: { kind: "literal", value: $4, start: 5521, end: 5539 },
        start: 5477,
        end: 5539,
        expression_start: 5484
      }
    )
  }
  let $5 = $glepub.item_for_href(book, "OEBPS/text/chapter1.xhtml#part2");
  let item;
  if ($5 instanceof Ok) {
    item = $5[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      155,
      "resources_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $5,
        start: 5543,
        end: 5630,
        pattern_start: 5554,
        pattern_end: 5562
      }
    )
  }
  let $6 = item.id;
  let $7 = "c1";
  if (!($6 === $7)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      157,
      "resources_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $6, start: 5640, end: 5647 },
        right: { kind: "literal", value: $7, start: 5651, end: 5655 },
        start: 5633,
        end: 5655,
        expression_start: 5640
      }
    )
  }
  let $8 = book.spine;
  let missing;
  if ($8 instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      159,
      "resources_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $8,
        start: 5659,
        end: 5695,
        pattern_start: 5670,
        pattern_end: 5682
      }
    )
  } else {
    let $9 = $8.tail;
    if ($9 instanceof $Empty) {
      throw makeError(
        "let_assert",
        FILEPATH,
        "glepub_test",
        159,
        "resources_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $8,
          start: 5659,
          end: 5695,
          pattern_start: 5670,
          pattern_end: 5682
        }
      )
    } else {
      let $10 = $9.tail;
      if ($10 instanceof $Empty) {
        missing = $9.head;
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "glepub_test",
          159,
          "resources_test",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $8,
            start: 5659,
            end: 5695,
            pattern_start: 5670,
            pattern_end: 5682
          }
        )
      }
    }
  }
  let $11 = $glepub.document(book, missing.item);
  if ($11 instanceof Error) {
    let $12 = $11[0];
    if ($12 instanceof $glepub.MissingFile) {
      let $13 = $12.path;
      if (!($13 === "OEBPS/text/chapter2.xhtml")) {
        throw makeError(
          "let_assert",
          FILEPATH,
          "glepub_test",
          160,
          "resources_test",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $11,
            start: 5698,
            end: 5805,
            pattern_start: 5709,
            pattern_end: 5763
          }
        )
      }
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "glepub_test",
        160,
        "resources_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $11,
          start: 5698,
          end: 5805,
          pattern_start: 5709,
          pattern_end: 5763
        }
      )
    }
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      160,
      "resources_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $11,
        start: 5698,
        end: 5805,
        pattern_start: 5709,
        pattern_end: 5763
      }
    )
  }
  return $11;
}

export function epub2_test() {
  let files = toList([
    ["META-INF/container.xml", container_xml],
    [
      "OEBPS/content.opf",
      "<?xml version=\"1.0\"?>\n<package xmlns=\"http://www.idpf.org/2007/opf\" version=\"2.0\" unique-identifier=\"bookid\">\n  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:opf=\"http://www.idpf.org/2007/opf\">\n    <dc:identifier id=\"bookid\">urn:isbn:12345</dc:identifier>\n    <dc:title>An Older Book</dc:title>\n    <dc:language>en</dc:language>\n    <dc:creator opf:role=\"aut\" opf:file-as=\"Author, Ann\">Ann Author</dc:creator>\n    <meta name=\"cover\" content=\"cover-picture\"/>\n  </metadata>\n  <manifest>\n    <item id=\"ncx\" href=\"toc.ncx\" media-type=\"application/x-dtbncx+xml\"/>\n    <item id=\"cover-picture\" href=\"cover.jpg\" media-type=\"image/jpeg\"/>\n    <item id=\"ch1\" href=\"ch1.xhtml\" media-type=\"application/xhtml+xml\"/>\n  </manifest>\n  <spine toc=\"ncx\">\n    <itemref idref=\"ch1\"/>\n  </spine>\n  <guide>\n    <reference type=\"cover\" title=\"Cover\" href=\"cover.jpg\"/>\n  </guide>\n</package>",
    ],
    [
      "OEBPS/toc.ncx",
      "<?xml version=\"1.0\"?>\n<ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" version=\"2005-1\">\n  <navMap>\n    <navPoint id=\"n1\" playOrder=\"1\">\n      <navLabel><text>Chapter One</text></navLabel>\n      <content src=\"ch1.xhtml\"/>\n      <navPoint id=\"n2\" playOrder=\"2\">\n        <navLabel><text>Part Two</text></navLabel>\n        <content src=\"ch1.xhtml#p2\"/>\n      </navPoint>\n    </navPoint>\n  </navMap>\n</ncx>",
    ],
  ]);
  let $ = $glepub.open(loader_of(files));
  let book;
  if ($ instanceof Ok) {
    book = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      208,
      "epub2_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 7353,
        end: 7404,
        pattern_start: 7364,
        pattern_end: 7372
      }
    )
  }
  let $1 = book.version;
  let $2 = "2.0";
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      209,
      "epub2_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 7414, end: 7426 },
        right: { kind: "literal", value: $2, start: 7430, end: 7435 },
        start: 7407,
        end: 7435,
        expression_start: 7414
      }
    )
  }
  let $3 = book.metadata.creators;
  let $4 = toList([
    new Contributor("Ann Author", new Some("aut"), new Some("Author, Ann")),
  ]);
  if (!(isEqual($3, $4))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      210,
      "epub2_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 7445, end: 7467 },
        right: { kind: "literal", value: $4, start: 7475, end: 7536 },
        start: 7438,
        end: 7536,
        expression_start: 7445
      }
    )
  }
  let $5 = book.toc;
  let $6 = toList([
    new TocEntry(
      "Chapter One",
      new Some("OEBPS/ch1.xhtml"),
      toList([
        new TocEntry("Part Two", new Some("OEBPS/ch1.xhtml#p2"), toList([])),
      ]),
    ),
  ]);
  if (!(isEqual($5, $6))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      214,
      "epub2_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $5, start: 7606, end: 7614 },
        right: { kind: "literal", value: $6, start: 7622, end: 7758 },
        start: 7599,
        end: 7758,
        expression_start: 7606
      }
    )
  }
  let $7 = book.cover;
  let cover;
  if ($7 instanceof Some) {
    cover = $7[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      222,
      "epub2_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $7,
        start: 7824,
        end: 7859,
        pattern_start: 7835,
        pattern_end: 7846
      }
    )
  }
  let $8 = cover.id;
  let $9 = "cover-picture";
  if (!($8 === $9)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      223,
      "epub2_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $8, start: 7869, end: 7877 },
        right: { kind: "literal", value: $9, start: 7881, end: 7896 },
        start: 7862,
        end: 7896,
        expression_start: 7869
      }
    )
  }
  let $10 = book.landmarks;
  let $11 = toList([
    new TocEntry("Cover", new Some("OEBPS/cover.jpg"), toList([])),
  ]);
  if (!(isEqual($10, $11))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      224,
      "epub2_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $10, start: 7906, end: 7920 },
        right: { kind: "literal", value: $11, start: 7924, end: 7972 },
        start: 7899,
        end: 7972,
        expression_start: 7906
      }
    )
  }
  return undefined;
}

export function resolve_test() {
  let $ = $glepub.resolve("OEBPS/text", "../images/a.png");
  let $1 = "OEBPS/images/a.png";
  if (!($ === $1)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      228,
      "resolve_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $, start: 8009, end: 8056 },
        right: { kind: "literal", value: $1, start: 8060, end: 8080 },
        start: 8002,
        end: 8080,
        expression_start: 8009
      }
    )
  }
  let $2 = $glepub.resolve("OEBPS", "./ch%201.xhtml#top");
  let $3 = "OEBPS/ch 1.xhtml#top";
  if (!($2 === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      229,
      "resolve_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $2, start: 8090, end: 8135 },
        right: { kind: "literal", value: $3, start: 8139, end: 8161 },
        start: 8083,
        end: 8161,
        expression_start: 8090
      }
    )
  }
  let $4 = $glepub.resolve("", "ch1.xhtml");
  let $5 = "ch1.xhtml";
  if (!($4 === $5)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      230,
      "resolve_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 8171, end: 8202 },
        right: { kind: "literal", value: $5, start: 8206, end: 8217 },
        start: 8164,
        end: 8217,
        expression_start: 8171
      }
    )
  }
  let $6 = $glepub.resolve("OEBPS", "/absolute.css");
  let $7 = "absolute.css";
  if (!($6 === $7)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      231,
      "resolve_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $6, start: 8227, end: 8267 },
        right: { kind: "literal", value: $7, start: 8271, end: 8285 },
        start: 8220,
        end: 8285,
        expression_start: 8227
      }
    )
  }
  let $8 = "https://example.com/x";
  if (!$glepub.is_external($8)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      232,
      "resolve_test",
      "Assertion failed.",
      {
        kind: "function_call",
        arguments: [{ kind: "literal", value: $8, start: 8314, end: 8337 }],
        start: 8288,
        end: 8338,
        expression_start: 8295
      }
    )
  }
  if (!!$glepub.is_external("text/chapter1.xhtml")) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_test",
      233,
      "resolve_test",
      "Assertion failed.",
      {
        kind: "expression",
        expression: { kind: "expression", value: false, start: 8348, end: 8390 },
        start: 8341,
        end: 8390,
        expression_start: 8348
      }
    )
  }
  return undefined;
}

export function missing_container_test() {
  let $ = $glepub.open(loader_of(toList([])));
  if ($ instanceof Error) {
    let $1 = $[0];
    if ($1 instanceof $glepub.MissingFile) {
      let $2 = $1.path;
      if (!($2 === "META-INF/container.xml")) {
        throw makeError(
          "let_assert",
          FILEPATH,
          "glepub_test",
          237,
          "missing_container_test",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $,
            start: 8430,
            end: 8525,
            pattern_start: 8441,
            pattern_end: 8492
          }
        )
      }
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "glepub_test",
        237,
        "missing_container_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $,
          start: 8430,
          end: 8525,
          pattern_start: 8441,
          pattern_end: 8492
        }
      )
    }
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_test",
      237,
      "missing_container_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 8430,
        end: 8525,
        pattern_start: 8441,
        pattern_end: 8492
      }
    )
  }
  return $;
}
