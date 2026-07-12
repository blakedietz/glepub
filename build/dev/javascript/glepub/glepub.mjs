import * as $bit_array from "../gleam_stdlib/gleam/bit_array.mjs";
import * as $dict from "../gleam_stdlib/gleam/dict.mjs";
import * as $int from "../gleam_stdlib/gleam/int.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../gleam_stdlib/gleam/option.mjs";
import * as $result from "../gleam_stdlib/gleam/result.mjs";
import * as $string from "../gleam_stdlib/gleam/string.mjs";
import * as $glexml from "../glexml/glexml.mjs";
import * as $selector from "../glexml/glexml/selector.mjs";
import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  isEqual,
  toBitArray,
  stringBits,
} from "./gleam.mjs";

export class Book extends $CustomType {
  constructor(version, metadata, manifest, spine, toc, page_list, landmarks, direction, rendition, cover, loader) {
    super();
    this.version = version;
    this.metadata = metadata;
    this.manifest = manifest;
    this.spine = spine;
    this.toc = toc;
    this.page_list = page_list;
    this.landmarks = landmarks;
    this.direction = direction;
    this.rendition = rendition;
    this.cover = cover;
    this.loader = loader;
  }
}
export const Book$Book = (version, metadata, manifest, spine, toc, page_list, landmarks, direction, rendition, cover, loader) =>
  new Book(version,
  metadata,
  manifest,
  spine,
  toc,
  page_list,
  landmarks,
  direction,
  rendition,
  cover,
  loader);
export const Book$isBook = (value) => value instanceof Book;
export const Book$Book$version = (value) => value.version;
export const Book$Book$0 = (value) => value.version;
export const Book$Book$metadata = (value) => value.metadata;
export const Book$Book$1 = (value) => value.metadata;
export const Book$Book$manifest = (value) => value.manifest;
export const Book$Book$2 = (value) => value.manifest;
export const Book$Book$spine = (value) => value.spine;
export const Book$Book$3 = (value) => value.spine;
export const Book$Book$toc = (value) => value.toc;
export const Book$Book$4 = (value) => value.toc;
export const Book$Book$page_list = (value) => value.page_list;
export const Book$Book$5 = (value) => value.page_list;
export const Book$Book$landmarks = (value) => value.landmarks;
export const Book$Book$6 = (value) => value.landmarks;
export const Book$Book$direction = (value) => value.direction;
export const Book$Book$7 = (value) => value.direction;
export const Book$Book$rendition = (value) => value.rendition;
export const Book$Book$8 = (value) => value.rendition;
export const Book$Book$cover = (value) => value.cover;
export const Book$Book$9 = (value) => value.cover;
export const Book$Book$loader = (value) => value.loader;
export const Book$Book$10 = (value) => value.loader;

export class Metadata extends $CustomType {
  constructor(identifier, title, language, creators, contributors, publisher, description, published, modified, subjects, rights) {
    super();
    this.identifier = identifier;
    this.title = title;
    this.language = language;
    this.creators = creators;
    this.contributors = contributors;
    this.publisher = publisher;
    this.description = description;
    this.published = published;
    this.modified = modified;
    this.subjects = subjects;
    this.rights = rights;
  }
}
export const Metadata$Metadata = (identifier, title, language, creators, contributors, publisher, description, published, modified, subjects, rights) =>
  new Metadata(identifier,
  title,
  language,
  creators,
  contributors,
  publisher,
  description,
  published,
  modified,
  subjects,
  rights);
export const Metadata$isMetadata = (value) => value instanceof Metadata;
export const Metadata$Metadata$identifier = (value) => value.identifier;
export const Metadata$Metadata$0 = (value) => value.identifier;
export const Metadata$Metadata$title = (value) => value.title;
export const Metadata$Metadata$1 = (value) => value.title;
export const Metadata$Metadata$language = (value) => value.language;
export const Metadata$Metadata$2 = (value) => value.language;
export const Metadata$Metadata$creators = (value) => value.creators;
export const Metadata$Metadata$3 = (value) => value.creators;
export const Metadata$Metadata$contributors = (value) => value.contributors;
export const Metadata$Metadata$4 = (value) => value.contributors;
export const Metadata$Metadata$publisher = (value) => value.publisher;
export const Metadata$Metadata$5 = (value) => value.publisher;
export const Metadata$Metadata$description = (value) => value.description;
export const Metadata$Metadata$6 = (value) => value.description;
export const Metadata$Metadata$published = (value) => value.published;
export const Metadata$Metadata$7 = (value) => value.published;
export const Metadata$Metadata$modified = (value) => value.modified;
export const Metadata$Metadata$8 = (value) => value.modified;
export const Metadata$Metadata$subjects = (value) => value.subjects;
export const Metadata$Metadata$9 = (value) => value.subjects;
export const Metadata$Metadata$rights = (value) => value.rights;
export const Metadata$Metadata$10 = (value) => value.rights;

