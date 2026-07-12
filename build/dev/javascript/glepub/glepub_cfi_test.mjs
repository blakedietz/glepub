import * as $bit_array from "../gleam_stdlib/gleam/bit_array.mjs";
import * as $dict from "../gleam_stdlib/gleam/dict.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../gleam_stdlib/gleam/option.mjs";
import { Ok, Error, toList, makeError, isEqual } from "./gleam.mjs";
import * as $glepub from "./glepub.mjs";
import * as $cfi from "./glepub/cfi.mjs";
import { Cfi, Step } from "./glepub/cfi.mjs";

const FILEPATH = "test/glepub_cfi_test.gleam";

export function parse_test() {
  let $ = $cfi.parse("epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)");
  let parsed;
  if ($ instanceof Ok) {
    parsed = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      9,
      "parse_test",
      "Pattern match failed, no pattern matched the value.",
      { value: $, start: 161, end: 253, pattern_start: 172, pattern_end: 182 }
    )
  }
  let $1 = new Cfi(
    toList([
      toList([new Step(6, new None()), new Step(4, new Some("chap01ref"))]),
      toList([
        new Step(4, new Some("body01")),
        new Step(10, new Some("para05")),
        new Step(3, new None()),
      ]),
    ]),
    new Some(10),
  );
  if (!(isEqual(parsed, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      11,
      "parse_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: parsed, start: 263, end: 269 },
        right: { kind: "literal", value: $1, start: 277, end: 449 },
        start: 256,
        end: 449,
        expression_start: 263
      }
    )
  }
  let $2 = $cfi.to_string(parsed);
  let $3 = "epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)";
  if (!($2 === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      19,
      "parse_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $2, start: 459, end: 480 },
        right: { kind: "literal", value: $3, start: 488, end: 541 },
        start: 452,
        end: 541,
        expression_start: 459
      }
    )
  }
  return undefined;
}

export function parse_escaped_assertion_test() {
  let $ = $cfi.parse("epubcfi(/6/2[a^]b])");
  let parsed;
  if ($ instanceof Ok) {
    parsed = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      24,
      "parse_escaped_assertion_test",
      "Pattern match failed, no pattern matched the value.",
      { value: $, start: 587, end: 643, pattern_start: 598, pattern_end: 608 }
    )
  }
  let $1 = new Cfi(
    toList([toList([new Step(6, new None()), new Step(2, new Some("a]b"))])]),
    new None(),
  );
  if (!(isEqual(parsed, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      25,
      "parse_escaped_assertion_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: parsed, start: 653, end: 659 },
        right: { kind: "literal", value: $1, start: 663, end: 713 },
        start: 646,
        end: 713,
        expression_start: 653
      }
    )
  }
  let $2 = $cfi.to_string(parsed);
  let $3 = "epubcfi(/6/2[a^]b])";
  if (!($2 === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      27,
      "parse_escaped_assertion_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $2, start: 766, end: 787 },
        right: { kind: "literal", value: $3, start: 791, end: 812 },
        start: 759,
        end: 812,
        expression_start: 766
      }
    )
  }
  return undefined;
}

export function parse_rejects_test() {
  let $ = $cfi.parse("not a cfi");
  let $1 = new Error(undefined);
  if (!(isEqual($, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      31,
      "parse_rejects_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $, start: 855, end: 877 },
        right: { kind: "literal", value: $1, start: 881, end: 891 },
        start: 848,
        end: 891,
        expression_start: 855
      }
    )
  }
  let $2 = $cfi.parse("epubcfi()");
  let $3 = new Error(undefined);
  if (!(isEqual($2, $3))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      32,
      "parse_rejects_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $2, start: 901, end: 923 },
        right: { kind: "literal", value: $3, start: 927, end: 937 },
        start: 894,
        end: 937,
        expression_start: 901
      }
    )
  }
  let $4 = $cfi.parse("epubcfi(6/4)");
  let $5 = new Error(undefined);
  if (!(isEqual($4, $5))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      33,
      "parse_rejects_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 947, end: 972 },
        right: { kind: "literal", value: $5, start: 976, end: 986 },
        start: 940,
        end: 986,
        expression_start: 947
      }
    )
  }
  let $6 = $cfi.parse("epubcfi(/6/4!/4,/10/2:1,/10/2:5)");
  let $7 = new Error(undefined);
  if (!(isEqual($6, $7))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      35,
      "parse_rejects_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $6, start: 1030, end: 1075 },
        right: { kind: "literal", value: $7, start: 1079, end: 1089 },
        start: 1023,
        end: 1089,
        expression_start: 1030
      }
    )
  }
  let $8 = $cfi.parse("epubcfi(/6/4:2/2)");
  let $9 = new Error(undefined);
  if (!(isEqual($8, $9))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      37,
      "parse_rejects_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $8, start: 1128, end: 1158 },
        right: { kind: "literal", value: $9, start: 1162, end: 1172 },
        start: 1121,
        end: 1172,
        expression_start: 1128
      }
    )
  }
  return undefined;
}

export function path_to_string_test() {
  let $ = $cfi.parse("epubcfi(/6/4!/4/10/3:10)");
  let parsed;
  if ($ instanceof Ok) {
    parsed = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      41,
      "path_to_string_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 1209,
        end: 1270,
        pattern_start: 1220,
        pattern_end: 1230
      }
    )
  }
  let $1 = $cfi.path_to_string(parsed);
  let $2 = "/6/4!/4/10/3:10";
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      42,
      "path_to_string_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 1280, end: 1306 },
        right: { kind: "literal", value: $2, start: 1310, end: 1327 },
        start: 1273,
        end: 1327,
        expression_start: 1280
      }
    )
  }
  return undefined;
}