export class Contributor extends $CustomType {
  constructor(name, role, file_as) {
    super();
    this.name = name;
    this.role = role;
    this.file_as = file_as;
  }
}
export const Contributor$Contributor = (name, role, file_as) =>
  new Contributor(name, role, file_as);
export const Contributor$isContributor = (value) =>
  value instanceof Contributor;
export const Contributor$Contributor$name = (value) => value.name;
export const Contributor$Contributor$0 = (value) => value.name;
export const Contributor$Contributor$role = (value) => value.role;
export const Contributor$Contributor$1 = (value) => value.role;
export const Contributor$Contributor$file_as = (value) => value.file_as;
export const Contributor$Contributor$2 = (value) => value.file_as;

export class ManifestItem extends $CustomType {
  constructor(id, href, media_type, properties) {
    super();
    this.id = id;
    this.href = href;
    this.media_type = media_type;
    this.properties = properties;
  }
}
export const ManifestItem$ManifestItem = (id, href, media_type, properties) =>
  new ManifestItem(id, href, media_type, properties);
export const ManifestItem$isManifestItem = (value) =>
  value instanceof ManifestItem;
export const ManifestItem$ManifestItem$id = (value) => value.id;
export const ManifestItem$ManifestItem$0 = (value) => value.id;
export const ManifestItem$ManifestItem$href = (value) => value.href;
export const ManifestItem$ManifestItem$1 = (value) => value.href;
export const ManifestItem$ManifestItem$media_type = (value) => value.media_type;
export const ManifestItem$ManifestItem$2 = (value) => value.media_type;
export const ManifestItem$ManifestItem$properties = (value) => value.properties;
export const ManifestItem$ManifestItem$3 = (value) => value.properties;

export class SpineItem extends $CustomType {
  constructor(item, linear, properties) {
    super();
    this.item = item;
    this.linear = linear;
    this.properties = properties;
  }
}
export const SpineItem$SpineItem = (item, linear, properties) =>
  new SpineItem(item, linear, properties);
export const SpineItem$isSpineItem = (value) => value instanceof SpineItem;
export const SpineItem$SpineItem$item = (value) => value.item;
export const SpineItem$SpineItem$0 = (value) => value.item;
export const SpineItem$SpineItem$linear = (value) => value.linear;
export const SpineItem$SpineItem$1 = (value) => value.linear;
export const SpineItem$SpineItem$properties = (value) => value.properties;
export const SpineItem$SpineItem$2 = (value) => value.properties;

export class TocEntry extends $CustomType {
  constructor(label, href, children) {
    super();
    this.label = label;
    this.href = href;
    this.children = children;
  }
}
export const TocEntry$TocEntry = (label, href, children) =>
  new TocEntry(label, href, children);
export const TocEntry$isTocEntry = (value) => value instanceof TocEntry;
export const TocEntry$TocEntry$label = (value) => value.label;
export const TocEntry$TocEntry$0 = (value) => value.label;
export const TocEntry$TocEntry$href = (value) => value.href;
export const TocEntry$TocEntry$1 = (value) => value.href;
export const TocEntry$TocEntry$children = (value) => value.children;
export const TocEntry$TocEntry$2 = (value) => value.children;

export class LeftToRight extends $CustomType {}
export const Direction$LeftToRight = () => new LeftToRight();
export const Direction$isLeftToRight = (value) => value instanceof LeftToRight;

export class RightToLeft extends $CustomType {}
export const Direction$RightToLeft = () => new RightToLeft();
export const Direction$isRightToLeft = (value) => value instanceof RightToLeft;

export class DefaultDirection extends $CustomType {}
export const Direction$DefaultDirection = () => new DefaultDirection();
export const Direction$isDefaultDirection = (value) =>
  value instanceof DefaultDirection;

export class Reflowable extends $CustomType {}
export const Layout$Reflowable = () => new Reflowable();
export const Layout$isReflowable = (value) => value instanceof Reflowable;

export class PrePaginated extends $CustomType {}
export const Layout$PrePaginated = () => new PrePaginated();
export const Layout$isPrePaginated = (value) => value instanceof PrePaginated;

export class Rendition extends $CustomType {
  constructor(layout, orientation, spread) {
    super();
    this.layout = layout;
    this.orientation = orientation;
    this.spread = spread;
  }
}
export const Rendition$Rendition = (layout, orientation, spread) =>
  new Rendition(layout, orientation, spread);
export const Rendition$isRendition = (value) => value instanceof Rendition;
export const Rendition$Rendition$layout = (value) => value.layout;
export const Rendition$Rendition$0 = (value) => value.layout;
export const Rendition$Rendition$orientation = (value) => value.orientation;
export const Rendition$Rendition$1 = (value) => value.orientation;
export const Rendition$Rendition$spread = (value) => value.spread;
export const Rendition$Rendition$2 = (value) => value.spread;

/**
 * The loader had no file at this path.
 */
export class MissingFile extends $CustomType {
  constructor(path) {
    super();
    this.path = path;
  }
}
export const EpubError$MissingFile = (path) => new MissingFile(path);
export const EpubError$isMissingFile = (value) => value instanceof MissingFile;
export const EpubError$MissingFile$path = (value) => value.path;
export const EpubError$MissingFile$0 = (value) => value.path;

/**
 * A file exists but is not well-formed XML.
 */
export class InvalidXml extends $CustomType {
  constructor(path, error) {
    super();
    this.path = path;
    this.error = error;
  }
}
export const EpubError$InvalidXml = (path, error) =>
  new InvalidXml(path, error);
export const EpubError$isInvalidXml = (value) => value instanceof InvalidXml;
export const EpubError$InvalidXml$path = (value) => value.path;
export const EpubError$InvalidXml$0 = (value) => value.path;
export const EpubError$InvalidXml$error = (value) => value.error;
export const EpubError$InvalidXml$1 = (value) => value.error;

/**
 * The container or package is structurally wrong; the description says
 * how.
 */
export class InvalidPackage extends $CustomType {
  constructor(description) {
    super();
    this.description = description;
  }
}
export const EpubError$InvalidPackage = (description) =>
  new InvalidPackage(description);
export const EpubError$isInvalidPackage = (value) =>
  value instanceof InvalidPackage;
export const EpubError$InvalidPackage$description = (value) =>
  value.description;
export const EpubError$InvalidPackage$0 = (value) => value.description;

/**
 * Convert an `EpubError` into a human readable message.
 */
export function error_to_string(error) {
  if (error instanceof MissingFile) {
    let path = error.path;
    return ("the container has no file at \"" + path) + "\"";
  } else if (error instanceof InvalidXml) {
    let path = error.path;
    let error$1 = error.error;
    return (("\"" + path) + "\" is not well-formed XML: ") + $glexml.error_to_string(
      error$1,
    );
  } else {
    let description = error.description;
    return description;
  }
}

/**
 * Element children matched by local name, so `dc:title` and plain `title`
 * both count regardless of the prefix a book chose.
 * 
 * @ignore
 */
function children_local(element, name) {
  let _pipe = $glexml.child_elements(element);
  return $list.filter(
    _pipe,
    (child) => { return $glexml.local_name(child.name) === name; },
  );
}

function find_cover(metadata, manifest) {
  let by_property = $list.find(
    manifest,
    (item) => { return $list.contains(item.properties, "cover-image"); },
  );
  if (by_property instanceof Ok) {
    let item = by_property[0];
    return new Some(item);
  } else {
    let _block;
    let _pipe = children_local(metadata, "meta");
    let _pipe$1 = $list.find(
      _pipe,
      (meta) => {
        return isEqual($glexml.attribute(meta, "name"), new Ok("cover"));
      },
    );
    let _pipe$2 = $result.try$(
      _pipe$1,
      (_capture) => { return $glexml.attribute(_capture, "content"); },
    );
    _block = $result.try$(
      _pipe$2,
      (id) => {
        return $list.find(manifest, (item) => { return item.id === id; });
      },
    );
    let by_meta = _block;
    if (by_meta instanceof Ok) {
      let item = by_meta[0];
      return new Some(item);
    } else {
      let _pipe$3 = $list.find(
        manifest,
        (item) => {
          return (item.id === "cover-image") && $string.starts_with(
            item.media_type,
            "image/",
          );
        },
      );
      return $option.from_result(_pipe$3);
    }
  }
}

/**
 * An element's text with whitespace collapsed, for labels and metadata.
 * 
 * @ignore
 */
function text_of(element) {
  let _pipe = $glexml.text_content(element);
  let _pipe$1 = $string.replace(_pipe, "\n", " ");
  let _pipe$2 = $string.replace(_pipe$1, "\t", " ");
  let _pipe$3 = $string.split(_pipe$2, " ");
  let _pipe$4 = $list.filter(_pipe$3, (part) => { return part !== ""; });
  return $string.join(_pipe$4, " ");
}