export function locate_test() {
  let $ = $cfi.parse("epubcfi(/6/4!/4/10/3:10)");
  let full;
  if ($ instanceof Ok) {
    full = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      46,
      "locate_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 1356,
        end: 1415,
        pattern_start: 1367,
        pattern_end: 1375
      }
    )
  }
  let $1 = $cfi.locate(full);
  let intra;
  if ($1 instanceof Ok) {
    let $2 = $1[0][1];
    if ($2 instanceof Some) {
      let $3 = $1[0][0];
      if ($3 === 1) {
        intra = $2[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "glepub_cfi_test",
          47,
          "locate_test",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $1,
            start: 1418,
            end: 1469,
            pattern_start: 1429,
            pattern_end: 1450
          }
        )
      }
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "glepub_cfi_test",
        47,
        "locate_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $1,
          start: 1418,
          end: 1469,
          pattern_start: 1429,
          pattern_end: 1450
        }
      )
    }
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      47,
      "locate_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 1418,
        end: 1469,
        pattern_start: 1429,
        pattern_end: 1450
      }
    )
  }
  let $4 = $cfi.to_string(intra);
  let $5 = "epubcfi(/4/10/3:10)";
  if (!($4 === $5)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      48,
      "locate_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 1479, end: 1499 },
        right: { kind: "literal", value: $5, start: 1503, end: 1524 },
        start: 1472,
        end: 1524,
        expression_start: 1479
      }
    )
  }
  let $6 = $cfi.parse("epubcfi(/6/2)");
  let chapter_only;
  if ($6 instanceof Ok) {
    chapter_only = $6[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      51,
      "locate_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $6,
        start: 1571,
        end: 1627,
        pattern_start: 1582,
        pattern_end: 1598
      }
    )
  }
  let $7 = $cfi.locate(chapter_only);
  let $8 = new Ok([0, new None()]);
  if (!(isEqual($7, $8))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      52,
      "locate_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $7, start: 1637, end: 1661 },
        right: { kind: "literal", value: $8, start: 1665, end: 1679 },
        start: 1630,
        end: 1679,
        expression_start: 1637
      }
    )
  }
  let $9 = $cfi.parse("epubcfi(/6/3)");
  let odd;
  if ($9 instanceof Ok) {
    odd = $9[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      55,
      "locate_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $9,
        start: 1742,
        end: 1789,
        pattern_start: 1753,
        pattern_end: 1760
      }
    )
  }
  let $10 = $cfi.locate(odd);
  let $11 = new Error(undefined);
  if (!(isEqual($10, $11))) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      56,
      "locate_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $10, start: 1799, end: 1814 },
        right: { kind: "literal", value: $11, start: 1818, end: 1828 },
        start: 1792,
        end: 1828,
        expression_start: 1799
      }
    )
  }
  return undefined;
}

function fixture() {
  let _block;
  let _pipe = toList([
    [
      "META-INF/container.xml",
      "<?xml version=\"1.0\"?>\n<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">\n  <rootfiles>\n    <rootfile full-path=\"content.opf\" media-type=\"application/oebps-package+xml\"/>\n  </rootfiles>\n</container>",
    ],
    [
      "content.opf",
      "<?xml version=\"1.0\"?>\n<package xmlns=\"http://www.idpf.org/2007/opf\" version=\"3.0\" unique-identifier=\"i\">\n  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">\n    <dc:identifier id=\"i\">urn:uuid:1</dc:identifier>\n    <dc:title>T</dc:title>\n    <dc:language>en</dc:language>\n  </metadata>\n  <manifest>\n    <item id=\"c1\" href=\"one.xhtml\" media-type=\"application/xhtml+xml\"/>\n    <item id=\"c2\" href=\"two.xhtml\" media-type=\"application/xhtml+xml\"/>\n  </manifest>\n  <spine>\n    <itemref idref=\"c1\"/>\n    <itemref idref=\"c2\"/>\n  </spine>\n</package>",
    ],
  ]);
  let _pipe$1 = $list.map(
    _pipe,
    (file) => { return [file[0], $bit_array.from_string(file[1])]; },
  );
  _block = $dict.from_list(_pipe$1);
  let files = _block;
  return (path) => { return $dict.get(files, path); };
}

export function spine_item_test() {
  let $ = $glepub.open(fixture());
  let book;
  if ($ instanceof Ok) {
    book = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      60,
      "spine_item_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 1861,
        end: 1905,
        pattern_start: 1872,
        pattern_end: 1880
      }
    )
  }
  let $1 = $cfi.parse("epubcfi(/6/4!/4/2)");
  let parsed;
  if ($1 instanceof Ok) {
    parsed = $1[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      61,
      "spine_item_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 1908,
        end: 1963,
        pattern_start: 1919,
        pattern_end: 1929
      }
    )
  }
  let $2 = $cfi.spine_item(book, parsed);
  let item;
  if ($2 instanceof Ok) {
    let $3 = $2[0][1];
    if ($3 instanceof Some) {
      item = $2[0][0];
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "glepub_cfi_test",
        62,
        "spine_item_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $2,
          start: 1966,
          end: 2028,
          pattern_start: 1977,
          pattern_end: 1997
        }
      )
    }
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glepub_cfi_test",
      62,
      "spine_item_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 1966,
        end: 2028,
        pattern_start: 1977,
        pattern_end: 1997
      }
    )
  }
  let $4 = item.item.id;
  let $5 = "c2";
  if (!($4 === $5)) {
    throw makeError(
      "assert",
      FILEPATH,
      "glepub_cfi_test",
      63,
      "spine_item_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 2038, end: 2050 },
        right: { kind: "literal", value: $5, start: 2054, end: 2058 },
        start: 2031,
        end: 2058,
        expression_start: 2038
      }
    )
  }
  return undefined;
}