function parse_rendition(metadata) {
  let property = (name) => {
    let _pipe = children_local(metadata, "meta");
    let _pipe$1 = $list.find(
      _pipe,
      (meta) => {
        return isEqual(
          $glexml.attribute(meta, "property"),
          new Ok("rendition:" + name)
        );
      },
    );
    let _pipe$2 = $result.map(
      _pipe$1,
      (meta) => { return new Some(text_of(meta)); },
    );
    return $result.unwrap(_pipe$2, new None());
  };
  return new Rendition(
    (() => {
      let $ = property("layout");
      if ($ instanceof Some) {
        let $1 = $[0];
        if ($1 === "pre-paginated") {
          return new PrePaginated();
        } else {
          return new Reflowable();
        }
      } else {
        return new Reflowable();
      }
    })(),
    property("orientation"),
    property("spread"),
  );
}

function normalise(path) {
  let _pipe = $string.split(path, "/");
  let _pipe$1 = $list.fold(
    _pipe,
    toList([]),
    (acc, part) => {
      if (part === "") {
        return acc;
      } else if (part === ".") {
        return acc;
      } else if (part === "..") {
        if (acc instanceof $Empty) {
          return acc;
        } else {
          let rest = acc.tail;
          return rest;
        }
      } else {
        let part$1 = part;
        return listPrepend(part$1, acc);
      }
    },
  );
  let _pipe$2 = $list.reverse(_pipe$1);
  return $string.join(_pipe$2, "/");
}

function do_percent_decode(loop$graphemes, loop$acc) {
  while (true) {
    let graphemes = loop$graphemes;
    let acc = loop$acc;
    if (graphemes instanceof $Empty) {
      return $list.reverse(acc);
    } else {
      let $ = graphemes.tail;
      if ($ instanceof $Empty) {
        let grapheme = graphemes.head;
        let rest = $;
        loop$graphemes = rest;
        loop$acc = listPrepend($bit_array.from_string(grapheme), acc);
      } else {
        let $1 = $.tail;
        if ($1 instanceof $Empty) {
          let grapheme = graphemes.head;
          let rest = $;
          loop$graphemes = rest;
          loop$acc = listPrepend($bit_array.from_string(grapheme), acc);
        } else {
          let $2 = graphemes.head;
          if ($2 === "%") {
            let a = $.head;
            let b = $1.head;
            let rest = $1.tail;
            let $3 = $int.base_parse(a + b, 16);
            if ($3 instanceof Ok) {
              let code = $3[0];
              loop$graphemes = rest;
              loop$acc = listPrepend(toBitArray([code]), acc);
            } else {
              loop$graphemes = listPrepend(a, listPrepend(b, rest));
              loop$acc = listPrepend(toBitArray([stringBits("%")]), acc);
            }
          } else {
            let grapheme = $2;
            let rest = $;
            loop$graphemes = rest;
            loop$acc = listPrepend($bit_array.from_string(grapheme), acc);
          }
        }
      }
    }
  }
}

function percent_decode(text) {
  let $ = $string.contains(text, "%");
  if ($) {
    let _pipe = do_percent_decode($string.to_graphemes(text), toList([]));
    let _pipe$1 = $bit_array.concat(_pipe);
    let _pipe$2 = $bit_array.to_string(_pipe$1);
    return $result.unwrap(_pipe$2, text);
  } else {
    return text;
  }
}

/**
 * Resolve a reference found in the document at directory `base` to a
 * container path: percent-decoded, `.`/`..` normalised, fragment kept.
 */
export function resolve(base, reference) {
  let _block;
  let $1 = $string.split_once(reference, "#");
  if ($1 instanceof Ok) {
    let path = $1[0][0];
    let fragment = $1[0][1];
    _block = [path, "#" + fragment];
  } else {
    _block = [reference, ""];
  }
  let $ = _block;
  let path = $[0];
  let fragment = $[1];
  let path$1 = percent_decode(path);
  let _block$1;
  if (path$1 === "") {
    _block$1 = path$1;
  } else if (path$1.charCodeAt(0) === 47) {
    let absolute = path$1.slice(1);
    _block$1 = normalise(absolute);
  } else {
    if (base === "") {
      _block$1 = normalise(path$1);
    } else {
      _block$1 = normalise((base + "/") + path$1);
    }
  }
  let resolved = _block$1;
  return resolved + fragment;
}

function first_local(element, name) {
  let _pipe = children_local(element, name);
  return $list.first(_pipe);
}

/**
 * EPUB 2 `<guide>` references presented as landmarks.
 * 
 * @ignore
 */
function guide_landmarks(package$, base) {
  let $ = first_local(package$, "guide");
  if ($ instanceof Ok) {
    let guide = $[0];
    let _pipe = children_local(guide, "reference");
    return $list.filter_map(
      _pipe,
      (reference) => {
        return $result.try$(
          $glexml.attribute(reference, "href"),
          (href) => {
            let _block;
            let $1 = $glexml.attribute(reference, "title");
            if ($1 instanceof Ok) {
              let title = $1[0];
              _block = title;
            } else {
              let _pipe$1 = $glexml.attribute(reference, "type");
              _block = $result.unwrap(_pipe$1, "");
            }
            let label = _block;
            return new Ok(
              new TocEntry(label, new Some(resolve(base, href)), toList([])),
            );
          },
        );
      },
    );
  } else {
    return toList([]);
  }
}

function dirname(path) {
  let $ = (() => {
    let _pipe = $string.split(path, "/");
    return $list.reverse(_pipe);
  })();
  if ($ instanceof $Empty) {
    return "";
  } else {
    let rest = $.tail;
    let _pipe = rest;
    let _pipe$1 = $list.reverse(_pipe);
    return $string.join(_pipe$1, "/");
  }
}

function ncx_points(parent, base) {
  let _pipe = children_local(parent, "navPoint");
  return $list.map(
    _pipe,
    (point) => {
      let _block;
      let _pipe$1 = first_local(point, "navLabel");
      let _pipe$2 = $result.try$(
        _pipe$1,
        (_capture) => { return first_local(_capture, "text"); },
      );
      let _pipe$3 = $result.map(_pipe$2, text_of);
      _block = $result.unwrap(_pipe$3, "");
      let label = _block;
      let _block$1;
      let _pipe$4 = first_local(point, "content");
      let _pipe$5 = $result.try$(
        _pipe$4,
        (_capture) => { return $glexml.attribute(_capture, "src"); },
      );
      let _pipe$6 = $result.map(
        _pipe$5,
        (src) => { return new Some(resolve(base, src)); },
      );
      _block$1 = $result.unwrap(_pipe$6, new None());
      let href = _block$1;
      return new TocEntry(label, href, ncx_points(point, base));
    },
  );
}

/**
 * Parse an EPUB 2 NCX `<navMap>` into the same tree shape.
 * 
 * @ignore
 */
function parse_ncx(root, base) {
  let $ = first_local(root, "navMap");
  if ($ instanceof Ok) {
    let nav_map = $[0];
    return ncx_points(nav_map, base);
  } else {
    return toList([]);
  }
}

function read_xml(loader, path) {
  return $result.try$(
    (() => {
      let _pipe = loader(path);
      return $result.replace_error(_pipe, new MissingFile(path));
    })(),
    (bytes) => {
      let _pipe = $glexml.parse_bytes(bytes);
      return $result.map_error(
        _pipe,
        (_capture) => { return new InvalidXml(path, _capture); },
      );
    },
  );
}

function nav_list(ol, base) {
  let _pipe = $glexml.children_named(ol, "li");
  return $list.map(
    _pipe,
    (li) => {
      let _block;
      let _pipe$1 = $glexml.first_child_named(li, "a");
      _block = $result.lazy_or(
        _pipe$1,
        () => { return $glexml.first_child_named(li, "span"); },
      );
      let link = _block;
      let _block$1;
      let _pipe$2 = link;
      let _pipe$3 = $result.map(_pipe$2, text_of);
      _block$1 = $result.unwrap(_pipe$3, "");
      let label = _block$1;
      let _block$2;
      let _pipe$4 = link;
      let _pipe$5 = $result.try$(
        _pipe$4,
        (_capture) => { return $glexml.attribute(_capture, "href"); },
      );
      let _pipe$6 = $result.map(
        _pipe$5,
        (href) => { return new Some(resolve(base, href)); },
      );
      _block$2 = $result.unwrap(_pipe$6, new None());
      let href = _block$2;
      let _block$3;
      let $ = $glexml.first_child_named(li, "ol");
      if ($ instanceof Ok) {
        let ol$1 = $[0];
        _block$3 = nav_list(ol$1, base);
      } else {
        _block$3 = toList([]);
      }
      let children = _block$3;
      return new TocEntry(label, href, children);
    },
  );
}

function selector_all(element, css) {
  let $ = $selector.select(element, css);
  if ($ instanceof Ok) {
    let found = $[0];
    return found;
  } else {
    return toList([]);
  }
}

/**
 * Parse one `<nav epub:type="...">` of an EPUB 3 navigation document into
 * a tree.
 * 
 * @ignore
 */
function parse_nav(root, base, kind) {
  let $ = selector_all(root, ("nav[epub|type~=" + kind) + "] > ol");
  if ($ instanceof $Empty) {
    return $;
  } else {
    let ol = $.head;
    return nav_list(ol, base);
  }
}

function load_navigation(loader, base, manifest, spine, package$) {
  let _block;
  let _pipe = $list.find(
    manifest,
    (item) => { return $list.contains(item.properties, "nav"); },
  );
  _block = $result.try$(
    _pipe,
    (item) => {
      let _pipe$1 = read_xml(loader, item.href);
      let _pipe$2 = $result.map(
        _pipe$1,
        (document) => { return [item.href, document]; },
      );
      return $result.replace_error(_pipe$2, undefined);
    },
  );
  let from_nav = _block;
  if (from_nav instanceof Ok) {
    let path = from_nav[0][0];
    let document$1 = from_nav[0][1];
    let nav_base = dirname(path);
    return [
      parse_nav(document$1.root, nav_base, "toc"),
      parse_nav(document$1.root, nav_base, "page-list"),
      (() => {
        let $ = parse_nav(document$1.root, nav_base, "landmarks");
        if ($ instanceof $Empty) {
          return guide_landmarks(package$, base);
        } else {
          return $;
        }
      })(),
    ];
  } else {
    let _block$1;
    let _pipe$1 = $glexml.attribute(spine, "toc");
    let _pipe$2 = $result.try$(
      _pipe$1,
      (id) => { return $list.find(manifest, (i) => { return i.id === id; }); },
    );
    _block$1 = $result.lazy_or(
      _pipe$2,
      () => {
        return $list.find(
          manifest,
          (item) => { return item.media_type === "application/x-dtbncx+xml"; },
        );
      },
    );
    let ncx_item = _block$1;
    let _block$2;
    let _pipe$3 = ncx_item;
    let _pipe$4 = $result.try$(
      _pipe$3,
      (item) => {
        let _pipe$4 = read_xml(loader, item.href);
        let _pipe$5 = $result.map(
          _pipe$4,
          (document) => { return parse_ncx(document.root, dirname(item.href)); },
        );
        return $result.replace_error(_pipe$5, undefined);
      },
    );
    _block$2 = $result.unwrap(_pipe$4, toList([]));
    let toc = _block$2;
    return [toc, toList([]), guide_landmarks(package$, base)];
  }
}

function first_local_text(element, name) {
  let _pipe = first_local(element, name);
  let _pipe$1 = $result.map(
    _pipe,
    (found) => { return new Some(text_of(found)); },
  );
  return $result.unwrap(_pipe$1, new None());
}

/**
 * `<meta refines="#id" property="p">value</meta>` associations, by the id
 * they refine.
 * 
 * @ignore
 */
function refinements_of(metadata) {
  let _pipe = children_local(metadata, "meta");
  let _pipe$1 = $list.filter_map(
    _pipe,
    (meta) => {
      let $ = $glexml.attribute(meta, "refines");
      let $1 = $glexml.attribute(meta, "property");
      if ($ instanceof Ok && $1 instanceof Ok) {
        let $2 = $[0];
        if ($2.charCodeAt(0) === 35) {
          let property = $1[0];
          let id = $2.slice(1);
          return new Ok([id, property, text_of(meta)]);
        } else {
          return new Error(undefined);
        }
      } else {
        return new Error(undefined);
      }
    },
  );
  return $list.fold(
    _pipe$1,
    $dict.new$(),
    (acc, entry) => {
      let id = entry[0];
      let property = entry[1];
      let value = entry[2];
      return $dict.upsert(
        acc,
        id,
        (existing) => {
          return listPrepend(
            [property, value],
            $option.unwrap(existing, toList([])),
          );
        },
      );
    },
  );
}

function parse_metadata(package$, metadata) {
  let refinements = refinements_of(metadata);
  let refinement = (element, property) => {
    let $ = $glexml.attribute(element, "id");
    if ($ instanceof Ok) {
      let id = $[0];
      let _pipe = $dict.get(refinements, id);
      let _pipe$1 = $result.unwrap(_pipe, toList([]));
      let _pipe$2 = $list.find(
        _pipe$1,
        (pair) => { return pair[0] === property; },
      );
      let _pipe$3 = $result.map(
        _pipe$2,
        (pair) => { return new Some(pair[1]); },
      );
      return $result.unwrap(_pipe$3, new None());
    } else {
      return new None();
    }
  };
  let identifiers = children_local(metadata, "identifier");
  let _block;
  let $ = $glexml.attribute(package$, "unique-identifier");
  if ($ instanceof Ok) {
    let wanted = $[0];
    let _pipe = identifiers;
    let _pipe$1 = $list.find(
      _pipe,
      (element) => {
        return isEqual($glexml.attribute(element, "id"), new Ok(wanted));
      },
    );
    _block = $result.map(_pipe$1, text_of);
  } else {
    _block = $;
  }
  let identifier = _block;
  let _block$1;
  if (identifier instanceof Ok) {
    let identifier$1 = identifier[0];
    _block$1 = identifier$1;
  } else {
    let _pipe = identifiers;
    let _pipe$1 = $list.first(_pipe);
    let _pipe$2 = $result.map(_pipe$1, text_of);
    _block$1 = $result.unwrap(_pipe$2, "");
  }
  let identifier$1 = _block$1;
  let titles = children_local(metadata, "title");
  let _block$2;
  let _pipe = titles;
  let _pipe$1 = $list.find(
    _pipe,
    (element) => {
      return isEqual(refinement(element, "title-type"), new Some("main"));
    },
  );
  let _pipe$2 = $result.lazy_or(_pipe$1, () => { return $list.first(titles); });
  let _pipe$3 = $result.map(_pipe$2, text_of);
  _block$2 = $result.unwrap(_pipe$3, "");
  let title = _block$2;
  let contributor = (element) => {
    return new Contributor(
      text_of(element),
      (() => {
        let _pipe$4 = refinement(element, "role");
        return $option.lazy_or(
          _pipe$4,
          () => {
            let _pipe$5 = $glexml.attribute(element, "opf:role");
            return $option.from_result(_pipe$5);
          },
        );
      })(),
      (() => {
        let _pipe$4 = refinement(element, "file-as");
        return $option.lazy_or(
          _pipe$4,
          () => {
            let _pipe$5 = $glexml.attribute(element, "opf:file-as");
            return $option.from_result(_pipe$5);
          },
        );
      })(),
    );
  };
  let property_meta = (property) => {
    let _pipe$4 = children_local(metadata, "meta");
    let _pipe$5 = $list.find(
      _pipe$4,
      (meta) => {
        return isEqual($glexml.attribute(meta, "property"), new Ok(property));
      },
    );
    let _pipe$6 = $result.map(
      _pipe$5,
      (meta) => { return new Some(text_of(meta)); },
    );
    return $result.unwrap(_pipe$6, new None());
  };
  return new Metadata(
    identifier$1,
    title,
    (() => {
      let _pipe$4 = first_local_text(metadata, "language");
      return $option.unwrap(_pipe$4, "");
    })(),
    (() => {
      let _pipe$4 = children_local(metadata, "creator");
      return $list.map(_pipe$4, contributor);
    })(),
    (() => {
      let _pipe$4 = children_local(metadata, "contributor");
      return $list.map(_pipe$4, contributor);
    })(),
    first_local_text(metadata, "publisher"),
    first_local_text(metadata, "description"),
    first_local_text(metadata, "date"),
    property_meta("dcterms:modified"),
    (() => {
      let _pipe$4 = children_local(metadata, "subject");
      return $list.map(_pipe$4, text_of);
    })(),
    first_local_text(metadata, "rights"),
  );
}

function properties_of(element) {
  let _pipe = $glexml.attribute(element, "properties");
  let _pipe$1 = $result.unwrap(_pipe, "");
  let _pipe$2 = $string.split(_pipe$1, " ");
  return $list.filter(_pipe$2, (property) => { return property !== ""; });
}

/**
 * The container path without any `#fragment`.
 */
export function strip_fragment(href) {
  let $ = $string.split_once(href, "#");
  if ($ instanceof Ok) {
    let path = $[0][0];
    return path;
  } else {
    return href;
  }
}

function build_book(loader, package_path, package$) {
  let base = dirname(package_path);
  let _block;
  let _pipe = $glexml.attribute(package$, "version");
  _block = $result.unwrap(_pipe, "3.0");
  let version = _block;
  return $result.try$(
    (() => {
      let _pipe$1 = first_local(package$, "metadata");
      return $result.replace_error(
        _pipe$1,
        new InvalidPackage("the package document has no <metadata>"),
      );
    })(),
    (metadata_element) => {
      return $result.try$(
        (() => {
          let _pipe$1 = first_local(package$, "manifest");
          return $result.replace_error(
            _pipe$1,
            new InvalidPackage("the package document has no <manifest>"),
          );
        })(),
        (manifest_element) => {
          return $result.try$(
            (() => {
              let _pipe$1 = first_local(package$, "spine");
              return $result.replace_error(
                _pipe$1,
                new InvalidPackage("the package document has no <spine>"),
              );
            })(),
            (spine_element) => {
              let _block$1;
              let _pipe$1 = children_local(manifest_element, "item");
              _block$1 = $list.filter_map(
                _pipe$1,
                (item) => {
                  let $ = $glexml.attribute(item, "id");
                  let $1 = $glexml.attribute(item, "href");
                  if ($ instanceof Ok && $1 instanceof Ok) {
                    let id = $[0];
                    let href = $1[0];
                    return new Ok(
                      new ManifestItem(
                        id,
                        (() => {
                          let _pipe$2 = resolve(base, href);
                          return strip_fragment(_pipe$2);
                        })(),
                        (() => {
                          let _pipe$2 = $glexml.attribute(item, "media-type");
                          return $result.unwrap(_pipe$2, "");
                        })(),
                        properties_of(item),
                      ),
                    );
                  } else {
                    return new Error(undefined);
                  }
                },
              );
              let manifest = _block$1;
              let _block$2;
              let _pipe$2 = manifest;
              let _pipe$3 = $list.map(
                _pipe$2,
                (item) => { return [item.id, item]; },
              );
              _block$2 = $dict.from_list(_pipe$3);
              let by_id = _block$2;
              let _block$3;
              let _pipe$4 = children_local(spine_element, "itemref");
              _block$3 = $list.filter_map(
                _pipe$4,
                (itemref) => {
                  return $result.try$(
                    $glexml.attribute(itemref, "idref"),
                    (idref) => {
                      return $result.try$(
                        $dict.get(by_id, idref),
                        (item) => {
                          return new Ok(
                            new SpineItem(
                              item,
                              !isEqual(
                                $glexml.attribute(itemref, "linear"),
                                new Ok("no")
                              ),
                              properties_of(itemref),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
              let spine = _block$3;
              let metadata = parse_metadata(package$, metadata_element);
              let $ = load_navigation(
                loader,
                base,
                manifest,
                spine_element,
                package$,
              );
              let toc = $[0];
              let page_list = $[1];
              let landmarks = $[2];
              return new Ok(
                new Book(
                  version,
                  metadata,
                  manifest,
                  spine,
                  toc,
                  page_list,
                  landmarks,
                  (() => {
                    let $1 = $glexml.attribute(
                      spine_element,
                      "page-progression-direction",
                    );
                    if ($1 instanceof Ok) {
                      let $2 = $1[0];
                      if ($2 === "rtl") {
                        return new RightToLeft();
                      } else if ($2 === "ltr") {
                        return new LeftToRight();
                      } else {
                        return new DefaultDirection();
                      }
                    } else {
                      return new DefaultDirection();
                    }
                  })(),
                  parse_rendition(metadata_element),
                  find_cover(metadata_element, manifest),
                  loader,
                ),
              );
            },
          );
        },
      );
    },
  );
}

/**
 * Open a publication: read `META-INF/container.xml`, find the package
 * document, and parse the package, navigation, and cover information.
 */
export function open(loader) {
  return $result.try$(
    read_xml(loader, "META-INF/container.xml"),
    (container) => {
      return $result.try$(
        (() => {
          let _pipe = selector_all(container.root, "rootfiles > rootfile");
          let _pipe$1 = $list.filter_map(
            _pipe,
            (rootfile) => {
              let $ = $glexml.attribute(rootfile, "media-type");
              if ($ instanceof Ok) {
                let $1 = $[0];
                if ($1 === "application/oebps-package+xml") {
                  return $glexml.attribute(rootfile, "full-path");
                } else {
                  return new Error(undefined);
                }
              } else {
                return new Error(undefined);
              }
            },
          );
          let _pipe$2 = $list.first(_pipe$1);
          return $result.replace_error(
            _pipe$2,
            new InvalidPackage("container.xml names no package document"),
          );
        })(),
        (package_path) => {
          let package_path$1 = normalise(percent_decode(package_path));
          return $result.try$(
            read_xml(loader, package_path$1),
            (package$) => {
              return build_book(loader, package_path$1, package$.root);
            },
          );
        },
      );
    },
  );
}

/**
 * Read a manifest item's bytes from the container.
 */
export function resource(book, item) {
  let _pipe = book.loader(item.href);
  return $result.replace_error(_pipe, new MissingFile(item.href));
}

/**
 * Like `document`, with extra DTD declarations available — typically the
 * XHTML entity set for EPUB 2 content documents.
 */
export function document_with_dtd(book, item, dtd) {
  return $result.try$(
    resource(book, item),
    (bytes) => {
      let _pipe = $glexml.parse_bytes_with_dtd(bytes, dtd);
      return $result.map_error(
        _pipe,
        (_capture) => { return new InvalidXml(item.href, _capture); },
      );
    },
  );
}

/**
 * Read and parse a manifest item as XML — a content document, for
 * instance. EPUB 2 XHTML may use the named entities of the XHTML DTD;
 * supply them with `document_with_dtd` if you need them.
 */
export function document(book, item) {
  return document_with_dtd(book, item, $glexml.empty_dtd());
}

/**
 * Find the manifest item a container path (as produced in `TocEntry.href`,
 * fragment ignored) refers to.
 */
export function item_for_href(book, href) {
  let path = strip_fragment(href);
  return $list.find(book.manifest, (item) => { return item.href === path; });
}

/**
 * Whether a reference in a content document points outside the container.
 */
export function is_external(reference) {
  let $ = $string.split_once(reference, ":");
  if ($ instanceof Ok) {
    let scheme = $[0][0];
    return !$string.contains(scheme, "/");
  } else {
    return false;
  }
}
