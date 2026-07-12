import * as $bit_array from "../gleam_stdlib/gleam/bit_array.mjs";
import * as $dict from "../gleam_stdlib/gleam/dict.mjs";
import * as $int from "../gleam_stdlib/gleam/int.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../gleam_stdlib/gleam/option.mjs";
import * as $result from "../gleam_stdlib/gleam/result.mjs";
import * as $string from "../gleam_stdlib/gleam/string.mjs";
import * as $string_tree from "../gleam_stdlib/gleam/string_tree.mjs";
import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  makeError,
  isEqual,
  toBitArray,
  bitArraySlice,
  stringBits,
} from "./gleam.mjs";

const FILEPATH = "src/glexml.gleam";

export class Document extends $CustomType {
  constructor(version, encoding, standalone, doctype, prolog, root, epilogue) {
    super();
    this.version = version;
    this.encoding = encoding;
    this.standalone = standalone;
    this.doctype = doctype;
    this.prolog = prolog;
    this.root = root;
    this.epilogue = epilogue;
  }
}
export const Document$Document = (version, encoding, standalone, doctype, prolog, root, epilogue) =>
  new Document(version, encoding, standalone, doctype, prolog, root, epilogue);
export const Document$isDocument = (value) => value instanceof Document;
export const Document$Document$version = (value) => value.version;
export const Document$Document$0 = (value) => value.version;
export const Document$Document$encoding = (value) => value.encoding;
export const Document$Document$1 = (value) => value.encoding;
export const Document$Document$standalone = (value) => value.standalone;
export const Document$Document$2 = (value) => value.standalone;
export const Document$Document$doctype = (value) => value.doctype;
export const Document$Document$3 = (value) => value.doctype;
export const Document$Document$prolog = (value) => value.prolog;
export const Document$Document$4 = (value) => value.prolog;
export const Document$Document$root = (value) => value.root;
export const Document$Document$5 = (value) => value.root;
export const Document$Document$epilogue = (value) => value.epilogue;
export const Document$Document$6 = (value) => value.epilogue;

export class Doctype extends $CustomType {
  constructor(root_name, external_id, declarations) {
    super();
    this.root_name = root_name;
    this.external_id = external_id;
    this.declarations = declarations;
  }
}
export const Doctype$Doctype = (root_name, external_id, declarations) =>
  new Doctype(root_name, external_id, declarations);
export const Doctype$isDoctype = (value) => value instanceof Doctype;
export const Doctype$Doctype$root_name = (value) => value.root_name;
export const Doctype$Doctype$0 = (value) => value.root_name;
export const Doctype$Doctype$external_id = (value) => value.external_id;
export const Doctype$Doctype$1 = (value) => value.external_id;
export const Doctype$Doctype$declarations = (value) => value.declarations;
export const Doctype$Doctype$2 = (value) => value.declarations;

export class System extends $CustomType {
  constructor(system) {
    super();
    this.system = system;
  }
}
export const ExternalId$System = (system) => new System(system);
export const ExternalId$isSystem = (value) => value instanceof System;
export const ExternalId$System$system = (value) => value.system;
export const ExternalId$System$0 = (value) => value.system;

export class Public extends $CustomType {
  constructor(public$, system) {
    super();
    this.public = public$;
    this.system = system;
  }
}
export const ExternalId$Public = (public$, system) =>
  new Public(public$, system);
export const ExternalId$isPublic = (value) => value instanceof Public;
export const ExternalId$Public$public = (value) => value.public;
export const ExternalId$Public$0 = (value) => value.public;
export const ExternalId$Public$system = (value) => value.system;
export const ExternalId$Public$1 = (value) => value.system;

export class Dtd extends $CustomType {
  constructor(elements, attribute_lists, entities, parameter_entities, notations, duplicate_elements, pe_nesting_violations) {
    super();
    this.elements = elements;
    this.attribute_lists = attribute_lists;
    this.entities = entities;
    this.parameter_entities = parameter_entities;
    this.notations = notations;
    this.duplicate_elements = duplicate_elements;
    this.pe_nesting_violations = pe_nesting_violations;
  }
}
export const Dtd$Dtd = (elements, attribute_lists, entities, parameter_entities, notations, duplicate_elements, pe_nesting_violations) =>
  new Dtd(elements,
  attribute_lists,
  entities,
  parameter_entities,
  notations,
  duplicate_elements,
  pe_nesting_violations);
export const Dtd$isDtd = (value) => value instanceof Dtd;
export const Dtd$Dtd$elements = (value) => value.elements;
export const Dtd$Dtd$0 = (value) => value.elements;
export const Dtd$Dtd$attribute_lists = (value) => value.attribute_lists;
export const Dtd$Dtd$1 = (value) => value.attribute_lists;
export const Dtd$Dtd$entities = (value) => value.entities;
export const Dtd$Dtd$2 = (value) => value.entities;
export const Dtd$Dtd$parameter_entities = (value) => value.parameter_entities;
export const Dtd$Dtd$3 = (value) => value.parameter_entities;
export const Dtd$Dtd$notations = (value) => value.notations;
export const Dtd$Dtd$4 = (value) => value.notations;
export const Dtd$Dtd$duplicate_elements = (value) => value.duplicate_elements;
export const Dtd$Dtd$5 = (value) => value.duplicate_elements;
export const Dtd$Dtd$pe_nesting_violations = (value) =>
  value.pe_nesting_violations;
export const Dtd$Dtd$6 = (value) => value.pe_nesting_violations;

/**
 * An entity whose replacement text was given inline. Parameter and
 * character references have already been expanded in it.
 */
export class InternalEntity extends $CustomType {
  constructor(replacement) {
    super();
    this.replacement = replacement;
  }
}
export const Entity$InternalEntity = (replacement) =>
  new InternalEntity(replacement);
export const Entity$isInternalEntity = (value) =>
  value instanceof InternalEntity;
export const Entity$InternalEntity$replacement = (value) => value.replacement;
export const Entity$InternalEntity$0 = (value) => value.replacement;

/**
 * An entity whose content lives in another resource. A `notation` marks
 * an unparsed (binary) entity. External entities cannot be expanded
 * during parsing; supply their content as `InternalEntity` values in a
 * DTD passed to `parse_with_dtd` if you need it.
 *
 * `declared_in` names the external parameter entity whose replacement
 * text contained this declaration, if any: the entity's system
 * identifier resolves relative to that entity's own location rather
 * than the document's.
 */
export class ExternalEntity extends $CustomType {
  constructor(id, notation, declared_in) {
    super();
    this.id = id;
    this.notation = notation;
    this.declared_in = declared_in;
  }
}
export const Entity$ExternalEntity = (id, notation, declared_in) =>
  new ExternalEntity(id, notation, declared_in);
export const Entity$isExternalEntity = (value) =>
  value instanceof ExternalEntity;
export const Entity$ExternalEntity$id = (value) => value.id;
export const Entity$ExternalEntity$0 = (value) => value.id;
export const Entity$ExternalEntity$notation = (value) => value.notation;
export const Entity$ExternalEntity$1 = (value) => value.notation;
export const Entity$ExternalEntity$declared_in = (value) => value.declared_in;
export const Entity$ExternalEntity$2 = (value) => value.declared_in;

/**
 * `EMPTY`: no children at all.
 */
export class EmptyContent extends $CustomType {}
export const ContentModel$EmptyContent = () => new EmptyContent();
export const ContentModel$isEmptyContent = (value) =>
  value instanceof EmptyContent;

/**
 * `ANY`: anything goes.
 */
export class AnyContent extends $CustomType {}
export const ContentModel$AnyContent = () => new AnyContent();
export const ContentModel$isAnyContent = (value) => value instanceof AnyContent;

/**
 * `(#PCDATA | a | b)*`: text freely mixed with the listed elements.
 */
export class MixedContent extends $CustomType {
  constructor(allowed) {
    super();
    this.allowed = allowed;
  }
}
export const ContentModel$MixedContent = (allowed) => new MixedContent(allowed);
export const ContentModel$isMixedContent = (value) =>
  value instanceof MixedContent;
export const ContentModel$MixedContent$allowed = (value) => value.allowed;
export const ContentModel$MixedContent$0 = (value) => value.allowed;

/**
 * A children content model such as `(head, body)` or `(a | b)+`.
 */
export class ElementContent extends $CustomType {
  constructor(particle) {
    super();
    this.particle = particle;
  }
}
export const ContentModel$ElementContent = (particle) =>
  new ElementContent(particle);
export const ContentModel$isElementContent = (value) =>
  value instanceof ElementContent;
export const ContentModel$ElementContent$particle = (value) => value.particle;
export const ContentModel$ElementContent$0 = (value) => value.particle;

export class NameParticle extends $CustomType {
  constructor(name, occurrence) {
    super();
    this.name = name;
    this.occurrence = occurrence;
  }
}
export const Particle$NameParticle = (name, occurrence) =>
  new NameParticle(name, occurrence);
export const Particle$isNameParticle = (value) => value instanceof NameParticle;
export const Particle$NameParticle$name = (value) => value.name;
export const Particle$NameParticle$0 = (value) => value.name;
export const Particle$NameParticle$occurrence = (value) => value.occurrence;
export const Particle$NameParticle$1 = (value) => value.occurrence;

export class Sequence extends $CustomType {
  constructor(particles, occurrence) {
    super();
    this.particles = particles;
    this.occurrence = occurrence;
  }
}
export const Particle$Sequence = (particles, occurrence) =>
  new Sequence(particles, occurrence);
export const Particle$isSequence = (value) => value instanceof Sequence;
export const Particle$Sequence$particles = (value) => value.particles;
export const Particle$Sequence$0 = (value) => value.particles;
export const Particle$Sequence$occurrence = (value) => value.occurrence;
export const Particle$Sequence$1 = (value) => value.occurrence;

export class Choice extends $CustomType {
  constructor(particles, occurrence) {
    super();
    this.particles = particles;
    this.occurrence = occurrence;
  }
}
export const Particle$Choice = (particles, occurrence) =>
  new Choice(particles, occurrence);
export const Particle$isChoice = (value) => value instanceof Choice;
export const Particle$Choice$particles = (value) => value.particles;
export const Particle$Choice$0 = (value) => value.particles;
export const Particle$Choice$occurrence = (value) => value.occurrence;
export const Particle$Choice$1 = (value) => value.occurrence;

export const Particle$occurrence = (value) => value.occurrence;

export class ExactlyOne extends $CustomType {}
export const Occurrence$ExactlyOne = () => new ExactlyOne();
export const Occurrence$isExactlyOne = (value) => value instanceof ExactlyOne;

export class ZeroOrOne extends $CustomType {}
export const Occurrence$ZeroOrOne = () => new ZeroOrOne();
export const Occurrence$isZeroOrOne = (value) => value instanceof ZeroOrOne;

export class ZeroOrMore extends $CustomType {}
export const Occurrence$ZeroOrMore = () => new ZeroOrMore();
export const Occurrence$isZeroOrMore = (value) => value instanceof ZeroOrMore;

export class OneOrMore extends $CustomType {}
export const Occurrence$OneOrMore = () => new OneOrMore();
export const Occurrence$isOneOrMore = (value) => value instanceof OneOrMore;

export class AttributeDeclaration extends $CustomType {
  constructor(name, kind, default$) {
    super();
    this.name = name;
    this.kind = kind;
    this.default = default$;
  }
}
export const AttributeDeclaration$AttributeDeclaration = (name, kind, default$) =>
  new AttributeDeclaration(name, kind, default$);
export const AttributeDeclaration$isAttributeDeclaration = (value) =>
  value instanceof AttributeDeclaration;
export const AttributeDeclaration$AttributeDeclaration$name = (value) =>
  value.name;
export const AttributeDeclaration$AttributeDeclaration$0 = (value) =>
  value.name;
export const AttributeDeclaration$AttributeDeclaration$kind = (value) =>
  value.kind;
export const AttributeDeclaration$AttributeDeclaration$1 = (value) =>
  value.kind;
export const AttributeDeclaration$AttributeDeclaration$default = (value) =>
  value.default;
export const AttributeDeclaration$AttributeDeclaration$2 = (value) =>
  value.default;

export class CdataAttribute extends $CustomType {}
export const AttributeKind$CdataAttribute = () => new CdataAttribute();
export const AttributeKind$isCdataAttribute = (value) =>
  value instanceof CdataAttribute;

export class IdAttribute extends $CustomType {}
export const AttributeKind$IdAttribute = () => new IdAttribute();
export const AttributeKind$isIdAttribute = (value) =>
  value instanceof IdAttribute;

export class IdRefAttribute extends $CustomType {}
export const AttributeKind$IdRefAttribute = () => new IdRefAttribute();
export const AttributeKind$isIdRefAttribute = (value) =>
  value instanceof IdRefAttribute;

export class IdRefsAttribute extends $CustomType {}
export const AttributeKind$IdRefsAttribute = () => new IdRefsAttribute();
export const AttributeKind$isIdRefsAttribute = (value) =>
  value instanceof IdRefsAttribute;

export class EntityAttribute extends $CustomType {}
export const AttributeKind$EntityAttribute = () => new EntityAttribute();
export const AttributeKind$isEntityAttribute = (value) =>
  value instanceof EntityAttribute;

export class EntitiesAttribute extends $CustomType {}
export const AttributeKind$EntitiesAttribute = () => new EntitiesAttribute();
export const AttributeKind$isEntitiesAttribute = (value) =>
  value instanceof EntitiesAttribute;

export class NmtokenAttribute extends $CustomType {}
export const AttributeKind$NmtokenAttribute = () => new NmtokenAttribute();
export const AttributeKind$isNmtokenAttribute = (value) =>
  value instanceof NmtokenAttribute;

export class NmtokensAttribute extends $CustomType {}
export const AttributeKind$NmtokensAttribute = () => new NmtokensAttribute();
export const AttributeKind$isNmtokensAttribute = (value) =>
  value instanceof NmtokensAttribute;

export class NotationAttribute extends $CustomType {
  constructor(allowed) {
    super();
    this.allowed = allowed;
  }
}
export const AttributeKind$NotationAttribute = (allowed) =>
  new NotationAttribute(allowed);
export const AttributeKind$isNotationAttribute = (value) =>
  value instanceof NotationAttribute;
export const AttributeKind$NotationAttribute$allowed = (value) => value.allowed;
export const AttributeKind$NotationAttribute$0 = (value) => value.allowed;

export class EnumeratedAttribute extends $CustomType {
  constructor(allowed) {
    super();
    this.allowed = allowed;
  }
}
export const AttributeKind$EnumeratedAttribute = (allowed) =>
  new EnumeratedAttribute(allowed);
export const AttributeKind$isEnumeratedAttribute = (value) =>
  value instanceof EnumeratedAttribute;
export const AttributeKind$EnumeratedAttribute$allowed = (value) =>
  value.allowed;
export const AttributeKind$EnumeratedAttribute$0 = (value) => value.allowed;

export class Required extends $CustomType {}
export const AttributeDefault$Required = () => new Required();
export const AttributeDefault$isRequired = (value) => value instanceof Required;

export class Implied extends $CustomType {}
export const AttributeDefault$Implied = () => new Implied();
export const AttributeDefault$isImplied = (value) => value instanceof Implied;

export class Fixed extends $CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
}
export const AttributeDefault$Fixed = (value) => new Fixed(value);
export const AttributeDefault$isFixed = (value) => value instanceof Fixed;
export const AttributeDefault$Fixed$value = (value) => value.value;
export const AttributeDefault$Fixed$0 = (value) => value.value;

export class Default extends $CustomType {
  constructor(value) {
    super();
    this.value = value;
  }
}
export const AttributeDefault$Default = (value) => new Default(value);
export const AttributeDefault$isDefault = (value) => value instanceof Default;
export const AttributeDefault$Default$value = (value) => value.value;
export const AttributeDefault$Default$0 = (value) => value.value;

export class Element extends $CustomType {
  constructor(name, attributes, children) {
    super();
    this.name = name;
    this.attributes = attributes;
    this.children = children;
  }
}
export const Element$Element = (name, attributes, children) =>
  new Element(name, attributes, children);
export const Element$isElement = (value) => value instanceof Element;
export const Element$Element$name = (value) => value.name;
export const Element$Element$0 = (value) => value.name;
export const Element$Element$attributes = (value) => value.attributes;
export const Element$Element$1 = (value) => value.attributes;
export const Element$Element$children = (value) => value.children;
export const Element$Element$2 = (value) => value.children;

export class Attribute extends $CustomType {
  constructor(name, value) {
    super();
    this.name = name;
    this.value = value;
  }
}
export const Attribute$Attribute = (name, value) => new Attribute(name, value);
export const Attribute$isAttribute = (value) => value instanceof Attribute;
export const Attribute$Attribute$name = (value) => value.name;
export const Attribute$Attribute$0 = (value) => value.name;
export const Attribute$Attribute$value = (value) => value.value;
export const Attribute$Attribute$1 = (value) => value.value;

export class ElementNode extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Node$ElementNode = ($0) => new ElementNode($0);
export const Node$isElementNode = (value) => value instanceof ElementNode;
export const Node$ElementNode$0 = (value) => value[0];

/**
 * Character data. Entity and character references have been decoded, and
 * CDATA sections become text nodes with their contents kept verbatim.
 * Whitespace is preserved.
 *
 * `literal` is False when any of the text came from a CDATA section or
 * from a character reference recognised in content. The distinction
 * matters for one validity rule: in element-only content models,
 * whitespace between children only counts as separator whitespace when
 * it is literal. Entity expansions still count as literal, unless the
 * replacement text itself contained CDATA sections or character
 * references.
 */
export class TextNode extends $CustomType {
  constructor(text, literal) {
    super();
    this.text = text;
    this.literal = literal;
  }
}
export const Node$TextNode = (text, literal) => new TextNode(text, literal);
export const Node$isTextNode = (value) => value instanceof TextNode;
export const Node$TextNode$text = (value) => value.text;
export const Node$TextNode$0 = (value) => value.text;
export const Node$TextNode$literal = (value) => value.literal;
export const Node$TextNode$1 = (value) => value.literal;

/**
 * A comment, with the `<!--` and `-->` delimiters removed.
 */
export class CommentNode extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Node$CommentNode = ($0) => new CommentNode($0);
export const Node$isCommentNode = (value) => value instanceof CommentNode;
export const Node$CommentNode$0 = (value) => value[0];

/**
 * A processing instruction such as `<?xml-stylesheet href="a.xsl"?>`,
 * split into its target and content. The whitespace separating the two
 * is removed; the rest of the content is kept verbatim.
 */
export class ProcessingInstructionNode extends $CustomType {
  constructor(target, content) {
    super();
    this.target = target;
    this.content = content;
  }
}
export const Node$ProcessingInstructionNode = (target, content) =>
  new ProcessingInstructionNode(target, content);
export const Node$isProcessingInstructionNode = (value) =>
  value instanceof ProcessingInstructionNode;
export const Node$ProcessingInstructionNode$target = (value) => value.target;
export const Node$ProcessingInstructionNode$0 = (value) => value.target;
export const Node$ProcessingInstructionNode$content = (value) => value.content;
export const Node$ProcessingInstructionNode$1 = (value) => value.content;

/**
 * A reference to an entity that was not declared, in a document whose
 * DTD could not have been read completely (it has an external subset or
 * uses parameter entity references, and is not standalone). In that
 * situation the XML specification makes an undeclared entity a validity
 * error rather than a well-formedness error, so the reference is kept
 * unexpanded instead of failing the parse. In all other documents an
 * undeclared entity is still an `UnknownEntity` parse error.
 */
export class EntityReferenceNode extends $CustomType {
  constructor(entity) {
    super();
    this.entity = entity;
  }
}
export const Node$EntityReferenceNode = (entity) =>
  new EntityReferenceNode(entity);
export const Node$isEntityReferenceNode = (value) =>
  value instanceof EntityReferenceNode;
export const Node$EntityReferenceNode$entity = (value) => value.entity;
export const Node$EntityReferenceNode$0 = (value) => value.entity;

export class ParseError extends $CustomType {
  constructor(kind, line, column, offset) {
    super();
    this.kind = kind;
    this.line = line;
    this.column = column;
    this.offset = offset;
  }
}
export const ParseError$ParseError = (kind, line, column, offset) =>
  new ParseError(kind, line, column, offset);
export const ParseError$isParseError = (value) => value instanceof ParseError;
export const ParseError$ParseError$kind = (value) => value.kind;
export const ParseError$ParseError$0 = (value) => value.kind;
export const ParseError$ParseError$line = (value) => value.line;
export const ParseError$ParseError$1 = (value) => value.line;
export const ParseError$ParseError$column = (value) => value.column;
export const ParseError$ParseError$2 = (value) => value.column;
export const ParseError$ParseError$offset = (value) => value.offset;
export const ParseError$ParseError$3 = (value) => value.offset;

/**
 * The document ended before parsing finished, e.g. an unclosed element
 * or a comment with no `-->`.
 */
export class UnexpectedEndOfInput extends $CustomType {}
export const ErrorKind$UnexpectedEndOfInput = () => new UnexpectedEndOfInput();
export const ErrorKind$isUnexpectedEndOfInput = (value) =>
  value instanceof UnexpectedEndOfInput;

/**
 * No root element was found.
 */
export class MissingRootElement extends $CustomType {}
export const ErrorKind$MissingRootElement = () => new MissingRootElement();
export const ErrorKind$isMissingRootElement = (value) =>
  value instanceof MissingRootElement;

/**
 * There was more than whitespace, comments, or processing instructions
 * after the root element was closed.
 */
export class ContentAfterRootElement extends $CustomType {}
export const ErrorKind$ContentAfterRootElement = () =>
  new ContentAfterRootElement();
export const ErrorKind$isContentAfterRootElement = (value) =>
  value instanceof ContentAfterRootElement;

/**
 * A name was expected (for an element, attribute, or closing tag) but
 * not found.
 */
export class InvalidName extends $CustomType {}
export const ErrorKind$InvalidName = () => new InvalidName();
export const ErrorKind$isInvalidName = (value) => value instanceof InvalidName;

/**
 * An attribute was not followed by `="value"` or `='value'`.
 */
export class MalformedAttribute extends $CustomType {
  constructor(attribute) {
    super();
    this.attribute = attribute;
  }
}
export const ErrorKind$MalformedAttribute = (attribute) =>
  new MalformedAttribute(attribute);
export const ErrorKind$isMalformedAttribute = (value) =>
  value instanceof MalformedAttribute;
export const ErrorKind$MalformedAttribute$attribute = (value) =>
  value.attribute;
export const ErrorKind$MalformedAttribute$0 = (value) => value.attribute;

/**
 * The same attribute appeared twice on one element.
 */
export class DuplicateAttribute extends $CustomType {
  constructor(attribute) {
    super();
    this.attribute = attribute;
  }
}
export const ErrorKind$DuplicateAttribute = (attribute) =>
  new DuplicateAttribute(attribute);
export const ErrorKind$isDuplicateAttribute = (value) =>
  value instanceof DuplicateAttribute;
export const ErrorKind$DuplicateAttribute$attribute = (value) =>
  value.attribute;
export const ErrorKind$DuplicateAttribute$0 = (value) => value.attribute;

/**
 * A closing tag did not match the currently open element.
 */
export class MismatchedClosingTag extends $CustomType {
  constructor(opening, closing) {
    super();
    this.opening = opening;
    this.closing = closing;
  }
}
export const ErrorKind$MismatchedClosingTag = (opening, closing) =>
  new MismatchedClosingTag(opening, closing);
export const ErrorKind$isMismatchedClosingTag = (value) =>
  value instanceof MismatchedClosingTag;
export const ErrorKind$MismatchedClosingTag$opening = (value) => value.opening;
export const ErrorKind$MismatchedClosingTag$0 = (value) => value.opening;
export const ErrorKind$MismatchedClosingTag$closing = (value) => value.closing;
export const ErrorKind$MismatchedClosingTag$1 = (value) => value.closing;

/**
 * An `&` was not followed by a terminated entity reference.
 */
export class MalformedEntity extends $CustomType {}
export const ErrorKind$MalformedEntity = () => new MalformedEntity();
export const ErrorKind$isMalformedEntity = (value) =>
  value instanceof MalformedEntity;

/**
 * An entity reference other than the five predefined XML entities or a
 * character reference, e.g. `&nbsp;`. XML (unlike HTML) only defines
 * `amp`, `lt`, `gt`, `quot`, and `apos`.
 */
export class UnknownEntity extends $CustomType {
  constructor(entity) {
    super();
    this.entity = entity;
  }
}
export const ErrorKind$UnknownEntity = (entity) => new UnknownEntity(entity);
export const ErrorKind$isUnknownEntity = (value) =>
  value instanceof UnknownEntity;
export const ErrorKind$UnknownEntity$entity = (value) => value.entity;
export const ErrorKind$UnknownEntity$0 = (value) => value.entity;

/**
 * A numeric character reference that is not a valid XML character, such
 * as `&#xD800;`.
 */
export class InvalidCharacterReference extends $CustomType {
  constructor(reference) {
    super();
    this.reference = reference;
  }
}
export const ErrorKind$InvalidCharacterReference = (reference) =>
  new InvalidCharacterReference(reference);
export const ErrorKind$isInvalidCharacterReference = (value) =>
  value instanceof InvalidCharacterReference;
export const ErrorKind$InvalidCharacterReference$reference = (value) =>
  value.reference;
export const ErrorKind$InvalidCharacterReference$0 = (value) => value.reference;

/**
 * A DOCTYPE or a declaration inside a DTD could not be parsed.
 */
export class MalformedDoctype extends $CustomType {}
export const ErrorKind$MalformedDoctype = () => new MalformedDoctype();
export const ErrorKind$isMalformedDoctype = (value) =>
  value instanceof MalformedDoctype;

/**
 * An entity expands to itself, directly or indirectly.
 */
export class RecursiveEntity extends $CustomType {
  constructor(entity) {
    super();
    this.entity = entity;
  }
}
export const ErrorKind$RecursiveEntity = (entity) =>
  new RecursiveEntity(entity);
export const ErrorKind$isRecursiveEntity = (value) =>
  value instanceof RecursiveEntity;
export const ErrorKind$RecursiveEntity$entity = (value) => value.entity;
export const ErrorKind$RecursiveEntity$0 = (value) => value.entity;

/**
 * A reference to an entity whose content is not available: an external
 * entity (which this parser never fetches) or an unparsed `NDATA`
 * entity.
 */
export class UnresolvableEntity extends $CustomType {
  constructor(entity) {
    super();
    this.entity = entity;
  }
}
export const ErrorKind$UnresolvableEntity = (entity) =>
  new UnresolvableEntity(entity);
export const ErrorKind$isUnresolvableEntity = (value) =>
  value instanceof UnresolvableEntity;
export const ErrorKind$UnresolvableEntity$entity = (value) => value.entity;
export const ErrorKind$UnresolvableEntity$0 = (value) => value.entity;

/**
 * An entity used in an attribute value expands to text containing `<`,
 * which XML forbids.
 */
export class MarkupInAttributeValue extends $CustomType {
  constructor(entity) {
    super();
    this.entity = entity;
  }
}
export const ErrorKind$MarkupInAttributeValue = (entity) =>
  new MarkupInAttributeValue(entity);
export const ErrorKind$isMarkupInAttributeValue = (value) =>
  value instanceof MarkupInAttributeValue;
export const ErrorKind$MarkupInAttributeValue$entity = (value) => value.entity;
export const ErrorKind$MarkupInAttributeValue$0 = (value) => value.entity;

/**
 * A character that XML does not allow in documents, such as most
 * control characters, or a `<` inside an attribute value.
 */
export class InvalidCharacter extends $CustomType {}
export const ErrorKind$InvalidCharacter = () => new InvalidCharacter();
export const ErrorKind$isInvalidCharacter = (value) =>
  value instanceof InvalidCharacter;

/**
 * A comment containing `--`, which XML forbids.
 */
export class MalformedComment extends $CustomType {}
export const ErrorKind$MalformedComment = () => new MalformedComment();
export const ErrorKind$isMalformedComment = (value) =>
  value instanceof MalformedComment;

/**
 * The literal sequence `]]>` in character data, which XML forbids.
 */
export class CdataEndInContent extends $CustomType {}
export const ErrorKind$CdataEndInContent = () => new CdataEndInContent();
export const ErrorKind$isCdataEndInContent = (value) =>
  value instanceof CdataEndInContent;

/**
 * An entity whose content is not balanced: it opens elements it does
 * not close, or closes elements it did not open.
 */
export class UnbalancedEntity extends $CustomType {
  constructor(entity) {
    super();
    this.entity = entity;
  }
}
export const ErrorKind$UnbalancedEntity = (entity) =>
  new UnbalancedEntity(entity);
export const ErrorKind$isUnbalancedEntity = (value) =>
  value instanceof UnbalancedEntity;
export const ErrorKind$UnbalancedEntity$entity = (value) => value.entity;
export const ErrorKind$UnbalancedEntity$0 = (value) => value.entity;

/**
 * Whitespace was required, for example between two attributes.
 */
export class MissingWhitespace extends $CustomType {}
export const ErrorKind$MissingWhitespace = () => new MissingWhitespace();
export const ErrorKind$isMissingWhitespace = (value) =>
  value instanceof MissingWhitespace;

/**
 * `parse_bytes` could not decode the input: an encoding this library
 * does not support (such as UTF-32 or EBCDIC), or bytes that are not
 * valid for the encoding they claim to be.
 */
export class UnsupportedEncoding extends $CustomType {
  constructor(encoding) {
    super();
    this.encoding = encoding;
  }
}
export const ErrorKind$UnsupportedEncoding = (encoding) =>
  new UnsupportedEncoding(encoding);
export const ErrorKind$isUnsupportedEncoding = (value) =>
  value instanceof UnsupportedEncoding;
export const ErrorKind$UnsupportedEncoding$encoding = (value) => value.encoding;
export const ErrorKind$UnsupportedEncoding$0 = (value) => value.encoding;

/**
 * The encoding named in the XML declaration contradicts the encoding
 * the document is actually written in, e.g. `encoding="UTF-16"` on a
 * UTF-8 document.
 */
export class DeclaredEncodingMismatch extends $CustomType {
  constructor(declared, detected) {
    super();
    this.declared = declared;
    this.detected = detected;
  }
}
export const ErrorKind$DeclaredEncodingMismatch = (declared, detected) =>
  new DeclaredEncodingMismatch(declared, detected);
export const ErrorKind$isDeclaredEncodingMismatch = (value) =>
  value instanceof DeclaredEncodingMismatch;
export const ErrorKind$DeclaredEncodingMismatch$declared = (value) =>
  value.declared;
export const ErrorKind$DeclaredEncodingMismatch$0 = (value) => value.declared;
export const ErrorKind$DeclaredEncodingMismatch$detected = (value) =>
  value.detected;
export const ErrorKind$DeclaredEncodingMismatch$1 = (value) => value.detected;

class DetectedUtf8 extends $CustomType {}

class DetectedUtf16 extends $CustomType {
  constructor(big_endian) {
    super();
    this.big_endian = big_endian;
  }
}

class InternalSubset extends $CustomType {}

class ExternalSubset extends $CustomType {}

class DtdInput extends $CustomType {
  constructor(current, entity, id, from_declaration_separator, parent) {
    super();
    this.current = current;
    this.entity = entity;
    this.id = id;
    this.from_declaration_separator = from_declaration_separator;
    this.parent = parent;
  }
}

class DtdState extends $CustomType {
  constructor(dtd, external, next_id, pe_used, internal_parameter_entities) {
    super();
    this.dtd = dtd;
    this.external = external;
    this.next_id = next_id;
    this.pe_used = pe_used;
    this.internal_parameter_entities = internal_parameter_entities;
  }
}

class UndecidedSeparator extends $CustomType {}

class SequenceSeparator extends $CustomType {}

class ChoiceSeparator extends $CustomType {}

const single_quote = 39;

const double_quote = 34;

/**
 * A DTD with no declarations at all.
 */
export function empty_dtd() {
  return new Dtd(
    $dict.new$(),
    $dict.new$(),
    $dict.new$(),
    $dict.new$(),
    toList([]),
    toList([]),
    toList([]),
  );
}

/**
 * Positions are only computed when parsing fails: the number of bytes
 * remaining at the failure point gives the consumed prefix, whose line,
 * column, and length in graphemes locate the error.
 * 
 * @ignore
 */
function make_error(input, kind, remaining) {
  let consumed_bytes = $int.clamp(
    $bit_array.byte_size(input) - remaining,
    0,
    $bit_array.byte_size(input),
  );
  let _block;
  let $ = $bit_array.slice(input, 0, consumed_bytes);
  if ($ instanceof Ok) {
    let bytes = $[0];
    let _pipe = $bit_array.to_string(bytes);
    _block = $result.unwrap(_pipe, "");
  } else {
    _block = "";
  }
  let consumed = _block;
  let lines = $string.split(consumed, "\n");
  let line = $list.length(lines);
  let _block$1;
  let $1 = $list.last(lines);
  if ($1 instanceof Ok) {
    let last = $1[0];
    _block$1 = $string.length(last) + 1;
  } else {
    _block$1 = 1;
  }
  let column = _block$1;
  return new ParseError(kind, line, column, $string.length(consumed));
}

/**
 * Take `count` bytes from the front of the input as a string. This cannot
 * fail: counts come from scanning the same bit array, and scanning stops
 * only at ASCII delimiters, so the bytes are always whole UTF-8 characters.
 * 
 * @ignore
 */
function take_string(input, count) {
  let $ = $bit_array.slice(input, 0, count);
  let bytes;
  if ($ instanceof Ok) {
    bytes = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glexml",
      3478,
      "take_string",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 117067,
        end: 117122,
        pattern_start: 117078,
        pattern_end: 117087
      }
    )
  }
  let $1 = $bit_array.to_string(bytes);
  let string;
  if ($1 instanceof Ok) {
    string = $1[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "glexml",
      3479,
      "take_string",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 117125,
        end: 117175,
        pattern_start: 117136,
        pattern_end: 117146
      }
    )
  }
  return string;
}

/**
 * Whether a byte may never appear in an XML document: the control
 * characters other than tab and line feed (carriage returns are gone by
 * this point, normalised to line feeds).
 * 
 * @ignore
 */
function is_forbidden_byte(byte) {
  return (((byte < 0x20) && (byte !== 0x9)) && (byte !== 0xA)) && (byte !== 0xD);
}

function scan_processing_instruction_end(loop$input, loop$count) {
  while (true) {
    let input = loop$input;
    let count = loop$count;
    if (input.bitSize >= 16) {
      if (input.byteAt(0) === 63 && input.byteAt(1) === 62) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 16);
          return new Ok([count, rest]);
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (
        input.byteAt(0) === 239 &&
        input.byteAt(1) === 191 &&
        input.bitSize >= 24
      ) {
        if (input.byteAt(2) === 190) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.byteAt(2) === 191) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.bitSize % 8 === 0) {
          let byte = input.byteAt(0);
          let rest = bitArraySlice(input, 8);
          let $ = is_forbidden_byte(byte);
          if ($) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            loop$input = rest;
            loop$count = count + 1;
          }
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.bitSize % 8 === 0) {
        let byte = input.byteAt(0);
        let rest = bitArraySlice(input, 8);
        let $ = is_forbidden_byte(byte);
        if ($) {
          return new Error(
            [new InvalidCharacter(), $bit_array.byte_size(input)],
          );
        } else {
          loop$input = rest;
          loop$count = count + 1;
        }
      } else {
        return new Error([new UnexpectedEndOfInput(), 0]);
      }
    } else if (input.bitSize >= 8 && input.bitSize % 8 === 0) {
      let byte = input.byteAt(0);
      let rest = bitArraySlice(input, 8);
      let $ = is_forbidden_byte(byte);
      if ($) {
        return new Error([new InvalidCharacter(), $bit_array.byte_size(input)]);
      } else {
        loop$input = rest;
        loop$count = count + 1;
      }
    } else {
      return new Error([new UnexpectedEndOfInput(), 0]);
    }
  }
}

function require(condition, failure, continue$) {
  if (condition) {
    return continue$();
  } else {
    return new Error(failure);
  }
}

/**
 * The NameStartChar production from XML 1.0 fifth edition.
 * 
 * @ignore
 */
function is_name_start_character(code) {
  return (((((((((((((((code === 0x3A) || (code === 0x5F)) || ((code >= 0x41) && (code <= 0x5A))) || ((code >= 0x61) && (code <= 0x7A))) || ((code >= 0xC0) && (code <= 0xD6))) || ((code >= 0xD8) && (code <= 0xF6))) || ((code >= 0xF8) && (code <= 0x2FF))) || ((code >= 0x370) && (code <= 0x37D))) || ((code >= 0x37F) && (code <= 0x1FFF))) || ((code >= 0x200C) && (code <= 0x200D))) || ((code >= 0x2070) && (code <= 0x218F))) || ((code >= 0x2C00) && (code <= 0x2FEF))) || ((code >= 0x3001) && (code <= 0xD7FF))) || ((code >= 0xF900) && (code <= 0xFDCF))) || ((code >= 0xFDF0) && (code <= 0xFFFD))) || ((code >= 0x10000) && (code <= 0xEFFFF));
}

/**
 * The NameChar production from XML 1.0 fifth edition.
 * 
 * @ignore
 */
function is_name_character(code) {
  return (((((is_name_start_character(code) || (code === 0x2D)) || (code === 0x2E)) || (code === 0xB7)) || ((code >= 0x30) && (code <= 0x39))) || ((code >= 0x300) && (code <= 0x36F))) || ((code >= 0x203F) && (code <= 0x2040));
}

function is_valid_name(name) {
  let $ = $string.to_utf_codepoints(name);
  if ($ instanceof $Empty) {
    return false;
  } else {
    let first = $.head;
    let rest = $.tail;
    return is_name_start_character($string.utf_codepoint_to_int(first)) && $list.all(
      rest,
      (codepoint) => {
        return is_name_character($string.utf_codepoint_to_int(codepoint));
      },
    );
  }
}

/**
 * Whether a byte can appear in an element or attribute name. This is
 * deliberately lenient: anything that cannot terminate a name (or open
 * other markup) is accepted, which also admits all multi-byte UTF-8
 * characters, as the XML specification largely does.
 * 
 * @ignore
 */
function is_name_byte(byte) {
  if (byte === 9) {
    return false;
  } else if (byte === 10) {
    return false;
  } else if (byte === 32) {
    return false;
  } else if (byte === 33) {
    return false;
  } else if (byte === 34) {
    return false;
  } else if (byte === 37) {
    return false;
  } else if (byte === 38) {
    return false;
  } else if (byte === 39) {
    return false;
  } else if (byte === 40) {
    return false;
  } else if (byte === 41) {
    return false;
  } else if (byte === 42) {
    return false;
  } else if (byte === 43) {
    return false;
  } else if (byte === 44) {
    return false;
  } else if (byte === 47) {
    return false;
  } else if (byte === 59) {
    return false;
  } else if (byte === 60) {
    return false;
  } else if (byte === 61) {
    return false;
  } else if (byte === 62) {
    return false;
  } else if (byte === 63) {
    return false;
  } else if (byte === 91) {
    return false;
  } else if (byte === 93) {
    return false;
  } else if (byte === 124) {
    return false;
  } else {
    return true;
  }
}

function scan_name(loop$input, loop$count) {
  while (true) {
    let input = loop$input;
    let count = loop$count;
    if (input.bitSize >= 8 && input.bitSize % 8 === 0) {
      let byte = input.byteAt(0);
      let rest = bitArraySlice(input, 8);
      let $ = is_name_byte(byte);
      if ($) {
        loop$input = rest;
        loop$count = count + 1;
      } else {
        return [count, input];
      }
    } else {
      return [count, input];
    }
  }
}

function parse_name(input) {
  let $ = scan_name(input, 0);
  let $1 = $[0];
  if ($1 === 0) {
    let $2 = $[1];
    if ($2.bitSize === 0) {
      return new Error([new UnexpectedEndOfInput(), 0]);
    } else {
      let rest = $2;
      return new Error([new InvalidName(), $bit_array.byte_size(rest)]);
    }
  } else {
    let count = $1;
    let rest = $[1];
    let name = take_string(input, count);
    let $2 = is_valid_name(name);
    if ($2) {
      return new Ok([name, rest]);
    } else {
      return new Error([new InvalidName(), $bit_array.byte_size(input)]);
    }
  }
}

/**
 * Parse a processing instruction. The input begins immediately after `<?`.
 * 
 * @ignore
 */
function parse_processing_instruction(input) {
  return $result.try$(
    parse_name(input),
    (_use0) => {
      let target = _use0[0];
      let rest = _use0[1];
      return require(
        $string.lowercase(target) !== "xml",
        [new InvalidName(), $bit_array.byte_size(input)],
        () => {
          if (rest.bitSize === 0) {
            return new Error([new UnexpectedEndOfInput(), 0]);
          } else if (rest.bitSize >= 16) {
            if (rest.byteAt(0) === 63 && rest.byteAt(1) === 62) {
              if (rest.bitSize % 8 === 0) {
                let rest$1 = bitArraySlice(rest, 16);
                return new Ok(
                  [new ProcessingInstructionNode(target, ""), rest$1],
                );
              } else {
                return new Error(
                  [new InvalidName(), $bit_array.byte_size(rest)],
                );
              }
            } else if (rest.byteAt(0) === 32) {
              if (rest.bitSize % 8 === 0) {
                let rest$1 = bitArraySlice(rest, 8);
                let $ = scan_processing_instruction_end(rest$1, 0);
                if ($ instanceof Ok) {
                  let count = $[0][0];
                  let after = $[0][1];
                  return new Ok(
                    [
                      new ProcessingInstructionNode(
                        target,
                        $string.trim_start(take_string(rest$1, count)),
                      ),
                      after,
                    ],
                  );
                } else {
                  return $;
                }
              } else {
                return new Error(
                  [new InvalidName(), $bit_array.byte_size(rest)],
                );
              }
            } else if (rest.byteAt(0) === 9) {
              if (rest.bitSize % 8 === 0) {
                let rest$1 = bitArraySlice(rest, 8);
                let $ = scan_processing_instruction_end(rest$1, 0);
                if ($ instanceof Ok) {
                  let count = $[0][0];
                  let after = $[0][1];
                  return new Ok(
                    [
                      new ProcessingInstructionNode(
                        target,
                        $string.trim_start(take_string(rest$1, count)),
                      ),
                      after,
                    ],
                  );
                } else {
                  return $;
                }
              } else {
                return new Error(
                  [new InvalidName(), $bit_array.byte_size(rest)],
                );
              }
            } else if (rest.byteAt(0) === 10 && rest.bitSize % 8 === 0) {
              let rest$1 = bitArraySlice(rest, 8);
              let $ = scan_processing_instruction_end(rest$1, 0);
              if ($ instanceof Ok) {
                let count = $[0][0];
                let after = $[0][1];
                return new Ok(
                  [
                    new ProcessingInstructionNode(
                      target,
                      $string.trim_start(take_string(rest$1, count)),
                    ),
                    after,
                  ],
                );
              } else {
                return $;
              }
            } else {
              return new Error([new InvalidName(), $bit_array.byte_size(rest)]);
            }
          } else if (rest.bitSize >= 8) {
            if (rest.byteAt(0) === 32) {
              if (rest.bitSize % 8 === 0) {
                let rest$1 = bitArraySlice(rest, 8);
                let $ = scan_processing_instruction_end(rest$1, 0);
                if ($ instanceof Ok) {
                  let count = $[0][0];
                  let after = $[0][1];
                  return new Ok(
                    [
                      new ProcessingInstructionNode(
                        target,
                        $string.trim_start(take_string(rest$1, count)),
                      ),
                      after,
                    ],
                  );
                } else {
                  return $;
                }
              } else {
                return new Error(
                  [new InvalidName(), $bit_array.byte_size(rest)],
                );
              }
            } else if (rest.byteAt(0) === 9) {
              if (rest.bitSize % 8 === 0) {
                let rest$1 = bitArraySlice(rest, 8);
                let $ = scan_processing_instruction_end(rest$1, 0);
                if ($ instanceof Ok) {
                  let count = $[0][0];
                  let after = $[0][1];
                  return new Ok(
                    [
                      new ProcessingInstructionNode(
                        target,
                        $string.trim_start(take_string(rest$1, count)),
                      ),
                      after,
                    ],
                  );
                } else {
                  return $;
                }
              } else {
                return new Error(
                  [new InvalidName(), $bit_array.byte_size(rest)],
                );
              }
            } else if (rest.byteAt(0) === 10 && rest.bitSize % 8 === 0) {
              let rest$1 = bitArraySlice(rest, 8);
              let $ = scan_processing_instruction_end(rest$1, 0);
              if ($ instanceof Ok) {
                let count = $[0][0];
                let after = $[0][1];
                return new Ok(
                  [
                    new ProcessingInstructionNode(
                      target,
                      $string.trim_start(take_string(rest$1, count)),
                    ),
                    after,
                  ],
                );
              } else {
                return $;
              }
            } else {
              return new Error([new InvalidName(), $bit_array.byte_size(rest)]);
            }
          } else {
            return new Error([new InvalidName(), $bit_array.byte_size(rest)]);
          }
        },
      );
    },
  );
}

function scan_comment_end(loop$input, loop$count) {
  while (true) {
    let input = loop$input;
    let count = loop$count;
    if (input.bitSize >= 24) {
      if (
        input.byteAt(0) === 45 &&
          input.byteAt(1) === 45 &&
          input.byteAt(2) === 62
      ) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 24);
          return new Ok([count, rest]);
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.byteAt(0) === 45 && input.byteAt(1) === 45) {
        if (input.bitSize % 8 === 0) {
          return new Error(
            [new MalformedComment(), $bit_array.byte_size(input)],
          );
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.byteAt(0) === 239 && input.byteAt(1) === 191) {
        if (input.byteAt(2) === 190) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.byteAt(2) === 191) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.bitSize % 8 === 0) {
          let byte = input.byteAt(0);
          let rest = bitArraySlice(input, 8);
          let $ = is_forbidden_byte(byte);
          if ($) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            loop$input = rest;
            loop$count = count + 1;
          }
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.bitSize % 8 === 0) {
        let byte = input.byteAt(0);
        let rest = bitArraySlice(input, 8);
        let $ = is_forbidden_byte(byte);
        if ($) {
          return new Error(
            [new InvalidCharacter(), $bit_array.byte_size(input)],
          );
        } else {
          loop$input = rest;
          loop$count = count + 1;
        }
      } else {
        return new Error([new UnexpectedEndOfInput(), 0]);
      }
    } else if (input.bitSize >= 16) {
      if (input.byteAt(0) === 45 && input.byteAt(1) === 45) {
        if (input.bitSize % 8 === 0) {
          return new Error(
            [new MalformedComment(), $bit_array.byte_size(input)],
          );
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.bitSize % 8 === 0) {
        let byte = input.byteAt(0);
        let rest = bitArraySlice(input, 8);
        let $ = is_forbidden_byte(byte);
        if ($) {
          return new Error(
            [new InvalidCharacter(), $bit_array.byte_size(input)],
          );
        } else {
          loop$input = rest;
          loop$count = count + 1;
        }
      } else {
        return new Error([new UnexpectedEndOfInput(), 0]);
      }
    } else if (input.bitSize >= 8 && input.bitSize % 8 === 0) {
      let byte = input.byteAt(0);
      let rest = bitArraySlice(input, 8);
      let $ = is_forbidden_byte(byte);
      if ($) {
        return new Error([new InvalidCharacter(), $bit_array.byte_size(input)]);
      } else {
        loop$input = rest;
        loop$count = count + 1;
      }
    } else {
      return new Error([new UnexpectedEndOfInput(), 0]);
    }
  }
}

/**
 * Parse a comment. The input begins immediately after `<!--`.
 * 
 * @ignore
 */
function parse_comment(input) {
  let $ = scan_comment_end(input, 0);
  if ($ instanceof Ok) {
    let count = $[0][0];
    let rest = $[0][1];
    return new Ok([take_string(input, count), rest]);
  } else {
    return $;
  }
}

function skip_whitespace(loop$input) {
  while (true) {
    let input = loop$input;
    if (input.bitSize >= 8) {
      if (input.byteAt(0) === 32) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          loop$input = rest;
        } else {
          return input;
        }
      } else if (input.byteAt(0) === 9) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          loop$input = rest;
        } else {
          return input;
        }
      } else if (input.byteAt(0) === 10 && input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        loop$input = rest;
      } else {
        return input;
      }
    } else {
      return input;
    }
  }
}

/**
 * Read whitespace, comments, and processing instructions after the root
 * element, keeping the comments and processing instructions in document
 * order.
 * 
 * @ignore
 */
function parse_epilogue(loop$input, loop$nodes) {
  while (true) {
    let input = loop$input;
    let nodes = loop$nodes;
    let input$1 = skip_whitespace(input);
    if (input$1.bitSize >= 32) {
      if (
        input$1.byteAt(0) === 60 &&
          input$1.byteAt(1) === 33 &&
          input$1.byteAt(2) === 45 &&
          input$1.byteAt(3) === 45
      ) {
        if (input$1.bitSize % 8 === 0) {
          let rest = bitArraySlice(input$1, 32);
          let $ = parse_comment(rest);
          if ($ instanceof Ok) {
            let content = $[0][0];
            let rest$1 = $[0][1];
            loop$input = rest$1;
            loop$nodes = listPrepend(new CommentNode(content), nodes);
          } else {
            return $;
          }
        } else {
          return new Ok([$list.reverse(nodes), input$1]);
        }
      } else if (
        input$1.byteAt(0) === 60 && input$1.byteAt(1) === 63 &&
        input$1.bitSize % 8 === 0
      ) {
        let rest = bitArraySlice(input$1, 16);
        let $ = parse_processing_instruction(rest);
        if ($ instanceof Ok) {
          let instruction = $[0][0];
          let rest$1 = $[0][1];
          loop$input = rest$1;
          loop$nodes = listPrepend(instruction, nodes);
        } else {
          return $;
        }
      } else {
        return new Ok([$list.reverse(nodes), input$1]);
      }
    } else if (
      input$1.bitSize >= 16 &&
      input$1.byteAt(0) === 60 && input$1.byteAt(1) === 63 &&
      input$1.bitSize % 8 === 0
    ) {
      let rest = bitArraySlice(input$1, 16);
      let $ = parse_processing_instruction(rest);
      if ($ instanceof Ok) {
        let instruction = $[0][0];
        let rest$1 = $[0][1];
        loop$input = rest$1;
        loop$nodes = listPrepend(instruction, nodes);
      } else {
        return $;
      }
    } else {
      return new Ok([$list.reverse(nodes), input$1]);
    }
  }
}

function scan_cdata_end(loop$input, loop$count) {
  while (true) {
    let input = loop$input;
    let count = loop$count;
    if (input.bitSize >= 24) {
      if (
        input.byteAt(0) === 93 &&
          input.byteAt(1) === 93 &&
          input.byteAt(2) === 62
      ) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 24);
          return new Ok([count, rest]);
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.byteAt(0) === 239 && input.byteAt(1) === 191) {
        if (input.byteAt(2) === 190) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.byteAt(2) === 191) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.bitSize % 8 === 0) {
          let byte = input.byteAt(0);
          let rest = bitArraySlice(input, 8);
          let $ = is_forbidden_byte(byte);
          if ($) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            loop$input = rest;
            loop$count = count + 1;
          }
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.bitSize % 8 === 0) {
        let byte = input.byteAt(0);
        let rest = bitArraySlice(input, 8);
        let $ = is_forbidden_byte(byte);
        if ($) {
          return new Error(
            [new InvalidCharacter(), $bit_array.byte_size(input)],
          );
        } else {
          loop$input = rest;
          loop$count = count + 1;
        }
      } else {
        return new Error([new UnexpectedEndOfInput(), 0]);
      }
    } else if (input.bitSize >= 8 && input.bitSize % 8 === 0) {
      let byte = input.byteAt(0);
      let rest = bitArraySlice(input, 8);
      let $ = is_forbidden_byte(byte);
      if ($) {
        return new Error([new InvalidCharacter(), $bit_array.byte_size(input)]);
      } else {
        loop$input = rest;
        loop$count = count + 1;
      }
    } else {
      return new Error([new UnexpectedEndOfInput(), 0]);
    }
  }
}

function take_adjacent_text(loop$nodes, loop$acc, loop$literal) {
  while (true) {
    let nodes = loop$nodes;
    let acc = loop$acc;
    let literal = loop$literal;
    if (nodes instanceof $Empty) {
      return [acc, literal, nodes];
    } else {
      let $ = nodes.head;
      if ($ instanceof TextNode) {
        let rest = nodes.tail;
        let text = $.text;
        let text_literal = $.literal;
        loop$nodes = rest;
        loop$acc = listPrepend(text, acc);
        loop$literal = literal && text_literal;
      } else {
        return [acc, literal, nodes];
      }
    }
  }
}

function do_merge_adjacent_text(loop$nodes, loop$acc) {
  while (true) {
    let nodes = loop$nodes;
    let acc = loop$acc;
    if (nodes instanceof $Empty) {
      return $list.reverse(acc);
    } else {
      let $ = nodes.head;
      if ($ instanceof TextNode) {
        let rest = nodes.tail;
        let first = $.text;
        let first_literal = $.literal;
        let $1 = take_adjacent_text(rest, toList([first]), first_literal);
        let pieces = $1[0];
        let literal = $1[1];
        let rest$1 = $1[2];
        let text = $string.concat($list.reverse(pieces));
        loop$nodes = rest$1;
        loop$acc = listPrepend(new TextNode(text, literal), acc);
      } else {
        let node = $;
        let rest = nodes.tail;
        loop$nodes = rest;
        loop$acc = listPrepend(node, acc);
      }
    }
  }
}

/**
 * Entity expansion can produce several text nodes in a row; combine them
 * so consumers see one text node per run of character data, and drop any
 * that are empty.
 * 
 * @ignore
 */
function merge_adjacent_text(nodes) {
  return do_merge_adjacent_text(nodes, toList([]));
}

/**
 * Parse a closing tag. The input begins immediately after `</`.
 * 
 * @ignore
 */
function parse_closing_tag(input, parent, acc) {
  return $result.try$(
    parse_name(input),
    (_use0) => {
      let closing = _use0[0];
      let rest = _use0[1];
      let rest$1 = skip_whitespace(rest);
      if (rest$1.bitSize === 0) {
        return new Error([new UnexpectedEndOfInput(), 0]);
      } else if (
        rest$1.bitSize >= 8 &&
        rest$1.byteAt(0) === 62 &&
        rest$1.bitSize % 8 === 0
      ) {
        let rest$2 = bitArraySlice(rest$1, 8);
        let $ = closing === parent;
        if ($) {
          return new Ok([merge_adjacent_text($list.reverse(acc)), rest$2]);
        } else {
          return new Error(
            [
              new MismatchedClosingTag(parent, closing),
              $bit_array.byte_size(input) + 2,
            ],
          );
        }
      } else {
        return new Error([new InvalidName(), $bit_array.byte_size(rest$1)]);
      }
    },
  );
}

/**
 * Count the bytes of character data before the next `<` or `&`, stopping
 * without consuming it. The remaining input is returned alongside the
 * count. Characters XML forbids, and the `]]>` sequence, are errors.
 * 
 * @ignore
 */
function scan_text(loop$input, loop$count) {
  while (true) {
    let input = loop$input;
    let count = loop$count;
    if (input.bitSize >= 8) {
      if (input.byteAt(0) === 60) {
        if (input.bitSize % 8 === 0) {
          return new Ok([count, input]);
        } else {
          return new Ok([count, input]);
        }
      } else if (input.byteAt(0) === 38) {
        if (input.bitSize % 8 === 0) {
          return new Ok([count, input]);
        } else {
          return new Ok([count, input]);
        }
      } else if (input.bitSize >= 24) {
        if (
          input.byteAt(0) === 93 &&
            input.byteAt(1) === 93 &&
            input.byteAt(2) === 62
        ) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new CdataEndInContent(), $bit_array.byte_size(input)],
            );
          } else {
            return new Ok([count, input]);
          }
        } else if (input.byteAt(0) === 239 && input.byteAt(1) === 191) {
          if (input.byteAt(2) === 190) {
            if (input.bitSize % 8 === 0) {
              return new Error(
                [new InvalidCharacter(), $bit_array.byte_size(input)],
              );
            } else {
              return new Ok([count, input]);
            }
          } else if (input.byteAt(2) === 191) {
            if (input.bitSize % 8 === 0) {
              return new Error(
                [new InvalidCharacter(), $bit_array.byte_size(input)],
              );
            } else {
              return new Ok([count, input]);
            }
          } else if (input.bitSize % 8 === 0) {
            let byte = input.byteAt(0);
            let rest = bitArraySlice(input, 8);
            let $ = is_forbidden_byte(byte);
            if ($) {
              return new Error(
                [new InvalidCharacter(), $bit_array.byte_size(input)],
              );
            } else {
              loop$input = rest;
              loop$count = count + 1;
            }
          } else {
            return new Ok([count, input]);
          }
        } else if (input.bitSize % 8 === 0) {
          let byte = input.byteAt(0);
          let rest = bitArraySlice(input, 8);
          let $ = is_forbidden_byte(byte);
          if ($) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            loop$input = rest;
            loop$count = count + 1;
          }
        } else {
          return new Ok([count, input]);
        }
      } else if (input.bitSize % 8 === 0) {
        let byte = input.byteAt(0);
        let rest = bitArraySlice(input, 8);
        let $ = is_forbidden_byte(byte);
        if ($) {
          return new Error(
            [new InvalidCharacter(), $bit_array.byte_size(input)],
          );
        } else {
          loop$input = rest;
          loop$count = count + 1;
        }
      } else {
        return new Ok([count, input]);
      }
    } else {
      return new Ok([count, input]);
    }
  }
}

/**
 * The number of bytes a `&name;` reference and everything after it spans,
 * used to report error positions at the `&`.
 * 
 * @ignore
 */
function reference_size(reference, after) {
  return ($string.byte_size(reference) + 2) + $bit_array.byte_size(after);
}

/**
 * The Char production from the XML specification.
 * 
 * @ignore
 */
function is_valid_xml_character(code) {
  return (((((code === 0x9) || (code === 0xA)) || (code === 0xD)) || ((code >= 0x20) && (code <= 0xD7FF))) || ((code >= 0xE000) && (code <= 0xFFFD))) || ((code >= 0x10000) && (code <= 0x10FFFF));
}

function resolve_character_reference(digits, base, reference) {
  let $ = $int.base_parse(digits, base);
  if ($ instanceof Ok) {
    let code = $[0];
    let $1 = is_valid_xml_character(code);
    if ($1) {
      let $2 = $string.utf_codepoint(code);
      if ($2 instanceof Ok) {
        let codepoint = $2[0];
        return new Ok($string.from_utf_codepoints(toList([codepoint])));
      } else {
        return new Error(new InvalidCharacterReference(reference));
      }
    } else {
      return new Error(new InvalidCharacterReference(reference));
    }
  } else {
    return new Error(new InvalidCharacterReference(reference));
  }
}

function resolve_entity(reference) {
  if (reference === "amp") {
    return new Ok("&");
  } else if (reference === "lt") {
    return new Ok("<");
  } else if (reference === "gt") {
    return new Ok(">");
  } else if (reference === "quot") {
    return new Ok("\"");
  } else if (reference === "apos") {
    return new Ok("'");
  } else if (reference.startsWith("#x")) {
    let digits = reference.slice(2);
    return resolve_character_reference(digits, 16, reference);
  } else if (reference.charCodeAt(0) === 35) {
    let digits = reference.slice(1);
    return resolve_character_reference(digits, 10, reference);
  } else {
    return new Error(new UnknownEntity(reference));
  }
}

function do_decode_character_references(loop$text, loop$acc, loop$literal) {
  while (true) {
    let text = loop$text;
    let acc = loop$acc;
    let literal = loop$literal;
    let $ = $string.split_once(text, "&");
    if ($ instanceof Ok) {
      let before = $[0][0];
      let after = $[0][1];
      let $1 = $string.split_once(after, ";");
      if ($1 instanceof Ok) {
        let reference = $1[0][0];
        let rest = $1[0][1];
        let $2 = resolve_entity(reference);
        if ($2 instanceof Ok) {
          let replacement = $2[0];
          let _block;
          if (reference.charCodeAt(0) === 35) {
            _block = false;
          } else {
            _block = literal;
          }
          let literal$1 = _block;
          loop$text = rest;
          loop$acc = listPrepend(replacement, listPrepend(before, acc));
          loop$literal = literal$1;
        } else {
          return $2;
        }
      } else {
        return new Error(new MalformedEntity());
      }
    } else {
      return new Ok(
        [$string.concat($list.reverse(listPrepend(text, acc))), literal],
      );
    }
  }
}

/**
 * Decode character references and the five predefined entities in text
 * where general entities have already been expanded.
 * Also reports whether the text stayed "literal": character references
 * recognised here poison the text for use as element-content separator
 * whitespace, while entity references (the predefined five) do not.
 * 
 * @ignore
 */
function decode_character_references(text) {
  return do_decode_character_references(text, toList([]), true);
}

/**
 * Parse a `name;` after a `&` or `%`, consuming the semicolon.
 * 
 * @ignore
 */
function parse_reference_name(input) {
  let $ = scan_name(input, 0);
  let $1 = $[0];
  if ($1 === 0) {
    return new Error([new MalformedEntity(), $bit_array.byte_size(input) + 1]);
  } else {
    let count = $1;
    let rest = $[1];
    if (rest.bitSize >= 8 && rest.byteAt(0) === 59 && rest.bitSize % 8 === 0) {
      let rest$1 = bitArraySlice(rest, 8);
      return new Ok([take_string(input, count), rest$1]);
    } else {
      return new Error([new MalformedEntity(), $bit_array.byte_size(input) + 1]);
    }
  }
}

function expand_references_in_bytes(loop$input, loop$dtd, loop$active, loop$acc) {
  while (true) {
    let input = loop$input;
    let dtd = loop$dtd;
    let active = loop$active;
    let acc = loop$acc;
    if (input.bitSize === 0) {
      return new Ok($string.concat($list.reverse(acc)));
    } else if (input.bitSize >= 72) {
      if (
        input.byteAt(0) === 60 &&
          input.byteAt(1) === 33 &&
          input.byteAt(2) === 91 &&
          input.byteAt(3) === 67 &&
          input.byteAt(4) === 68 &&
          input.byteAt(5) === 65 &&
          input.byteAt(6) === 84 &&
          input.byteAt(7) === 65 &&
          input.byteAt(8) === 91
      ) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 72);
          let $ = scan_cdata_end(rest, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let after = $[0][1];
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(
              ("<![CDATA[" + take_string(rest, count)) + "]]>",
              acc,
            );
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (
        input.byteAt(0) === 60 &&
          input.byteAt(1) === 33 &&
          input.byteAt(2) === 45 &&
          input.byteAt(3) === 45
      ) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 32);
          let $ = scan_comment_end(rest, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let after = $[0][1];
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(
              ("<!--" + take_string(rest, count)) + "-->",
              acc,
            );
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (input.byteAt(0) === 60 && input.byteAt(1) === 63) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 16);
          let $ = scan_processing_instruction_end(rest, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let after = $[0][1];
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(
              ("<?" + take_string(rest, count)) + "?>",
              acc,
            );
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (input.byteAt(0) === 60) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          loop$input = rest;
          loop$dtd = dtd;
          loop$active = active;
          loop$acc = listPrepend("<", acc);
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (input.byteAt(0) === 38 && input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        let $ = parse_reference_name(rest);
        if ($ instanceof Ok) {
          let reference = $[0][0];
          let after = $[0][1];
          if (reference.charCodeAt(0) === 35) {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "amp") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "lt") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "gt") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "quot") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "apos") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else {
            let $1 = expand_general_entity(reference, dtd, active);
            if ($1 instanceof Ok) {
              let expansion = $1[0];
              loop$input = after;
              loop$dtd = dtd;
              loop$active = active;
              loop$acc = listPrepend(expansion, acc);
            } else {
              return $1;
            }
          }
        } else {
          let kind = $[0][0];
          return new Error(kind);
        }
      } else {
        let $ = scan_text(input, 0);
        if ($ instanceof Ok) {
          let count = $[0][0];
          let rest = $[0][1];
          loop$input = rest;
          loop$dtd = dtd;
          loop$active = active;
          loop$acc = listPrepend(take_string(input, count), acc);
        } else {
          let kind = $[0][0];
          return new Error(kind);
        }
      }
    } else if (input.bitSize >= 32) {
      if (
        input.byteAt(0) === 60 &&
          input.byteAt(1) === 33 &&
          input.byteAt(2) === 45 &&
          input.byteAt(3) === 45
      ) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 32);
          let $ = scan_comment_end(rest, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let after = $[0][1];
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(
              ("<!--" + take_string(rest, count)) + "-->",
              acc,
            );
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (input.byteAt(0) === 60 && input.byteAt(1) === 63) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 16);
          let $ = scan_processing_instruction_end(rest, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let after = $[0][1];
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(
              ("<?" + take_string(rest, count)) + "?>",
              acc,
            );
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (input.byteAt(0) === 60) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          loop$input = rest;
          loop$dtd = dtd;
          loop$active = active;
          loop$acc = listPrepend("<", acc);
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (input.byteAt(0) === 38 && input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        let $ = parse_reference_name(rest);
        if ($ instanceof Ok) {
          let reference = $[0][0];
          let after = $[0][1];
          if (reference.charCodeAt(0) === 35) {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "amp") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "lt") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "gt") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "quot") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "apos") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else {
            let $1 = expand_general_entity(reference, dtd, active);
            if ($1 instanceof Ok) {
              let expansion = $1[0];
              loop$input = after;
              loop$dtd = dtd;
              loop$active = active;
              loop$acc = listPrepend(expansion, acc);
            } else {
              return $1;
            }
          }
        } else {
          let kind = $[0][0];
          return new Error(kind);
        }
      } else {
        let $ = scan_text(input, 0);
        if ($ instanceof Ok) {
          let count = $[0][0];
          let rest = $[0][1];
          loop$input = rest;
          loop$dtd = dtd;
          loop$active = active;
          loop$acc = listPrepend(take_string(input, count), acc);
        } else {
          let kind = $[0][0];
          return new Error(kind);
        }
      }
    } else if (input.bitSize >= 16) {
      if (input.byteAt(0) === 60 && input.byteAt(1) === 63) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 16);
          let $ = scan_processing_instruction_end(rest, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let after = $[0][1];
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(
              ("<?" + take_string(rest, count)) + "?>",
              acc,
            );
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (input.byteAt(0) === 60) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          loop$input = rest;
          loop$dtd = dtd;
          loop$active = active;
          loop$acc = listPrepend("<", acc);
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (input.byteAt(0) === 38 && input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        let $ = parse_reference_name(rest);
        if ($ instanceof Ok) {
          let reference = $[0][0];
          let after = $[0][1];
          if (reference.charCodeAt(0) === 35) {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "amp") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "lt") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "gt") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "quot") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "apos") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else {
            let $1 = expand_general_entity(reference, dtd, active);
            if ($1 instanceof Ok) {
              let expansion = $1[0];
              loop$input = after;
              loop$dtd = dtd;
              loop$active = active;
              loop$acc = listPrepend(expansion, acc);
            } else {
              return $1;
            }
          }
        } else {
          let kind = $[0][0];
          return new Error(kind);
        }
      } else {
        let $ = scan_text(input, 0);
        if ($ instanceof Ok) {
          let count = $[0][0];
          let rest = $[0][1];
          loop$input = rest;
          loop$dtd = dtd;
          loop$active = active;
          loop$acc = listPrepend(take_string(input, count), acc);
        } else {
          let kind = $[0][0];
          return new Error(kind);
        }
      }
    } else if (input.bitSize >= 8) {
      if (input.byteAt(0) === 60) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          loop$input = rest;
          loop$dtd = dtd;
          loop$active = active;
          loop$acc = listPrepend("<", acc);
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(take_string(input, count), acc);
          } else {
            let kind = $[0][0];
            return new Error(kind);
          }
        }
      } else if (input.byteAt(0) === 38 && input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        let $ = parse_reference_name(rest);
        if ($ instanceof Ok) {
          let reference = $[0][0];
          let after = $[0][1];
          if (reference.charCodeAt(0) === 35) {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "amp") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "lt") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "gt") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "quot") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else if (reference === "apos") {
            loop$input = after;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(("&" + reference) + ";", acc);
          } else {
            let $1 = expand_general_entity(reference, dtd, active);
            if ($1 instanceof Ok) {
              let expansion = $1[0];
              loop$input = after;
              loop$dtd = dtd;
              loop$active = active;
              loop$acc = listPrepend(expansion, acc);
            } else {
              return $1;
            }
          }
        } else {
          let kind = $[0][0];
          return new Error(kind);
        }
      } else {
        let $ = scan_text(input, 0);
        if ($ instanceof Ok) {
          let count = $[0][0];
          let rest = $[0][1];
          loop$input = rest;
          loop$dtd = dtd;
          loop$active = active;
          loop$acc = listPrepend(take_string(input, count), acc);
        } else {
          let kind = $[0][0];
          return new Error(kind);
        }
      }
    } else {
      let $ = scan_text(input, 0);
      if ($ instanceof Ok) {
        let count = $[0][0];
        let rest = $[0][1];
        loop$input = rest;
        loop$dtd = dtd;
        loop$active = active;
        loop$acc = listPrepend(take_string(input, count), acc);
      } else {
        let kind = $[0][0];
        return new Error(kind);
      }
    }
  }
}

/**
 * Fully expand a general entity declared in the DTD to its replacement
 * text: nested general entity references are expanded recursively (with
 * cycle detection via `active`), while character references, the five
 * predefined entities, CDATA sections, comments, and processing
 * instructions are left untouched for the parser or the final text decode
 * to handle.
 * 
 * @ignore
 */
function expand_general_entity(name, dtd, active) {
  let $ = $list.contains(active, name);
  if ($) {
    return new Error(new RecursiveEntity(name));
  } else {
    let $1 = $dict.get(dtd.entities, name);
    if ($1 instanceof Ok) {
      let $2 = $1[0];
      if ($2 instanceof InternalEntity) {
        let replacement = $2.replacement;
        return expand_references_in_bytes(
          $bit_array.from_string(replacement),
          dtd,
          listPrepend(name, active),
          toList([]),
        );
      } else {
        return new Error(new UnresolvableEntity(name));
      }
    } else {
      return new Error(new UnknownEntity(name));
    }
  }
}

function has_attribute(attributes, name) {
  return $list.any(
    attributes,
    (attribute) => { return attribute.name === name; },
  );
}

function do_decode_attribute_text(loop$text, loop$dtd, loop$active, loop$acc) {
  while (true) {
    let text = loop$text;
    let dtd = loop$dtd;
    let active = loop$active;
    let acc = loop$acc;
    let $ = $string.split_once(text, "&");
    if ($ instanceof Ok) {
      let before = $[0][0];
      let after = $[0][1];
      let $1 = $string.split_once(after, ";");
      if ($1 instanceof Ok) {
        let reference = $1[0][0];
        let rest = $1[0][1];
        if (reference.charCodeAt(0) === 35) {
          let $2 = resolve_entity(reference);
          if ($2 instanceof Ok) {
            let replacement = $2[0];
            loop$text = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(replacement, listPrepend(before, acc));
          } else {
            return $2;
          }
        } else if (reference === "amp") {
          let $2 = resolve_entity(reference);
          if ($2 instanceof Ok) {
            let replacement = $2[0];
            loop$text = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(replacement, listPrepend(before, acc));
          } else {
            return $2;
          }
        } else if (reference === "lt") {
          let $2 = resolve_entity(reference);
          if ($2 instanceof Ok) {
            let replacement = $2[0];
            loop$text = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(replacement, listPrepend(before, acc));
          } else {
            return $2;
          }
        } else if (reference === "gt") {
          let $2 = resolve_entity(reference);
          if ($2 instanceof Ok) {
            let replacement = $2[0];
            loop$text = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(replacement, listPrepend(before, acc));
          } else {
            return $2;
          }
        } else if (reference === "quot") {
          let $2 = resolve_entity(reference);
          if ($2 instanceof Ok) {
            let replacement = $2[0];
            loop$text = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(replacement, listPrepend(before, acc));
          } else {
            return $2;
          }
        } else if (reference === "apos") {
          let $2 = resolve_entity(reference);
          if ($2 instanceof Ok) {
            let replacement = $2[0];
            loop$text = rest;
            loop$dtd = dtd;
            loop$active = active;
            loop$acc = listPrepend(replacement, listPrepend(before, acc));
          } else {
            return $2;
          }
        } else {
          let $2 = $list.contains(active, reference);
          if ($2) {
            return new Error(new RecursiveEntity(reference));
          } else {
            let $3 = $dict.get(dtd.entities, reference);
            if ($3 instanceof Ok) {
              let $4 = $3[0];
              if ($4 instanceof InternalEntity) {
                let replacement = $4.replacement;
                let $5 = $string.contains(replacement, "<");
                if ($5) {
                  return new Error(new MarkupInAttributeValue(reference));
                } else {
                  let $6 = decode_attribute_text(
                    replacement,
                    dtd,
                    listPrepend(reference, active),
                  );
                  if ($6 instanceof Ok) {
                    let replacement$1 = $6[0];
                    loop$text = rest;
                    loop$dtd = dtd;
                    loop$active = active;
                    loop$acc = listPrepend(
                      replacement$1,
                      listPrepend(before, acc),
                    );
                  } else {
                    return $6;
                  }
                }
              } else {
                return new Error(new UnresolvableEntity(reference));
              }
            } else {
              return new Error(new UnknownEntity(reference));
            }
          }
        }
      } else {
        return new Error(new MalformedEntity());
      }
    } else {
      return new Ok($string.concat($list.reverse(listPrepend(text, acc))));
    }
  }
}

/**
 * Decode an attribute value: whitespace is normalised to spaces, character
 * references become characters, and entity references are expanded
 * recursively. An entity that would put a `<` in the value is an error, as
 * the specification requires.
 * 
 * @ignore
 */
function decode_attribute_text(text, dtd, active) {
  let _block;
  let _pipe = text;
  let _pipe$1 = $string.replace(_pipe, "\n", " ");
  let _pipe$2 = $string.replace(_pipe$1, "\t", " ");
  _block = $string.replace(_pipe$2, "\r", " ");
  let text$1 = _block;
  return do_decode_attribute_text(text$1, dtd, active, toList([]));
}

/**
 * Scan an attribute value to its closing quote, consuming it. A literal
 * `<` is not allowed in attribute values.
 * 
 * @ignore
 */
function scan_attribute_value(loop$input, loop$count, loop$quote) {
  while (true) {
    let input = loop$input;
    let count = loop$count;
    let quote = loop$quote;
    if (input.bitSize >= 8) {
      if (input.byteAt(0) === 60) {
        if (input.bitSize % 8 === 0) {
          return new Error(
            [new InvalidCharacter(), $bit_array.byte_size(input)],
          );
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (
        input.byteAt(0) === 239 &&
        input.bitSize >= 16 &&
        input.byteAt(1) === 191 &&
        input.bitSize >= 24
      ) {
        if (input.byteAt(2) === 190) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.byteAt(2) === 191) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.bitSize % 8 === 0) {
          let byte = input.byteAt(0);
          let rest = bitArraySlice(input, 8);
          let $ = byte === quote;
          if ($) {
            return new Ok([count, rest]);
          } else {
            let $1 = is_forbidden_byte(byte);
            if ($1) {
              return new Error(
                [new InvalidCharacter(), $bit_array.byte_size(input)],
              );
            } else {
              loop$input = rest;
              loop$count = count + 1;
              loop$quote = quote;
            }
          }
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.bitSize % 8 === 0) {
        let byte = input.byteAt(0);
        let rest = bitArraySlice(input, 8);
        let $ = byte === quote;
        if ($) {
          return new Ok([count, rest]);
        } else {
          let $1 = is_forbidden_byte(byte);
          if ($1) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            loop$input = rest;
            loop$count = count + 1;
            loop$quote = quote;
          }
        }
      } else {
        return new Error([new UnexpectedEndOfInput(), 0]);
      }
    } else {
      return new Error([new UnexpectedEndOfInput(), 0]);
    }
  }
}

function finish_attribute_value(input, quote, dtd) {
  let $ = scan_attribute_value(input, 0, quote);
  if ($ instanceof Ok) {
    let count = $[0][0];
    let rest = $[0][1];
    let $1 = decode_attribute_text(take_string(input, count), dtd, toList([]));
    if ($1 instanceof Ok) {
      let value = $1[0];
      return new Ok([value, rest]);
    } else {
      let kind = $1[0];
      return new Error([kind, $bit_array.byte_size(rest)]);
    }
  } else {
    return $;
  }
}

function parse_attribute_value(input, attribute, dtd) {
  if (input.bitSize >= 8) {
    if (input.byteAt(0) === 34) {
      if (input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        return finish_attribute_value(rest, double_quote, dtd);
      } else {
        return new Error(
          [new MalformedAttribute(attribute), $bit_array.byte_size(input)],
        );
      }
    } else if (input.byteAt(0) === 39 && input.bitSize % 8 === 0) {
      let rest = bitArraySlice(input, 8);
      return finish_attribute_value(rest, single_quote, dtd);
    } else {
      return new Error(
        [new MalformedAttribute(attribute), $bit_array.byte_size(input)],
      );
    }
  } else {
    return new Error(
      [new MalformedAttribute(attribute), $bit_array.byte_size(input)],
    );
  }
}

function parse_attribute(input, dtd) {
  return $result.try$(
    parse_name(input),
    (_use0) => {
      let name = _use0[0];
      let rest = _use0[1];
      let rest$1 = skip_whitespace(rest);
      if (
        rest$1.bitSize >= 8 &&
        rest$1.byteAt(0) === 61 &&
        rest$1.bitSize % 8 === 0
      ) {
        let rest$2 = bitArraySlice(rest$1, 8);
        let rest$3 = skip_whitespace(rest$2);
        return $result.try$(
          parse_attribute_value(rest$3, name, dtd),
          (_use0) => {
            let value = _use0[0];
            let rest$4 = _use0[1];
            return new Ok([new Attribute(name, value), rest$4]);
          },
        );
      } else {
        return new Error(
          [new MalformedAttribute(name), $bit_array.byte_size(rest$1)],
        );
      }
    },
  );
}

function parse_attributes(input, acc, dtd) {
  let stripped = skip_whitespace(input);
  if (stripped.bitSize === 0) {
    return new Error([new UnexpectedEndOfInput(), 0]);
  } else if (stripped.bitSize >= 16) {
    if (stripped.byteAt(0) === 47 && stripped.byteAt(1) === 62) {
      if (stripped.bitSize % 8 === 0) {
        let rest = bitArraySlice(stripped, 16);
        return new Ok([$list.reverse(acc), rest, true]);
      } else {
        return $result.try$(
          (() => {
            let $ = $bit_array.byte_size(stripped) < $bit_array.byte_size(input);
            if ($) {
              return new Ok(stripped);
            } else {
              return new Error(
                [new MissingWhitespace(), $bit_array.byte_size(stripped)],
              );
            }
          })(),
          (input) => {
            let $ = parse_attribute(input, dtd);
            if ($ instanceof Ok) {
              let attribute$1 = $[0][0];
              let rest = $[0][1];
              let $1 = has_attribute(acc, attribute$1.name);
              if ($1) {
                return new Error(
                  [
                    new DuplicateAttribute(attribute$1.name),
                    $bit_array.byte_size(input),
                  ],
                );
              } else {
                return parse_attributes(
                  rest,
                  listPrepend(attribute$1, acc),
                  dtd,
                );
              }
            } else {
              return $;
            }
          },
        );
      }
    } else if (stripped.byteAt(0) === 62 && stripped.bitSize % 8 === 0) {
      let rest = bitArraySlice(stripped, 8);
      return new Ok([$list.reverse(acc), rest, false]);
    } else {
      return $result.try$(
        (() => {
          let $ = $bit_array.byte_size(stripped) < $bit_array.byte_size(input);
          if ($) {
            return new Ok(stripped);
          } else {
            return new Error(
              [new MissingWhitespace(), $bit_array.byte_size(stripped)],
            );
          }
        })(),
        (input) => {
          let $ = parse_attribute(input, dtd);
          if ($ instanceof Ok) {
            let attribute$1 = $[0][0];
            let rest = $[0][1];
            let $1 = has_attribute(acc, attribute$1.name);
            if ($1) {
              return new Error(
                [
                  new DuplicateAttribute(attribute$1.name),
                  $bit_array.byte_size(input),
                ],
              );
            } else {
              return parse_attributes(rest, listPrepend(attribute$1, acc), dtd);
            }
          } else {
            return $;
          }
        },
      );
    }
  } else if (
    stripped.bitSize >= 8 &&
    stripped.byteAt(0) === 62 &&
    stripped.bitSize % 8 === 0
  ) {
    let rest = bitArraySlice(stripped, 8);
    return new Ok([$list.reverse(acc), rest, false]);
  } else {
    return $result.try$(
      (() => {
        let $ = $bit_array.byte_size(stripped) < $bit_array.byte_size(input);
        if ($) {
          return new Ok(stripped);
        } else {
          return new Error(
            [new MissingWhitespace(), $bit_array.byte_size(stripped)],
          );
        }
      })(),
      (input) => {
        let $ = parse_attribute(input, dtd);
        if ($ instanceof Ok) {
          let attribute$1 = $[0][0];
          let rest = $[0][1];
          let $1 = has_attribute(acc, attribute$1.name);
          if ($1) {
            return new Error(
              [
                new DuplicateAttribute(attribute$1.name),
                $bit_array.byte_size(input),
              ],
            );
          } else {
            return parse_attributes(rest, listPrepend(attribute$1, acc), dtd);
          }
        } else {
          return $;
        }
      },
    );
  }
}

/**
 * Parse the expansion of a general entity as content. The expansion must
 * be balanced on its own: reaching the end of the fragment is success, and
 * a closing tag with no matching open element within the fragment is an
 * error. Returns the nodes newest-first, matching how `parse_children`
 * accumulates. General entity references no longer occur here — they were
 * expanded before the fragment was parsed — so only character and
 * predefined references remain.
 * 
 * @ignore
 */
function parse_fragment(
  loop$input,
  loop$dtd,
  loop$entity,
  loop$acc,
  loop$relaxed_entities
) {
  while (true) {
    let input = loop$input;
    let dtd = loop$dtd;
    let entity = loop$entity;
    let acc = loop$acc;
    let relaxed_entities = loop$relaxed_entities;
    if (input.bitSize === 0) {
      return new Ok(acc);
    } else if (input.bitSize >= 16) {
      if (input.byteAt(0) === 60 && input.byteAt(1) === 47) {
        if (input.bitSize % 8 === 0) {
          return new Error(
            [new UnbalancedEntity(entity), $bit_array.byte_size(input)],
          );
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(
              new TextNode(take_string(input, count), true),
              acc,
            );
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        }
      } else if (input.bitSize >= 32) {
        if (
          input.byteAt(0) === 60 &&
            input.byteAt(1) === 33 &&
            input.byteAt(2) === 45 &&
            input.byteAt(3) === 45
        ) {
          if (input.bitSize % 8 === 0) {
            let rest = bitArraySlice(input, 32);
            let $ = parse_comment(rest);
            if ($ instanceof Ok) {
              let content = $[0][0];
              let rest$1 = $[0][1];
              loop$input = rest$1;
              loop$dtd = dtd;
              loop$entity = entity;
              loop$acc = listPrepend(new CommentNode(content), acc);
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          } else {
            let $ = scan_text(input, 0);
            if ($ instanceof Ok) {
              let count = $[0][0];
              let rest = $[0][1];
              loop$input = rest;
              loop$dtd = dtd;
              loop$entity = entity;
              loop$acc = listPrepend(
                new TextNode(take_string(input, count), true),
                acc,
              );
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          }
        } else if (
          input.bitSize >= 72 &&
          input.byteAt(0) === 60 &&
            input.byteAt(1) === 33 &&
            input.byteAt(2) === 91 &&
            input.byteAt(3) === 67 &&
            input.byteAt(4) === 68 &&
            input.byteAt(5) === 65 &&
            input.byteAt(6) === 84 &&
            input.byteAt(7) === 65 &&
            input.byteAt(8) === 91
        ) {
          if (input.bitSize % 8 === 0) {
            let rest = bitArraySlice(input, 72);
            let $ = scan_cdata_end(rest, 0);
            if ($ instanceof Ok) {
              let count = $[0][0];
              let after = $[0][1];
              loop$input = after;
              loop$dtd = dtd;
              loop$entity = entity;
              loop$acc = listPrepend(
                new TextNode(take_string(rest, count), false),
                acc,
              );
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          } else {
            let $ = scan_text(input, 0);
            if ($ instanceof Ok) {
              let count = $[0][0];
              let rest = $[0][1];
              loop$input = rest;
              loop$dtd = dtd;
              loop$entity = entity;
              loop$acc = listPrepend(
                new TextNode(take_string(input, count), true),
                acc,
              );
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          }
        } else if (input.byteAt(0) === 60 && input.byteAt(1) === 63) {
          if (input.bitSize % 8 === 0) {
            let rest = bitArraySlice(input, 16);
            let $ = parse_processing_instruction(rest);
            if ($ instanceof Ok) {
              let instruction = $[0][0];
              let rest$1 = $[0][1];
              loop$input = rest$1;
              loop$dtd = dtd;
              loop$entity = entity;
              loop$acc = listPrepend(instruction, acc);
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          } else {
            let $ = scan_text(input, 0);
            if ($ instanceof Ok) {
              let count = $[0][0];
              let rest = $[0][1];
              loop$input = rest;
              loop$dtd = dtd;
              loop$entity = entity;
              loop$acc = listPrepend(
                new TextNode(take_string(input, count), true),
                acc,
              );
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          }
        } else if (input.byteAt(0) === 60) {
          if (input.bitSize % 8 === 0) {
            let rest = bitArraySlice(input, 8);
            let $ = parse_element(rest, dtd, relaxed_entities);
            if ($ instanceof Ok) {
              let element = $[0][0];
              let rest$1 = $[0][1];
              loop$input = rest$1;
              loop$dtd = dtd;
              loop$entity = entity;
              loop$acc = listPrepend(new ElementNode(element), acc);
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          } else {
            let $ = scan_text(input, 0);
            if ($ instanceof Ok) {
              let count = $[0][0];
              let rest = $[0][1];
              loop$input = rest;
              loop$dtd = dtd;
              loop$entity = entity;
              loop$acc = listPrepend(
                new TextNode(take_string(input, count), true),
                acc,
              );
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          }
        } else if (input.byteAt(0) === 38 && input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          let $ = parse_reference_name(rest);
          if ($ instanceof Ok) {
            let reference = $[0][0];
            let after = $[0][1];
            let $1 = resolve_entity(reference);
            if ($1 instanceof Ok) {
              let text = $1[0];
              let _block;
              if (reference.charCodeAt(0) === 35) {
                _block = false;
              } else {
                _block = true;
              }
              let literal = _block;
              loop$input = after;
              loop$dtd = dtd;
              loop$entity = entity;
              loop$acc = listPrepend(new TextNode(text, literal), acc);
              loop$relaxed_entities = relaxed_entities;
            } else {
              let kind = $1[0];
              return new Error([kind, reference_size(reference, after)]);
            }
          } else {
            return $;
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(
              new TextNode(take_string(input, count), true),
              acc,
            );
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        }
      } else if (input.byteAt(0) === 60 && input.byteAt(1) === 63) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 16);
          let $ = parse_processing_instruction(rest);
          if ($ instanceof Ok) {
            let instruction = $[0][0];
            let rest$1 = $[0][1];
            loop$input = rest$1;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(instruction, acc);
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(
              new TextNode(take_string(input, count), true),
              acc,
            );
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        }
      } else if (input.byteAt(0) === 60) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          let $ = parse_element(rest, dtd, relaxed_entities);
          if ($ instanceof Ok) {
            let element = $[0][0];
            let rest$1 = $[0][1];
            loop$input = rest$1;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(new ElementNode(element), acc);
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(
              new TextNode(take_string(input, count), true),
              acc,
            );
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        }
      } else if (input.byteAt(0) === 38 && input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        let $ = parse_reference_name(rest);
        if ($ instanceof Ok) {
          let reference = $[0][0];
          let after = $[0][1];
          let $1 = resolve_entity(reference);
          if ($1 instanceof Ok) {
            let text = $1[0];
            let _block;
            if (reference.charCodeAt(0) === 35) {
              _block = false;
            } else {
              _block = true;
            }
            let literal = _block;
            loop$input = after;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(new TextNode(text, literal), acc);
            loop$relaxed_entities = relaxed_entities;
          } else {
            let kind = $1[0];
            return new Error([kind, reference_size(reference, after)]);
          }
        } else {
          return $;
        }
      } else {
        let $ = scan_text(input, 0);
        if ($ instanceof Ok) {
          let count = $[0][0];
          let rest = $[0][1];
          loop$input = rest;
          loop$dtd = dtd;
          loop$entity = entity;
          loop$acc = listPrepend(
            new TextNode(take_string(input, count), true),
            acc,
          );
          loop$relaxed_entities = relaxed_entities;
        } else {
          return $;
        }
      }
    } else if (input.bitSize >= 8) {
      if (input.byteAt(0) === 60) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          let $ = parse_element(rest, dtd, relaxed_entities);
          if ($ instanceof Ok) {
            let element = $[0][0];
            let rest$1 = $[0][1];
            loop$input = rest$1;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(new ElementNode(element), acc);
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(
              new TextNode(take_string(input, count), true),
              acc,
            );
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        }
      } else if (input.byteAt(0) === 38 && input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        let $ = parse_reference_name(rest);
        if ($ instanceof Ok) {
          let reference = $[0][0];
          let after = $[0][1];
          let $1 = resolve_entity(reference);
          if ($1 instanceof Ok) {
            let text = $1[0];
            let _block;
            if (reference.charCodeAt(0) === 35) {
              _block = false;
            } else {
              _block = true;
            }
            let literal = _block;
            loop$input = after;
            loop$dtd = dtd;
            loop$entity = entity;
            loop$acc = listPrepend(new TextNode(text, literal), acc);
            loop$relaxed_entities = relaxed_entities;
          } else {
            let kind = $1[0];
            return new Error([kind, reference_size(reference, after)]);
          }
        } else {
          return $;
        }
      } else {
        let $ = scan_text(input, 0);
        if ($ instanceof Ok) {
          let count = $[0][0];
          let rest = $[0][1];
          loop$input = rest;
          loop$dtd = dtd;
          loop$entity = entity;
          loop$acc = listPrepend(
            new TextNode(take_string(input, count), true),
            acc,
          );
          loop$relaxed_entities = relaxed_entities;
        } else {
          return $;
        }
      }
    } else {
      let $ = scan_text(input, 0);
      if ($ instanceof Ok) {
        let count = $[0][0];
        let rest = $[0][1];
        loop$input = rest;
        loop$dtd = dtd;
        loop$entity = entity;
        loop$acc = listPrepend(
          new TextNode(take_string(input, count), true),
          acc,
        );
        loop$relaxed_entities = relaxed_entities;
      } else {
        return $;
      }
    }
  }
}

/**
 * Parse the children of an element up to and including its closing tag.
 *
 * When `in_markup` is true the input begins just after a `<`. This function
 * only ever tail-calls itself so that it compiles to a loop on the
 * JavaScript target, where a long run of sibling nodes would otherwise
 * overflow the stack.
 * 
 * @ignore
 */
function parse_children(
  loop$input,
  loop$in_markup,
  loop$parent,
  loop$acc,
  loop$dtd,
  loop$relaxed_entities
) {
  while (true) {
    let input = loop$input;
    let in_markup = loop$in_markup;
    let parent = loop$parent;
    let acc = loop$acc;
    let dtd = loop$dtd;
    let relaxed_entities = loop$relaxed_entities;
    if (in_markup) {
      if (input.bitSize === 0) {
        return new Error([new UnexpectedEndOfInput(), 0]);
      } else if (input.bitSize >= 8) {
        if (input.byteAt(0) === 47) {
          if (input.bitSize % 8 === 0) {
            let rest = bitArraySlice(input, 8);
            return parse_closing_tag(rest, parent, acc);
          } else {
            let $ = parse_element(input, dtd, relaxed_entities);
            if ($ instanceof Ok) {
              let element = $[0][0];
              let rest = $[0][1];
              loop$input = rest;
              loop$in_markup = false;
              loop$parent = parent;
              loop$acc = listPrepend(new ElementNode(element), acc);
              loop$dtd = dtd;
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          }
        } else if (input.bitSize >= 24) {
          if (
            input.byteAt(0) === 33 &&
              input.byteAt(1) === 45 &&
              input.byteAt(2) === 45
          ) {
            if (input.bitSize % 8 === 0) {
              let rest = bitArraySlice(input, 24);
              let $ = parse_comment(rest);
              if ($ instanceof Ok) {
                let content = $[0][0];
                let rest$1 = $[0][1];
                loop$input = rest$1;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(new CommentNode(content), acc);
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                return $;
              }
            } else {
              let $ = parse_element(input, dtd, relaxed_entities);
              if ($ instanceof Ok) {
                let element = $[0][0];
                let rest = $[0][1];
                loop$input = rest;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(new ElementNode(element), acc);
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                return $;
              }
            }
          } else if (
            input.bitSize >= 64 &&
            input.byteAt(0) === 33 &&
              input.byteAt(1) === 91 &&
              input.byteAt(2) === 67 &&
              input.byteAt(3) === 68 &&
              input.byteAt(4) === 65 &&
              input.byteAt(5) === 84 &&
              input.byteAt(6) === 65 &&
              input.byteAt(7) === 91
          ) {
            if (input.bitSize % 8 === 0) {
              let rest = bitArraySlice(input, 64);
              let $ = scan_cdata_end(rest, 0);
              if ($ instanceof Ok) {
                let count = $[0][0];
                let after = $[0][1];
                loop$input = after;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(
                  new TextNode(take_string(rest, count), false),
                  acc,
                );
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                return $;
              }
            } else {
              let $ = parse_element(input, dtd, relaxed_entities);
              if ($ instanceof Ok) {
                let element = $[0][0];
                let rest = $[0][1];
                loop$input = rest;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(new ElementNode(element), acc);
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                return $;
              }
            }
          } else if (input.byteAt(0) === 63 && input.bitSize % 8 === 0) {
            let rest = bitArraySlice(input, 8);
            let $ = parse_processing_instruction(rest);
            if ($ instanceof Ok) {
              let instruction = $[0][0];
              let rest$1 = $[0][1];
              loop$input = rest$1;
              loop$in_markup = false;
              loop$parent = parent;
              loop$acc = listPrepend(instruction, acc);
              loop$dtd = dtd;
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          } else {
            let $ = parse_element(input, dtd, relaxed_entities);
            if ($ instanceof Ok) {
              let element = $[0][0];
              let rest = $[0][1];
              loop$input = rest;
              loop$in_markup = false;
              loop$parent = parent;
              loop$acc = listPrepend(new ElementNode(element), acc);
              loop$dtd = dtd;
              loop$relaxed_entities = relaxed_entities;
            } else {
              return $;
            }
          }
        } else if (input.byteAt(0) === 63 && input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          let $ = parse_processing_instruction(rest);
          if ($ instanceof Ok) {
            let instruction = $[0][0];
            let rest$1 = $[0][1];
            loop$input = rest$1;
            loop$in_markup = false;
            loop$parent = parent;
            loop$acc = listPrepend(instruction, acc);
            loop$dtd = dtd;
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        } else {
          let $ = parse_element(input, dtd, relaxed_entities);
          if ($ instanceof Ok) {
            let element = $[0][0];
            let rest = $[0][1];
            loop$input = rest;
            loop$in_markup = false;
            loop$parent = parent;
            loop$acc = listPrepend(new ElementNode(element), acc);
            loop$dtd = dtd;
            loop$relaxed_entities = relaxed_entities;
          } else {
            return $;
          }
        }
      } else {
        let $ = parse_element(input, dtd, relaxed_entities);
        if ($ instanceof Ok) {
          let element = $[0][0];
          let rest = $[0][1];
          loop$input = rest;
          loop$in_markup = false;
          loop$parent = parent;
          loop$acc = listPrepend(new ElementNode(element), acc);
          loop$dtd = dtd;
          loop$relaxed_entities = relaxed_entities;
        } else {
          return $;
        }
      }
    } else {
      if (input.bitSize === 0) {
        return new Error([new UnexpectedEndOfInput(), 0]);
      } else if (input.bitSize >= 8) {
        if (input.byteAt(0) === 60) {
          if (input.bitSize % 8 === 0) {
            let rest = bitArraySlice(input, 8);
            loop$input = rest;
            loop$in_markup = true;
            loop$parent = parent;
            loop$acc = acc;
            loop$dtd = dtd;
            loop$relaxed_entities = relaxed_entities;
          } else {
            let $ = scan_text(input, 0);
            if ($ instanceof Ok) {
              let count = $[0][0];
              let rest = $[0][1];
              if (rest.bitSize === 0) {
                return new Error([new UnexpectedEndOfInput(), 0]);
              } else {
                loop$input = rest;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(
                  new TextNode(take_string(input, count), true),
                  acc,
                );
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              }
            } else {
              return $;
            }
          }
        } else if (input.byteAt(0) === 38 && input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          let $ = parse_reference_name(rest);
          if ($ instanceof Ok) {
            let reference = $[0][0];
            let after = $[0][1];
            if (reference.charCodeAt(0) === 35) {
              let $1 = resolve_entity(reference);
              if ($1 instanceof Ok) {
                let text = $1[0];
                loop$input = after;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(new TextNode(text, false), acc);
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                let kind = $1[0];
                return new Error([kind, reference_size(reference, after)]);
              }
            } else if (reference === "amp") {
              let $1 = resolve_entity(reference);
              if ($1 instanceof Ok) {
                let text = $1[0];
                loop$input = after;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(new TextNode(text, true), acc);
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                let kind = $1[0];
                return new Error([kind, reference_size(reference, after)]);
              }
            } else if (reference === "lt") {
              let $1 = resolve_entity(reference);
              if ($1 instanceof Ok) {
                let text = $1[0];
                loop$input = after;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(new TextNode(text, true), acc);
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                let kind = $1[0];
                return new Error([kind, reference_size(reference, after)]);
              }
            } else if (reference === "gt") {
              let $1 = resolve_entity(reference);
              if ($1 instanceof Ok) {
                let text = $1[0];
                loop$input = after;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(new TextNode(text, true), acc);
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                let kind = $1[0];
                return new Error([kind, reference_size(reference, after)]);
              }
            } else if (reference === "quot") {
              let $1 = resolve_entity(reference);
              if ($1 instanceof Ok) {
                let text = $1[0];
                loop$input = after;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(new TextNode(text, true), acc);
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                let kind = $1[0];
                return new Error([kind, reference_size(reference, after)]);
              }
            } else if (reference === "apos") {
              let $1 = resolve_entity(reference);
              if ($1 instanceof Ok) {
                let text = $1[0];
                loop$input = after;
                loop$in_markup = false;
                loop$parent = parent;
                loop$acc = listPrepend(new TextNode(text, true), acc);
                loop$dtd = dtd;
                loop$relaxed_entities = relaxed_entities;
              } else {
                let kind = $1[0];
                return new Error([kind, reference_size(reference, after)]);
              }
            } else {
              let $1 = expand_general_entity(reference, dtd, toList([]));
              if ($1 instanceof Ok) {
                let expansion = $1[0];
                let $2 = $string.contains(expansion, "<");
                if ($2) {
                  let $3 = parse_fragment(
                    $bit_array.from_string(expansion),
                    dtd,
                    reference,
                    toList([]),
                    relaxed_entities,
                  );
                  if ($3 instanceof Ok) {
                    let nodes = $3[0];
                    loop$input = after;
                    loop$in_markup = false;
                    loop$parent = parent;
                    loop$acc = $list.append(nodes, acc);
                    loop$dtd = dtd;
                    loop$relaxed_entities = relaxed_entities;
                  } else {
                    let kind = $3[0][0];
                    let _block;
                    if (kind instanceof UnexpectedEndOfInput) {
                      _block = new UnbalancedEntity(reference);
                    } else if (kind instanceof MismatchedClosingTag) {
                      _block = new UnbalancedEntity(reference);
                    } else {
                      _block = kind;
                    }
                    let kind$1 = _block;
                    return new Error([kind$1, reference_size(reference, after)]);
                  }
                } else {
                  let $3 = decode_character_references(expansion);
                  if ($3 instanceof Ok) {
                    let text = $3[0][0];
                    let literal = $3[0][1];
                    loop$input = after;
                    loop$in_markup = false;
                    loop$parent = parent;
                    loop$acc = listPrepend(new TextNode(text, literal), acc);
                    loop$dtd = dtd;
                    loop$relaxed_entities = relaxed_entities;
                  } else {
                    let kind = $3[0];
                    return new Error([kind, reference_size(reference, after)]);
                  }
                }
              } else {
                let kind = $1[0];
                if (relaxed_entities && kind instanceof UnknownEntity) {
                  loop$input = after;
                  loop$in_markup = false;
                  loop$parent = parent;
                  loop$acc = listPrepend(
                    new EntityReferenceNode(reference),
                    acc,
                  );
                  loop$dtd = dtd;
                  loop$relaxed_entities = relaxed_entities;
                } else {
                  return new Error([kind, reference_size(reference, after)]);
                }
              }
            }
          } else {
            return $;
          }
        } else {
          let $ = scan_text(input, 0);
          if ($ instanceof Ok) {
            let count = $[0][0];
            let rest = $[0][1];
            if (rest.bitSize === 0) {
              return new Error([new UnexpectedEndOfInput(), 0]);
            } else {
              loop$input = rest;
              loop$in_markup = false;
              loop$parent = parent;
              loop$acc = listPrepend(
                new TextNode(take_string(input, count), true),
                acc,
              );
              loop$dtd = dtd;
              loop$relaxed_entities = relaxed_entities;
            }
          } else {
            return $;
          }
        }
      } else {
        let $ = scan_text(input, 0);
        if ($ instanceof Ok) {
          let count = $[0][0];
          let rest = $[0][1];
          if (rest.bitSize === 0) {
            return new Error([new UnexpectedEndOfInput(), 0]);
          } else {
            loop$input = rest;
            loop$in_markup = false;
            loop$parent = parent;
            loop$acc = listPrepend(
              new TextNode(take_string(input, count), true),
              acc,
            );
            loop$dtd = dtd;
            loop$relaxed_entities = relaxed_entities;
          }
        } else {
          return $;
        }
      }
    }
  }
}

/**
 * Parse an element. The input begins immediately after the opening `<`.
 * 
 * @ignore
 */
function parse_element(input, dtd, relaxed_entities) {
  return $result.try$(
    parse_name(input),
    (_use0) => {
      let name = _use0[0];
      let rest = _use0[1];
      return $result.try$(
        parse_attributes(rest, toList([]), dtd),
        (_use0) => {
          let attributes = _use0[0];
          let rest$1 = _use0[1];
          let self_closing = _use0[2];
          if (self_closing) {
            return new Ok([new Element(name, attributes, toList([])), rest$1]);
          } else {
            return $result.try$(
              parse_children(
                rest$1,
                false,
                name,
                toList([]),
                dtd,
                relaxed_entities,
              ),
              (_use0) => {
                let children = _use0[0];
                let rest$2 = _use0[1];
                return new Ok([new Element(name, attributes, children), rest$2]);
              },
            );
          }
        },
      );
    },
  );
}

/**
 * Combine two DTDs. Where both declare the same name the `preferred` DTD
 * wins, matching the XML rule that the first declaration of an entity is
 * binding. Use this to merge a document's internal subset with an external
 * DTD: `merge_dtds(doctype.declarations, external)`.
 *
 * One exception to preference: when the preferred DTD declares an entity
 * as an external parsed entity (whose content this library cannot fetch)
 * and the other DTD supplies an `InternalEntity` under the same name, the
 * supplied content is used. This is how callers provide the content of
 * external entities: load the file yourself and pass it as an
 * `InternalEntity` in the DTD given to `parse_with_dtd`.
 */
export function merge_dtds(preferred, other) {
  let _block;
  let _pipe = $dict.merge(other.entities, preferred.entities);
  _block = $dict.map_values(
    _pipe,
    (name, entity) => {
      if (entity instanceof ExternalEntity) {
        let $ = entity.notation;
        if ($ instanceof None) {
          let $1 = $dict.get(other.entities, name);
          if ($1 instanceof Ok) {
            let $2 = $1[0];
            if ($2 instanceof InternalEntity) {
              let replacement = $2.replacement;
              return new InternalEntity(replacement);
            } else {
              return entity;
            }
          } else {
            return entity;
          }
        } else {
          return entity;
        }
      } else {
        return entity;
      }
    },
  );
  let entities = _block;
  let attribute_lists = $dict.fold(
    other.attribute_lists,
    preferred.attribute_lists,
    (merged, element, other_declarations) => {
      let _block$1;
      let _pipe$1 = $dict.get(preferred.attribute_lists, element);
      _block$1 = $result.unwrap(_pipe$1, toList([]));
      let preferred_declarations = _block$1;
      let additional = $list.filter(
        other_declarations,
        (declaration) => {
          return !$list.any(
            preferred_declarations,
            (d) => { return d.name === declaration.name; },
          );
        },
      );
      return $dict.insert(
        merged,
        element,
        $list.append(preferred_declarations, additional),
      );
    },
  );
  return new Dtd(
    $dict.merge(other.elements, preferred.elements),
    attribute_lists,
    entities,
    $dict.merge(other.parameter_entities, preferred.parameter_entities),
    (() => {
      let _pipe$1 = $list.append(preferred.notations, other.notations);
      return $list.unique(_pipe$1);
    })(),
    (() => {
      let _pipe$1 = $list.append(
        preferred.duplicate_elements,
        other.duplicate_elements,
      );
      return $list.unique(_pipe$1);
    })(),
    (() => {
      let _pipe$1 = $list.append(
        preferred.pe_nesting_violations,
        other.pe_nesting_violations,
      );
      return $list.unique(_pipe$1);
    })(),
  );
}

/**
 * Error positions inside parameter entity replacements are reported at
 * the position of the reference in the outermost input.
 * 
 * @ignore
 */
function dtd_position(loop$input) {
  while (true) {
    let input = loop$input;
    let $ = input.parent;
    if ($ instanceof Some) {
      let parent = $[0];
      loop$input = parent;
    } else {
      return $bit_array.byte_size(input.current);
    }
  }
}

function advance(input, rest) {
  return new DtdInput(
    rest,
    input.entity,
    input.id,
    input.from_declaration_separator,
    input.parent,
  );
}

function record_nesting_violation(state, description) {
  let dtd = state.dtd;
  return new DtdState(
    new Dtd(
      dtd.elements,
      dtd.attribute_lists,
      dtd.entities,
      dtd.parameter_entities,
      dtd.notations,
      dtd.duplicate_elements,
      listPrepend(description, dtd.pe_nesting_violations),
    ),
    state.external,
    state.next_id,
    state.pe_used,
    state.internal_parameter_entities,
  );
}

/**
 * When a construct opens in one entity and closes in another, record a
 * violation of the Proper Declaration/Group/Conditional Section PE
 * Nesting validity constraints. (The well-formedness case — a between-
 * declarations parameter entity whose replacement is not complete
 * declarations — is caught when its segment is popped mid-construct.)
 * 
 * @ignore
 */
function check_same_segment(input, state, opened_in, what) {
  let $ = input.id === opened_in;
  if ($) {
    return new Ok(state);
  } else {
    return new Ok(
      record_nesting_violation(
        state,
        what + " does not start and end in the same entity",
      ),
    );
  }
}

/**
 * Whether parameter entity references may be expanded here: anywhere in
 * an external subset, and inside parameter entity replacement text, but
 * not within markup declarations written directly in the internal subset.
 * 
 * @ignore
 */
function may_expand_here(input, state) {
  return state.external || $option.is_some(input.parent);
}

function do_skip_dtd_space(
  loop$input,
  loop$state,
  loop$expand,
  loop$at_declaration_separator
) {
  while (true) {
    let input = loop$input;
    let state = loop$state;
    let expand = loop$expand;
    let at_declaration_separator = loop$at_declaration_separator;
    let input$1 = advance(input, skip_whitespace(input.current));
    let $ = input$1.current;
    let $1 = input$1.parent;
    if ($1 instanceof Some && $.bitSize === 0) {
      let parent = $1[0];
      let $2 = input$1.from_declaration_separator && !at_declaration_separator;
      if ($2) {
        return new Error([new MalformedDoctype(), dtd_position(input$1)]);
      } else {
        loop$input = parent;
        loop$state = state;
        loop$expand = expand;
        loop$at_declaration_separator = at_declaration_separator;
      }
    } else if ($.bitSize >= 8 && $.byteAt(0) === 37 && $.bitSize % 8 === 0) {
      let rest = bitArraySlice($, 8);
      if (expand) {
        let $2 = parse_reference_name(rest);
        if ($2 instanceof Ok) {
          let name = $2[0][0];
          let rest$1 = $2[0][1];
          let $3 = $dict.get(state.dtd.parameter_entities, name);
          if ($3 instanceof Ok) {
            let replacement = $3[0];
            let segment = new DtdInput(
              $bit_array.from_string(replacement),
              new Some(name),
              state.next_id,
              at_declaration_separator,
              new Some(advance(input$1, rest$1)),
            );
            let state$1 = new DtdState(
              state.dtd,
              state.external,
              state.next_id + 1,
              true,
              state.internal_parameter_entities,
            );
            loop$input = segment;
            loop$state = state$1;
            loop$expand = expand;
            loop$at_declaration_separator = at_declaration_separator;
          } else {
            return new Error([new UnknownEntity(name), dtd_position(input$1)]);
          }
        } else {
          let kind = $2[0][0];
          return new Error([kind, dtd_position(input$1)]);
        }
      } else {
        return new Ok([input$1, state]);
      }
    } else {
      return new Ok([input$1, state]);
    }
  }
}

/**
 * Skip whitespace, popping exhausted segments, and (where allowed)
 * expanding `%name;` parameter entity references by pushing a segment
 * with their replacement text.
 * 
 * @ignore
 */
function skip_dtd_space(input, state, expand) {
  return do_skip_dtd_space(input, state, expand, false);
}

/**
 * Skip DTD whitespace and the closing `>` of a declaration, checking that
 * the declaration ends in the entity it started in.
 * 
 * @ignore
 */
function close_declaration(input, state, opened_in) {
  return $result.try$(
    skip_dtd_space(input, state, may_expand_here(input, state)),
    (_use0) => {
      let input$1 = _use0[0];
      let state$1 = _use0[1];
      let $ = input$1.current;
      if ($.bitSize >= 8) {
        if ($.byteAt(0) === 62 && $.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 8);
          let $1 = check_same_segment(
            input$1,
            state$1,
            opened_in,
            "a markup declaration",
          );
          if ($1 instanceof Ok) {
            let state$2 = $1[0];
            return new Ok([advance(input$1, rest), state$2]);
          } else {
            return $1;
          }
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input$1)]);
        }
      } else if ($.bitSize === 0) {
        return new Error([new UnexpectedEndOfInput(), 0]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input$1)]);
      }
    },
  );
}

/**
 * Scan to the given byte (a quote in every current use), consuming it.
 * Forbidden characters are errors.
 * 
 * @ignore
 */
function scan_to_byte(loop$input, loop$count, loop$target) {
  while (true) {
    let input = loop$input;
    let count = loop$count;
    let target = loop$target;
    if (input.bitSize >= 8) {
      if (
        input.byteAt(0) === 239 &&
        input.bitSize >= 16 &&
        input.byteAt(1) === 191 &&
        input.bitSize >= 24
      ) {
        if (input.byteAt(2) === 190) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.byteAt(2) === 191) {
          if (input.bitSize % 8 === 0) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            return new Error([new UnexpectedEndOfInput(), 0]);
          }
        } else if (input.bitSize % 8 === 0) {
          let byte = input.byteAt(0);
          let rest = bitArraySlice(input, 8);
          let $ = byte === target;
          if ($) {
            return new Ok([count, rest]);
          } else {
            let $1 = is_forbidden_byte(byte);
            if ($1) {
              return new Error(
                [new InvalidCharacter(), $bit_array.byte_size(input)],
              );
            } else {
              loop$input = rest;
              loop$count = count + 1;
              loop$target = target;
            }
          }
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.bitSize % 8 === 0) {
        let byte = input.byteAt(0);
        let rest = bitArraySlice(input, 8);
        let $ = byte === target;
        if ($) {
          return new Ok([count, rest]);
        } else {
          let $1 = is_forbidden_byte(byte);
          if ($1) {
            return new Error(
              [new InvalidCharacter(), $bit_array.byte_size(input)],
            );
          } else {
            loop$input = rest;
            loop$count = count + 1;
            loop$target = target;
          }
        }
      } else {
        return new Error([new UnexpectedEndOfInput(), 0]);
      }
    } else {
      return new Error([new UnexpectedEndOfInput(), 0]);
    }
  }
}

function finish_quoted_literal(input, quote) {
  let $ = scan_to_byte(input, 0, quote);
  if ($ instanceof Ok) {
    let count = $[0][0];
    let rest = $[0][1];
    return new Ok([take_string(input, count), rest]);
  } else {
    return $;
  }
}

function parse_quoted_literal(input) {
  if (input.bitSize >= 8) {
    if (input.byteAt(0) === 34) {
      if (input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        return finish_quoted_literal(rest, double_quote);
      } else {
        return new Error([new MalformedDoctype(), $bit_array.byte_size(input)]);
      }
    } else if (input.byteAt(0) === 39 && input.bitSize % 8 === 0) {
      let rest = bitArraySlice(input, 8);
      return finish_quoted_literal(rest, single_quote);
    } else {
      return new Error([new MalformedDoctype(), $bit_array.byte_size(input)]);
    }
  } else {
    return new Error([new MalformedDoctype(), $bit_array.byte_size(input)]);
  }
}

function dtd_quoted_literal(input) {
  let $ = parse_quoted_literal(input.current);
  if ($ instanceof Ok) {
    let value = $[0][0];
    let rest = $[0][1];
    return new Ok([value, advance(input, rest)]);
  } else {
    let kind = $[0][0];
    return new Error([kind, dtd_position(input)]);
  }
}

/**
 * Require at least one whitespace character; a segment boundary or a
 * parameter entity reference also separates tokens, exactly as the
 * specification's space padding would.
 * 
 * @ignore
 */
function require_dtd_space(input, state, expand) {
  let $ = input.current;
  if ($.bitSize >= 8) {
    if ($.byteAt(0) === 32) {
      if ($.bitSize % 8 === 0) {
        return skip_dtd_space(input, state, expand);
      } else {
        return new Error([new MissingWhitespace(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 9) {
      if ($.bitSize % 8 === 0) {
        return skip_dtd_space(input, state, expand);
      } else {
        return new Error([new MissingWhitespace(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 10) {
      if ($.bitSize % 8 === 0) {
        return skip_dtd_space(input, state, expand);
      } else {
        return new Error([new MissingWhitespace(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 37 && $.bitSize % 8 === 0) {
      if (expand) {
        return skip_dtd_space(input, state, expand);
      } else {
        return new Error([new MissingWhitespace(), dtd_position(input)]);
      }
    } else {
      return new Error([new MissingWhitespace(), dtd_position(input)]);
    }
  } else if ($.bitSize === 0) {
    let $1 = input.parent;
    if ($1 instanceof Some) {
      return skip_dtd_space(input, state, expand);
    } else {
      return new Error([new MissingWhitespace(), dtd_position(input)]);
    }
  } else {
    return new Error([new MissingWhitespace(), dtd_position(input)]);
  }
}

/**
 * The PubidChar production: public identifiers use a restricted character
 * set.
 * 
 * @ignore
 */
function is_valid_public_id(public$) {
  let _pipe = $string.to_utf_codepoints(public$);
  return $list.all(
    _pipe,
    (codepoint) => {
      let code = $string.utf_codepoint_to_int(codepoint);
      return (((((code === 0x20) || (code === 0xA)) || ((code >= 0x61) && (code <= 0x7A))) || ((code >= 0x41) && (code <= 0x5A))) || ((code >= 0x30) && (code <= 0x39))) || $string.contains(
        "-'()+,./:=?;!*#@$_%",
        $string.from_utf_codepoints(toList([codepoint])),
      );
    },
  );
}

/**
 * Parse a SYSTEM or PUBLIC identifier within a DTD declaration. Keywords
 * and literals are tokens, so they lie within one entity; the whitespace
 * between them may cross entity boundaries.
 * 
 * @ignore
 */
function parse_external_id_in_dtd(input, state, require_system) {
  let $ = input.current;
  if ($.bitSize >= 48) {
    if (
      $.byteAt(0) === 83 &&
        $.byteAt(1) === 89 &&
        $.byteAt(2) === 83 &&
        $.byteAt(3) === 84 &&
        $.byteAt(4) === 69 &&
        $.byteAt(5) === 77
    ) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 48);
        return $result.try$(
          require_dtd_space(
            advance(input, rest),
            state,
            may_expand_here(input, state),
          ),
          (_use0) => {
            let input$1 = _use0[0];
            let state$1 = _use0[1];
            return $result.try$(
              dtd_quoted_literal(input$1),
              (_use0) => {
                let system = _use0[0];
                let input$2 = _use0[1];
                return new Ok([new System(system), input$2, state$1]);
              },
            );
          },
        );
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if (
      $.byteAt(0) === 80 &&
        $.byteAt(1) === 85 &&
        $.byteAt(2) === 66 &&
        $.byteAt(3) === 76 &&
        $.byteAt(4) === 73 &&
        $.byteAt(5) === 67 &&
      $.bitSize % 8 === 0
    ) {
      let rest = bitArraySlice($, 48);
      return $result.try$(
        require_dtd_space(
          advance(input, rest),
          state,
          may_expand_here(input, state),
        ),
        (_use0) => {
          let input$1 = _use0[0];
          let state$1 = _use0[1];
          return $result.try$(
            dtd_quoted_literal(input$1),
            (_use0) => {
              let public$ = _use0[0];
              let input$2 = _use0[1];
              return require(
                is_valid_public_id(public$),
                [new MalformedDoctype(), dtd_position(input$2)],
                () => {
                  if (require_system) {
                    return $result.try$(
                      require_dtd_space(
                        input$2,
                        state$1,
                        may_expand_here(input$2, state$1),
                      ),
                      (_use0) => {
                        let input$3 = _use0[0];
                        let state$2 = _use0[1];
                        return $result.try$(
                          dtd_quoted_literal(input$3),
                          (_use0) => {
                            let system = _use0[0];
                            let input$4 = _use0[1];
                            return new Ok(
                              [
                                new Public(public$, new Some(system)),
                                input$4,
                                state$2,
                              ],
                            );
                          },
                        );
                      },
                    );
                  } else {
                    let after_public = advance(
                      input$2,
                      skip_whitespace(input$2.current),
                    );
                    let $1 = dtd_quoted_literal(after_public);
                    if ($1 instanceof Ok) {
                      let system = $1[0][0];
                      let input$3 = $1[0][1];
                      return new Ok(
                        [
                          new Public(public$, new Some(system)),
                          input$3,
                          state$1,
                        ],
                      );
                    } else {
                      return new Ok(
                        [new Public(public$, new None()), input$2, state$1],
                      );
                    }
                  }
                },
              );
            },
          );
        },
      );
    } else {
      return new Error([new MalformedDoctype(), dtd_position(input)]);
    }
  } else {
    return new Error([new MalformedDoctype(), dtd_position(input)]);
  }
}

/**
 * Parse a name from the current segment, with error positions mapped to
 * the outermost input.
 * 
 * @ignore
 */
function dtd_name(input) {
  let $ = parse_name(input.current);
  if ($ instanceof Ok) {
    return $;
  } else {
    let kind = $[0][0];
    return new Error([kind, dtd_position(input)]);
  }
}

function parse_notation_declaration(input, state, opened_in) {
  return $result.try$(
    require_dtd_space(input, state, may_expand_here(input, state)),
    (_use0) => {
      let input$1 = _use0[0];
      let state$1 = _use0[1];
      return $result.try$(
        dtd_name(input$1),
        (_use0) => {
          let name = _use0[0];
          let rest = _use0[1];
          let input$2 = advance(input$1, rest);
          return $result.try$(
            require_dtd_space(
              input$2,
              state$1,
              may_expand_here(input$2, state$1),
            ),
            (_use0) => {
              let input$3 = _use0[0];
              let state$2 = _use0[1];
              return $result.try$(
                parse_external_id_in_dtd(input$3, state$2, false),
                (_use0) => {
                  let input$4 = _use0[1];
                  let state$3 = _use0[2];
                  return $result.try$(
                    close_declaration(input$4, state$3, opened_in),
                    (_use0) => {
                      let input$5 = _use0[0];
                      let state$4 = _use0[1];
                      let dtd = state$4.dtd;
                      let _block;
                      let $ = $list.contains(dtd.notations, name);
                      if ($) {
                        _block = dtd;
                      } else {
                        _block = new Dtd(
                          dtd.elements,
                          dtd.attribute_lists,
                          dtd.entities,
                          dtd.parameter_entities,
                          listPrepend(name, dtd.notations),
                          dtd.duplicate_elements,
                          dtd.pe_nesting_violations,
                        );
                      }
                      let dtd$1 = _block;
                      return new Ok(
                        [
                          input$5,
                          new DtdState(
                            dtd$1,
                            state$4.external,
                            state$4.next_id,
                            state$4.pe_used,
                            state$4.internal_parameter_entities,
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

/**
 * Parse a quoted attribute default value, decoding references the same way
 * attribute values in documents are decoded. The literal must close within
 * the entity it opened in.
 * 
 * @ignore
 */
function parse_default_value(input, state) {
  return $result.try$(
    (() => {
      let $ = input.current;
      if ($.bitSize >= 8) {
        if ($.byteAt(0) === 34) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 8);
            return new Ok([double_quote, advance(input, rest)]);
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input)]);
          }
        } else if ($.byteAt(0) === 39 && $.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 8);
          return new Ok([single_quote, advance(input, rest)]);
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input)]);
        }
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    })(),
    (_use0) => {
      let quote = _use0[0];
      let input$1 = _use0[1];
      let $ = scan_attribute_value(input$1.current, 0, quote);
      if ($ instanceof Ok) {
        let count = $[0][0];
        let rest = $[0][1];
        let $1 = decode_attribute_text(
          take_string(input$1.current, count),
          state.dtd,
          toList([]),
        );
        if ($1 instanceof Ok) {
          let value = $1[0];
          return new Ok([value, advance(input$1, rest), state]);
        } else {
          let kind = $1[0];
          return new Error([kind, dtd_position(input$1)]);
        }
      } else {
        let kind = $[0][0];
        return new Error([kind, dtd_position(input$1)]);
      }
    },
  );
}

function parse_attribute_default(input, state) {
  let $ = input.current;
  if ($.bitSize >= 72) {
    if (
      $.byteAt(0) === 35 &&
        $.byteAt(1) === 82 &&
        $.byteAt(2) === 69 &&
        $.byteAt(3) === 81 &&
        $.byteAt(4) === 85 &&
        $.byteAt(5) === 73 &&
        $.byteAt(6) === 82 &&
        $.byteAt(7) === 69 &&
        $.byteAt(8) === 68
    ) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 72);
        return new Ok([new Required(), advance(input, rest), state]);
      } else {
        return $result.try$(
          parse_default_value(input, state),
          (_use0) => {
            let value = _use0[0];
            let input$1 = _use0[1];
            let state$1 = _use0[2];
            return new Ok([new Default(value), input$1, state$1]);
          },
        );
      }
    } else if (
      $.byteAt(0) === 35 &&
        $.byteAt(1) === 73 &&
        $.byteAt(2) === 77 &&
        $.byteAt(3) === 80 &&
        $.byteAt(4) === 76 &&
        $.byteAt(5) === 73 &&
        $.byteAt(6) === 69 &&
        $.byteAt(7) === 68
    ) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 64);
        return new Ok([new Implied(), advance(input, rest), state]);
      } else {
        return $result.try$(
          parse_default_value(input, state),
          (_use0) => {
            let value = _use0[0];
            let input$1 = _use0[1];
            let state$1 = _use0[2];
            return new Ok([new Default(value), input$1, state$1]);
          },
        );
      }
    } else if (
      $.byteAt(0) === 35 &&
        $.byteAt(1) === 70 &&
        $.byteAt(2) === 73 &&
        $.byteAt(3) === 88 &&
        $.byteAt(4) === 69 &&
        $.byteAt(5) === 68 &&
      $.bitSize % 8 === 0
    ) {
      let rest = bitArraySlice($, 48);
      return $result.try$(
        require_dtd_space(
          advance(input, rest),
          state,
          may_expand_here(input, state),
        ),
        (_use0) => {
          let input$1 = _use0[0];
          let state$1 = _use0[1];
          return $result.try$(
            parse_default_value(input$1, state$1),
            (_use0) => {
              let value = _use0[0];
              let input$2 = _use0[1];
              let state$2 = _use0[2];
              return new Ok([new Fixed(value), input$2, state$2]);
            },
          );
        },
      );
    } else {
      return $result.try$(
        parse_default_value(input, state),
        (_use0) => {
          let value = _use0[0];
          let input$1 = _use0[1];
          let state$1 = _use0[2];
          return new Ok([new Default(value), input$1, state$1]);
        },
      );
    }
  } else if ($.bitSize >= 64) {
    if (
      $.byteAt(0) === 35 &&
        $.byteAt(1) === 73 &&
        $.byteAt(2) === 77 &&
        $.byteAt(3) === 80 &&
        $.byteAt(4) === 76 &&
        $.byteAt(5) === 73 &&
        $.byteAt(6) === 69 &&
        $.byteAt(7) === 68
    ) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 64);
        return new Ok([new Implied(), advance(input, rest), state]);
      } else {
        return $result.try$(
          parse_default_value(input, state),
          (_use0) => {
            let value = _use0[0];
            let input$1 = _use0[1];
            let state$1 = _use0[2];
            return new Ok([new Default(value), input$1, state$1]);
          },
        );
      }
    } else if (
      $.byteAt(0) === 35 &&
        $.byteAt(1) === 70 &&
        $.byteAt(2) === 73 &&
        $.byteAt(3) === 88 &&
        $.byteAt(4) === 69 &&
        $.byteAt(5) === 68 &&
      $.bitSize % 8 === 0
    ) {
      let rest = bitArraySlice($, 48);
      return $result.try$(
        require_dtd_space(
          advance(input, rest),
          state,
          may_expand_here(input, state),
        ),
        (_use0) => {
          let input$1 = _use0[0];
          let state$1 = _use0[1];
          return $result.try$(
            parse_default_value(input$1, state$1),
            (_use0) => {
              let value = _use0[0];
              let input$2 = _use0[1];
              let state$2 = _use0[2];
              return new Ok([new Fixed(value), input$2, state$2]);
            },
          );
        },
      );
    } else {
      return $result.try$(
        parse_default_value(input, state),
        (_use0) => {
          let value = _use0[0];
          let input$1 = _use0[1];
          let state$1 = _use0[2];
          return new Ok([new Default(value), input$1, state$1]);
        },
      );
    }
  } else if (
    $.bitSize >= 48 &&
    $.byteAt(0) === 35 &&
      $.byteAt(1) === 70 &&
      $.byteAt(2) === 73 &&
      $.byteAt(3) === 88 &&
      $.byteAt(4) === 69 &&
      $.byteAt(5) === 68 &&
    $.bitSize % 8 === 0
  ) {
    let rest = bitArraySlice($, 48);
    return $result.try$(
      require_dtd_space(
        advance(input, rest),
        state,
        may_expand_here(input, state),
      ),
      (_use0) => {
        let input$1 = _use0[0];
        let state$1 = _use0[1];
        return $result.try$(
          parse_default_value(input$1, state$1),
          (_use0) => {
            let value = _use0[0];
            let input$2 = _use0[1];
            let state$2 = _use0[2];
            return new Ok([new Fixed(value), input$2, state$2]);
          },
        );
      },
    );
  } else {
    return $result.try$(
      parse_default_value(input, state),
      (_use0) => {
        let value = _use0[0];
        let input$1 = _use0[1];
        let state$1 = _use0[2];
        return new Ok([new Default(value), input$1, state$1]);
      },
    );
  }
}

/**
 * Parse a name token (`Nmtoken`): like a name, but without the restriction
 * on the first character, so `007` is a valid name token.
 * 
 * @ignore
 */
function parse_nmtoken(input) {
  let $ = scan_name(input, 0);
  let $1 = $[0];
  if ($1 === 0) {
    let $2 = $[1];
    if ($2.bitSize === 0) {
      return new Error([new UnexpectedEndOfInput(), 0]);
    } else {
      let rest = $2;
      return new Error([new InvalidName(), $bit_array.byte_size(rest)]);
    }
  } else {
    let count = $1;
    let rest = $[1];
    let token = take_string(input, count);
    let _block;
    let _pipe = $string.to_utf_codepoints(token);
    _block = $list.all(
      _pipe,
      (codepoint) => {
        return is_name_character($string.utf_codepoint_to_int(codepoint));
      },
    );
    let valid = _block;
    if (valid) {
      return new Ok([token, rest]);
    } else {
      return new Error([new InvalidName(), $bit_array.byte_size(input)]);
    }
  }
}

function parse_name_enumeration(input, state, names, opened_in) {
  return $result.try$(
    skip_dtd_space(input, state, may_expand_here(input, state)),
    (_use0) => {
      let input$1 = _use0[0];
      let state$1 = _use0[1];
      return $result.try$(
        (() => {
          let $ = parse_nmtoken(input$1.current);
          if ($ instanceof Ok) {
            return $;
          } else {
            let kind = $[0][0];
            return new Error([kind, dtd_position(input$1)]);
          }
        })(),
        (_use0) => {
          let name = _use0[0];
          let rest = _use0[1];
          let input$2 = advance(input$1, rest);
          return $result.try$(
            skip_dtd_space(input$2, state$1, may_expand_here(input$2, state$1)),
            (_use0) => {
              let input$3 = _use0[0];
              let state$2 = _use0[1];
              let $ = input$3.current;
              if ($.bitSize >= 8) {
                if ($.byteAt(0) === 41) {
                  if ($.bitSize % 8 === 0) {
                    let rest$1 = bitArraySlice($, 8);
                    let $1 = check_same_segment(
                      input$3,
                      state$2,
                      opened_in,
                      "an enumeration",
                    );
                    if ($1 instanceof Ok) {
                      let state$3 = $1[0];
                      return new Ok(
                        [
                          $list.reverse(listPrepend(name, names)),
                          advance(input$3, rest$1),
                          state$3,
                        ],
                      );
                    } else {
                      return $1;
                    }
                  } else {
                    return new Error(
                      [new MalformedDoctype(), dtd_position(input$3)],
                    );
                  }
                } else if ($.byteAt(0) === 124 && $.bitSize % 8 === 0) {
                  let rest$1 = bitArraySlice($, 8);
                  return parse_name_enumeration(
                    advance(input$3, rest$1),
                    state$2,
                    listPrepend(name, names),
                    opened_in,
                  );
                } else {
                  return new Error(
                    [new MalformedDoctype(), dtd_position(input$3)],
                  );
                }
              } else if ($.bitSize === 0) {
                return new Error([new UnexpectedEndOfInput(), 0]);
              } else {
                return new Error(
                  [new MalformedDoctype(), dtd_position(input$3)],
                );
              }
            },
          );
        },
      );
    },
  );
}

function parse_attribute_kind(input, state) {
  let $ = input.current;
  if ($.bitSize >= 40) {
    if (
      $.byteAt(0) === 67 &&
        $.byteAt(1) === 68 &&
        $.byteAt(2) === 65 &&
        $.byteAt(3) === 84 &&
        $.byteAt(4) === 65
    ) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 40);
        return new Ok([new CdataAttribute(), advance(input, rest), state]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if ($.bitSize >= 48) {
      if (
        $.byteAt(0) === 73 &&
          $.byteAt(1) === 68 &&
          $.byteAt(2) === 82 &&
          $.byteAt(3) === 69 &&
          $.byteAt(4) === 70 &&
          $.byteAt(5) === 83
      ) {
        if ($.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 48);
          return new Ok([new IdRefsAttribute(), advance(input, rest), state]);
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input)]);
        }
      } else if (
        $.byteAt(0) === 73 &&
          $.byteAt(1) === 68 &&
          $.byteAt(2) === 82 &&
          $.byteAt(3) === 69 &&
          $.byteAt(4) === 70
      ) {
        if ($.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 40);
          return new Ok([new IdRefAttribute(), advance(input, rest), state]);
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input)]);
        }
      } else if ($.byteAt(0) === 73 && $.byteAt(1) === 68) {
        if ($.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 16);
          return new Ok([new IdAttribute(), advance(input, rest), state]);
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input)]);
        }
      } else if ($.bitSize >= 64) {
        if (
          $.byteAt(0) === 69 &&
            $.byteAt(1) === 78 &&
            $.byteAt(2) === 84 &&
            $.byteAt(3) === 73 &&
            $.byteAt(4) === 84 &&
            $.byteAt(5) === 73 &&
            $.byteAt(6) === 69 &&
            $.byteAt(7) === 83
        ) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 64);
            return new Ok(
              [new EntitiesAttribute(), advance(input, rest), state],
            );
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input)]);
          }
        } else if (
          $.byteAt(0) === 69 &&
            $.byteAt(1) === 78 &&
            $.byteAt(2) === 84 &&
            $.byteAt(3) === 73 &&
            $.byteAt(4) === 84 &&
            $.byteAt(5) === 89
        ) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 48);
            return new Ok([new EntityAttribute(), advance(input, rest), state]);
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input)]);
          }
        } else if (
          $.byteAt(0) === 78 &&
            $.byteAt(1) === 77 &&
            $.byteAt(2) === 84 &&
            $.byteAt(3) === 79 &&
            $.byteAt(4) === 75 &&
            $.byteAt(5) === 69 &&
            $.byteAt(6) === 78 &&
            $.byteAt(7) === 83
        ) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 64);
            return new Ok(
              [new NmtokensAttribute(), advance(input, rest), state],
            );
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input)]);
          }
        } else if (
          $.byteAt(0) === 78 &&
            $.byteAt(1) === 77 &&
            $.byteAt(2) === 84 &&
            $.byteAt(3) === 79 &&
            $.byteAt(4) === 75 &&
            $.byteAt(5) === 69 &&
            $.byteAt(6) === 78
        ) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 56);
            return new Ok([new NmtokenAttribute(), advance(input, rest), state]);
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input)]);
          }
        } else if (
          $.byteAt(0) === 78 &&
            $.byteAt(1) === 79 &&
            $.byteAt(2) === 84 &&
            $.byteAt(3) === 65 &&
            $.byteAt(4) === 84 &&
            $.byteAt(5) === 73 &&
            $.byteAt(6) === 79 &&
            $.byteAt(7) === 78
        ) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 64);
            return $result.try$(
              require_dtd_space(
                advance(input, rest),
                state,
                may_expand_here(input, state),
              ),
              (_use0) => {
                let input$1 = _use0[0];
                let state$1 = _use0[1];
                let $1 = input$1.current;
                if (
                  $1.bitSize >= 8 &&
                  $1.byteAt(0) === 40 &&
                  $1.bitSize % 8 === 0
                ) {
                  let rest$1 = bitArraySlice($1, 8);
                  let opened_in = input$1.id;
                  return $result.try$(
                    parse_name_enumeration(
                      advance(input$1, rest$1),
                      state$1,
                      toList([]),
                      opened_in,
                    ),
                    (_use0) => {
                      let names = _use0[0];
                      let input$2 = _use0[1];
                      let state$2 = _use0[2];
                      return new Ok(
                        [new NotationAttribute(names), input$2, state$2],
                      );
                    },
                  );
                } else {
                  return new Error(
                    [new MalformedDoctype(), dtd_position(input$1)],
                  );
                }
              },
            );
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input)]);
          }
        } else if ($.byteAt(0) === 40 && $.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 8);
          let opened_in = input.id;
          return $result.try$(
            parse_name_enumeration(
              advance(input, rest),
              state,
              toList([]),
              opened_in,
            ),
            (_use0) => {
              let names = _use0[0];
              let input$1 = _use0[1];
              let state$1 = _use0[2];
              return new Ok([new EnumeratedAttribute(names), input$1, state$1]);
            },
          );
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input)]);
        }
      } else if (
        $.byteAt(0) === 69 &&
          $.byteAt(1) === 78 &&
          $.byteAt(2) === 84 &&
          $.byteAt(3) === 73 &&
          $.byteAt(4) === 84 &&
          $.byteAt(5) === 89
      ) {
        if ($.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 48);
          return new Ok([new EntityAttribute(), advance(input, rest), state]);
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input)]);
        }
      } else if (
        $.bitSize >= 56 &&
        $.byteAt(0) === 78 &&
          $.byteAt(1) === 77 &&
          $.byteAt(2) === 84 &&
          $.byteAt(3) === 79 &&
          $.byteAt(4) === 75 &&
          $.byteAt(5) === 69 &&
          $.byteAt(6) === 78
      ) {
        if ($.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 56);
          return new Ok([new NmtokenAttribute(), advance(input, rest), state]);
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input)]);
        }
      } else if ($.byteAt(0) === 40 && $.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 8);
        let opened_in = input.id;
        return $result.try$(
          parse_name_enumeration(
            advance(input, rest),
            state,
            toList([]),
            opened_in,
          ),
          (_use0) => {
            let names = _use0[0];
            let input$1 = _use0[1];
            let state$1 = _use0[2];
            return new Ok([new EnumeratedAttribute(names), input$1, state$1]);
          },
        );
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if (
      $.byteAt(0) === 73 &&
        $.byteAt(1) === 68 &&
        $.byteAt(2) === 82 &&
        $.byteAt(3) === 69 &&
        $.byteAt(4) === 70
    ) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 40);
        return new Ok([new IdRefAttribute(), advance(input, rest), state]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 73 && $.byteAt(1) === 68) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 16);
        return new Ok([new IdAttribute(), advance(input, rest), state]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 40 && $.bitSize % 8 === 0) {
      let rest = bitArraySlice($, 8);
      let opened_in = input.id;
      return $result.try$(
        parse_name_enumeration(
          advance(input, rest),
          state,
          toList([]),
          opened_in,
        ),
        (_use0) => {
          let names = _use0[0];
          let input$1 = _use0[1];
          let state$1 = _use0[2];
          return new Ok([new EnumeratedAttribute(names), input$1, state$1]);
        },
      );
    } else {
      return new Error([new MalformedDoctype(), dtd_position(input)]);
    }
  } else if ($.bitSize >= 16) {
    if ($.byteAt(0) === 73 && $.byteAt(1) === 68) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 16);
        return new Ok([new IdAttribute(), advance(input, rest), state]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 40 && $.bitSize % 8 === 0) {
      let rest = bitArraySlice($, 8);
      let opened_in = input.id;
      return $result.try$(
        parse_name_enumeration(
          advance(input, rest),
          state,
          toList([]),
          opened_in,
        ),
        (_use0) => {
          let names = _use0[0];
          let input$1 = _use0[1];
          let state$1 = _use0[2];
          return new Ok([new EnumeratedAttribute(names), input$1, state$1]);
        },
      );
    } else {
      return new Error([new MalformedDoctype(), dtd_position(input)]);
    }
  } else if ($.bitSize >= 8) {
    if ($.byteAt(0) === 40 && $.bitSize % 8 === 0) {
      let rest = bitArraySlice($, 8);
      let opened_in = input.id;
      return $result.try$(
        parse_name_enumeration(
          advance(input, rest),
          state,
          toList([]),
          opened_in,
        ),
        (_use0) => {
          let names = _use0[0];
          let input$1 = _use0[1];
          let state$1 = _use0[2];
          return new Ok([new EnumeratedAttribute(names), input$1, state$1]);
        },
      );
    } else {
      return new Error([new MalformedDoctype(), dtd_position(input)]);
    }
  } else if ($.bitSize === 0) {
    return new Error([new UnexpectedEndOfInput(), 0]);
  } else {
    return new Error([new MalformedDoctype(), dtd_position(input)]);
  }
}

function parse_attlist_attribute(input, state) {
  return $result.try$(
    dtd_name(input),
    (_use0) => {
      let name = _use0[0];
      let rest = _use0[1];
      let input$1 = advance(input, rest);
      return $result.try$(
        require_dtd_space(input$1, state, may_expand_here(input$1, state)),
        (_use0) => {
          let input$2 = _use0[0];
          let state$1 = _use0[1];
          return $result.try$(
            parse_attribute_kind(input$2, state$1),
            (_use0) => {
              let kind = _use0[0];
              let input$3 = _use0[1];
              let state$2 = _use0[2];
              return $result.try$(
                require_dtd_space(
                  input$3,
                  state$2,
                  may_expand_here(input$3, state$2),
                ),
                (_use0) => {
                  let input$4 = _use0[0];
                  let state$3 = _use0[1];
                  return $result.try$(
                    parse_attribute_default(input$4, state$3),
                    (_use0) => {
                      let default$ = _use0[0];
                      let input$5 = _use0[1];
                      let state$4 = _use0[2];
                      return new Ok(
                        [
                          new AttributeDeclaration(name, kind, default$),
                          input$5,
                          state$4,
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

function parse_attlist_attributes(
  loop$input,
  loop$state,
  loop$element,
  loop$declared,
  loop$opened_in
) {
  while (true) {
    let input = loop$input;
    let state = loop$state;
    let element = loop$element;
    let declared = loop$declared;
    let opened_in = loop$opened_in;
    let _block;
    let $ = input.current;
    if ($.bitSize >= 8 && $.byteAt(0) === 62 && $.bitSize % 8 === 0) {
      _block = new Ok([input, state]);
    } else {
      _block = require_dtd_space(input, state, may_expand_here(input, state));
    }
    let space = _block;
    if (space instanceof Ok) {
      let input$1 = space[0][0];
      let state$1 = space[0][1];
      let $1 = input$1.current;
      if ($1.bitSize === 0) {
        return new Error([new UnexpectedEndOfInput(), 0]);
      } else if ($1.bitSize >= 8 && $1.byteAt(0) === 62 && $1.bitSize % 8 === 0) {
        let rest = bitArraySlice($1, 8);
        let $2 = check_same_segment(
          input$1,
          state$1,
          opened_in,
          "a markup declaration",
        );
        if ($2 instanceof Ok) {
          let state$2 = $2[0];
          let dtd = state$2.dtd;
          let _block$1;
          let _pipe = $dict.get(dtd.attribute_lists, element);
          _block$1 = $result.unwrap(_pipe, toList([]));
          let existing = _block$1;
          let new$ = $list.filter(
            $list.reverse(declared),
            (declaration) => {
              return !$list.any(
                existing,
                (existing) => { return existing.name === declaration.name; },
              );
            },
          );
          let dtd$1 = new Dtd(
            dtd.elements,
            $dict.insert(
              dtd.attribute_lists,
              element,
              $list.append(existing, new$),
            ),
            dtd.entities,
            dtd.parameter_entities,
            dtd.notations,
            dtd.duplicate_elements,
            dtd.pe_nesting_violations,
          );
          return new Ok(
            [
              advance(input$1, rest),
              new DtdState(
                dtd$1,
                state$2.external,
                state$2.next_id,
                state$2.pe_used,
                state$2.internal_parameter_entities,
              ),
            ],
          );
        } else {
          return $2;
        }
      } else {
        let $2 = parse_attlist_attribute(input$1, state$1);
        if ($2 instanceof Ok) {
          let declaration = $2[0][0];
          let input$2 = $2[0][1];
          let state$2 = $2[0][2];
          loop$input = input$2;
          loop$state = state$2;
          loop$element = element;
          loop$declared = listPrepend(declaration, declared);
          loop$opened_in = opened_in;
        } else {
          return $2;
        }
      }
    } else {
      return space;
    }
  }
}

function parse_attlist_declaration(input, state, opened_in) {
  return $result.try$(
    require_dtd_space(input, state, may_expand_here(input, state)),
    (_use0) => {
      let input$1 = _use0[0];
      let state$1 = _use0[1];
      return $result.try$(
        dtd_name(input$1),
        (_use0) => {
          let element = _use0[0];
          let rest = _use0[1];
          return parse_attlist_attributes(
            advance(input$1, rest),
            state$1,
            element,
            toList([]),
            opened_in,
          );
        },
      );
    },
  );
}

function parse_occurrence(input) {
  if (input.bitSize >= 8) {
    if (input.byteAt(0) === 63) {
      if (input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        return [new ZeroOrOne(), rest];
      } else {
        return [new ExactlyOne(), input];
      }
    } else if (input.byteAt(0) === 42) {
      if (input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        return [new ZeroOrMore(), rest];
      } else {
        return [new ExactlyOne(), input];
      }
    } else if (input.byteAt(0) === 43 && input.bitSize % 8 === 0) {
      let rest = bitArraySlice(input, 8);
      return [new OneOrMore(), rest];
    } else {
      return [new ExactlyOne(), input];
    }
  } else {
    return [new ExactlyOne(), input];
  }
}

function parse_particle(input, state) {
  let $ = input.current;
  if ($.bitSize >= 8 && $.byteAt(0) === 40 && $.bitSize % 8 === 0) {
    let rest = bitArraySlice($, 8);
    let opened_in = input.id;
    return $result.try$(
      skip_dtd_space(advance(input, rest), state, may_expand_here(input, state)),
      (_use0) => {
        let input$1 = _use0[0];
        let state$1 = _use0[1];
        return parse_group(input$1, state$1, opened_in);
      },
    );
  } else {
    return $result.try$(
      dtd_name(input),
      (_use0) => {
        let name = _use0[0];
        let rest = _use0[1];
        let $1 = parse_occurrence(rest);
        let occurrence = $1[0];
        let rest$1 = $1[1];
        return new Ok(
          [new NameParticle(name, occurrence), advance(input, rest$1), state],
        );
      },
    );
  }
}

function parse_group_items(input, state, particles, separator, opened_in) {
  return $result.try$(
    skip_dtd_space(input, state, may_expand_here(input, state)),
    (_use0) => {
      let input$1 = _use0[0];
      let state$1 = _use0[1];
      let $ = input$1.current;
      if ($.bitSize >= 8) {
        if ($.byteAt(0) === 41) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 8);
            let $1 = check_same_segment(
              input$1,
              state$1,
              opened_in,
              "a content model group",
            );
            if ($1 instanceof Ok) {
              let state$2 = $1[0];
              let $2 = parse_occurrence(rest);
              let occurrence = $2[0];
              let rest$1 = $2[1];
              let particles$1 = $list.reverse(particles);
              let _block;
              if (separator instanceof ChoiceSeparator) {
                _block = new Choice(particles$1, occurrence);
              } else {
                _block = new Sequence(particles$1, occurrence);
              }
              let particle = _block;
              return new Ok([particle, advance(input$1, rest$1), state$2]);
            } else {
              return $1;
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if ($.byteAt(0) === 124) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 8);
            if (separator instanceof SequenceSeparator) {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            } else {
              return $result.try$(
                skip_dtd_space(
                  advance(input$1, rest),
                  state$1,
                  may_expand_here(input$1, state$1),
                ),
                (_use0) => {
                  let input$2 = _use0[0];
                  let state$2 = _use0[1];
                  return $result.try$(
                    parse_particle(input$2, state$2),
                    (_use0) => {
                      let particle = _use0[0];
                      let input$3 = _use0[1];
                      let state$3 = _use0[2];
                      return parse_group_items(
                        input$3,
                        state$3,
                        listPrepend(particle, particles),
                        new ChoiceSeparator(),
                        opened_in,
                      );
                    },
                  );
                },
              );
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if ($.byteAt(0) === 44 && $.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 8);
          if (separator instanceof ChoiceSeparator) {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          } else {
            return $result.try$(
              skip_dtd_space(
                advance(input$1, rest),
                state$1,
                may_expand_here(input$1, state$1),
              ),
              (_use0) => {
                let input$2 = _use0[0];
                let state$2 = _use0[1];
                return $result.try$(
                  parse_particle(input$2, state$2),
                  (_use0) => {
                    let particle = _use0[0];
                    let input$3 = _use0[1];
                    let state$3 = _use0[2];
                    return parse_group_items(
                      input$3,
                      state$3,
                      listPrepend(particle, particles),
                      new SequenceSeparator(),
                      opened_in,
                    );
                  },
                );
              },
            );
          }
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input$1)]);
        }
      } else if ($.bitSize === 0) {
        return new Error([new UnexpectedEndOfInput(), 0]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input$1)]);
      }
    },
  );
}

/**
 * Parse a `(a, b)` or `(a | b)` group body. The input begins after the
 * opening `(`, whose segment id is given so the closing parenthesis can
 * be checked against it.
 * 
 * @ignore
 */
function parse_group(input, state, opened_in) {
  return $result.try$(
    parse_particle(input, state),
    (_use0) => {
      let first = _use0[0];
      let input$1 = _use0[1];
      let state$1 = _use0[2];
      return parse_group_items(
        input$1,
        state$1,
        toList([first]),
        new UndecidedSeparator(),
        opened_in,
      );
    },
  );
}

/**
 * Parse the rest of a `(#PCDATA | a | b)*` mixed content model, after the
 * `#PCDATA`. The closing parenthesis must be in the same entity as the
 * opening one.
 * 
 * @ignore
 */
function parse_mixed_content(input, state, names, opened_in) {
  return $result.try$(
    skip_dtd_space(input, state, may_expand_here(input, state)),
    (_use0) => {
      let input$1 = _use0[0];
      let state$1 = _use0[1];
      let $ = input$1.current;
      if ($.bitSize >= 16) {
        if ($.byteAt(0) === 41 && $.byteAt(1) === 42) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 16);
            let $1 = check_same_segment(
              input$1,
              state$1,
              opened_in,
              "a content model group",
            );
            if ($1 instanceof Ok) {
              let state$2 = $1[0];
              return new Ok(
                [
                  new MixedContent($list.reverse(names)),
                  advance(input$1, rest),
                  state$2,
                ],
              );
            } else {
              return $1;
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if ($.byteAt(0) === 41) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 8);
            if (names instanceof $Empty) {
              let $1 = check_same_segment(
                input$1,
                state$1,
                opened_in,
                "a content model group",
              );
              if ($1 instanceof Ok) {
                let state$2 = $1[0];
                return new Ok(
                  [
                    new MixedContent(toList([])),
                    advance(input$1, rest),
                    state$2,
                  ],
                );
              } else {
                return $1;
              }
            } else {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if ($.byteAt(0) === 124 && $.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 8);
          return $result.try$(
            skip_dtd_space(
              advance(input$1, rest),
              state$1,
              may_expand_here(input$1, state$1),
            ),
            (_use0) => {
              let input$2 = _use0[0];
              let state$2 = _use0[1];
              return $result.try$(
                dtd_name(input$2),
                (_use0) => {
                  let name = _use0[0];
                  let rest$1 = _use0[1];
                  return parse_mixed_content(
                    advance(input$2, rest$1),
                    state$2,
                    listPrepend(name, names),
                    opened_in,
                  );
                },
              );
            },
          );
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input$1)]);
        }
      } else if ($.bitSize >= 8) {
        if ($.byteAt(0) === 41) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 8);
            if (names instanceof $Empty) {
              let $1 = check_same_segment(
                input$1,
                state$1,
                opened_in,
                "a content model group",
              );
              if ($1 instanceof Ok) {
                let state$2 = $1[0];
                return new Ok(
                  [
                    new MixedContent(toList([])),
                    advance(input$1, rest),
                    state$2,
                  ],
                );
              } else {
                return $1;
              }
            } else {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if ($.byteAt(0) === 124 && $.bitSize % 8 === 0) {
          let rest = bitArraySlice($, 8);
          return $result.try$(
            skip_dtd_space(
              advance(input$1, rest),
              state$1,
              may_expand_here(input$1, state$1),
            ),
            (_use0) => {
              let input$2 = _use0[0];
              let state$2 = _use0[1];
              return $result.try$(
                dtd_name(input$2),
                (_use0) => {
                  let name = _use0[0];
                  let rest$1 = _use0[1];
                  return parse_mixed_content(
                    advance(input$2, rest$1),
                    state$2,
                    listPrepend(name, names),
                    opened_in,
                  );
                },
              );
            },
          );
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input$1)]);
        }
      } else if ($.bitSize === 0) {
        return new Error([new UnexpectedEndOfInput(), 0]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input$1)]);
      }
    },
  );
}

function parse_content_model(input, state) {
  let $ = input.current;
  if ($.bitSize >= 40) {
    if (
      $.byteAt(0) === 69 &&
        $.byteAt(1) === 77 &&
        $.byteAt(2) === 80 &&
        $.byteAt(3) === 84 &&
        $.byteAt(4) === 89
    ) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 40);
        return new Ok([new EmptyContent(), advance(input, rest), state]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 65 && $.byteAt(1) === 78 && $.byteAt(2) === 89) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 24);
        return new Ok([new AnyContent(), advance(input, rest), state]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 40 && $.bitSize % 8 === 0) {
      let rest = bitArraySlice($, 8);
      let opened_in = input.id;
      return $result.try$(
        skip_dtd_space(
          advance(input, rest),
          state,
          may_expand_here(input, state),
        ),
        (_use0) => {
          let input$1 = _use0[0];
          let state$1 = _use0[1];
          let $1 = input$1.current;
          if (
            $1.bitSize >= 56 &&
            $1.byteAt(0) === 35 &&
              $1.byteAt(1) === 80 &&
              $1.byteAt(2) === 67 &&
              $1.byteAt(3) === 68 &&
              $1.byteAt(4) === 65 &&
              $1.byteAt(5) === 84 &&
              $1.byteAt(6) === 65 &&
            $1.bitSize % 8 === 0
          ) {
            let rest$1 = bitArraySlice($1, 56);
            return parse_mixed_content(
              advance(input$1, rest$1),
              state$1,
              toList([]),
              opened_in,
            );
          } else {
            return $result.try$(
              parse_group(input$1, state$1, opened_in),
              (_use0) => {
                let particle = _use0[0];
                let input$2 = _use0[1];
                let state$2 = _use0[2];
                return new Ok([new ElementContent(particle), input$2, state$2]);
              },
            );
          }
        },
      );
    } else {
      return new Error([new MalformedDoctype(), dtd_position(input)]);
    }
  } else if ($.bitSize >= 24) {
    if ($.byteAt(0) === 65 && $.byteAt(1) === 78 && $.byteAt(2) === 89) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 24);
        return new Ok([new AnyContent(), advance(input, rest), state]);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 40 && $.bitSize % 8 === 0) {
      let rest = bitArraySlice($, 8);
      let opened_in = input.id;
      return $result.try$(
        skip_dtd_space(
          advance(input, rest),
          state,
          may_expand_here(input, state),
        ),
        (_use0) => {
          let input$1 = _use0[0];
          let state$1 = _use0[1];
          let $1 = input$1.current;
          if (
            $1.bitSize >= 56 &&
            $1.byteAt(0) === 35 &&
              $1.byteAt(1) === 80 &&
              $1.byteAt(2) === 67 &&
              $1.byteAt(3) === 68 &&
              $1.byteAt(4) === 65 &&
              $1.byteAt(5) === 84 &&
              $1.byteAt(6) === 65 &&
            $1.bitSize % 8 === 0
          ) {
            let rest$1 = bitArraySlice($1, 56);
            return parse_mixed_content(
              advance(input$1, rest$1),
              state$1,
              toList([]),
              opened_in,
            );
          } else {
            return $result.try$(
              parse_group(input$1, state$1, opened_in),
              (_use0) => {
                let particle = _use0[0];
                let input$2 = _use0[1];
                let state$2 = _use0[2];
                return new Ok([new ElementContent(particle), input$2, state$2]);
              },
            );
          }
        },
      );
    } else {
      return new Error([new MalformedDoctype(), dtd_position(input)]);
    }
  } else if ($.bitSize >= 8 && $.byteAt(0) === 40 && $.bitSize % 8 === 0) {
    let rest = bitArraySlice($, 8);
    let opened_in = input.id;
    return $result.try$(
      skip_dtd_space(advance(input, rest), state, may_expand_here(input, state)),
      (_use0) => {
        let input$1 = _use0[0];
        let state$1 = _use0[1];
        let $1 = input$1.current;
        if (
          $1.bitSize >= 56 &&
          $1.byteAt(0) === 35 &&
            $1.byteAt(1) === 80 &&
            $1.byteAt(2) === 67 &&
            $1.byteAt(3) === 68 &&
            $1.byteAt(4) === 65 &&
            $1.byteAt(5) === 84 &&
            $1.byteAt(6) === 65 &&
          $1.bitSize % 8 === 0
        ) {
          let rest$1 = bitArraySlice($1, 56);
          return parse_mixed_content(
            advance(input$1, rest$1),
            state$1,
            toList([]),
            opened_in,
          );
        } else {
          return $result.try$(
            parse_group(input$1, state$1, opened_in),
            (_use0) => {
              let particle = _use0[0];
              let input$2 = _use0[1];
              let state$2 = _use0[2];
              return new Ok([new ElementContent(particle), input$2, state$2]);
            },
          );
        }
      },
    );
  } else {
    return new Error([new MalformedDoctype(), dtd_position(input)]);
  }
}

function parse_element_declaration(input, state, opened_in) {
  return $result.try$(
    require_dtd_space(input, state, may_expand_here(input, state)),
    (_use0) => {
      let input$1 = _use0[0];
      let state$1 = _use0[1];
      return $result.try$(
        dtd_name(input$1),
        (_use0) => {
          let name = _use0[0];
          let rest = _use0[1];
          let input$2 = advance(input$1, rest);
          return $result.try$(
            require_dtd_space(
              input$2,
              state$1,
              may_expand_here(input$2, state$1),
            ),
            (_use0) => {
              let input$3 = _use0[0];
              let state$2 = _use0[1];
              return $result.try$(
                parse_content_model(input$3, state$2),
                (_use0) => {
                  let model = _use0[0];
                  let input$4 = _use0[1];
                  let state$3 = _use0[2];
                  return $result.try$(
                    close_declaration(input$4, state$3, opened_in),
                    (_use0) => {
                      let input$5 = _use0[0];
                      let state$4 = _use0[1];
                      let dtd = state$4.dtd;
                      let _block;
                      let $ = $dict.has_key(dtd.elements, name);
                      if ($) {
                        _block = new Dtd(
                          dtd.elements,
                          dtd.attribute_lists,
                          dtd.entities,
                          dtd.parameter_entities,
                          dtd.notations,
                          listPrepend(name, dtd.duplicate_elements),
                          dtd.pe_nesting_violations,
                        );
                      } else {
                        _block = new Dtd(
                          $dict.insert(dtd.elements, name, model),
                          dtd.attribute_lists,
                          dtd.entities,
                          dtd.parameter_entities,
                          dtd.notations,
                          dtd.duplicate_elements,
                          dtd.pe_nesting_violations,
                        );
                      }
                      let dtd$1 = _block;
                      return new Ok(
                        [
                          input$5,
                          new DtdState(
                            dtd$1,
                            state$4.external,
                            state$4.next_id,
                            state$4.pe_used,
                            state$4.internal_parameter_entities,
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

/**
 * Expand character references in an entity value, keeping general entity
 * references (`&name;`) untouched for later.
 * 
 * @ignore
 */
function expand_character_references(text) {
  let $ = $string.split_once(text, "&");
  if ($ instanceof Ok) {
    let before = $[0][0];
    let after = $[0][1];
    let $1 = $string.split_once(after, ";");
    if ($1 instanceof Ok) {
      let reference = $1[0][0];
      let rest = $1[0][1];
      return $result.try$(
        (() => {
          if (reference.charCodeAt(0) === 35) {
            return resolve_entity(reference);
          } else {
            let $2 = is_valid_name(reference);
            if ($2) {
              return new Ok(("&" + reference) + ";");
            } else {
              return new Error(new MalformedEntity());
            }
          }
        })(),
        (expanded) => {
          return $result.try$(
            expand_character_references(rest),
            (rest) => { return new Ok((before + expanded) + rest); },
          );
        },
      );
    } else {
      return new Error(new MalformedEntity());
    }
  } else {
    return new Ok(text);
  }
}

function expand_parameter_references(text, state, allowed) {
  let $ = $string.split_once(text, "%");
  if ($ instanceof Ok) {
    let before = $[0][0];
    let after = $[0][1];
    if (allowed) {
      let $1 = $string.split_once(after, ";");
      if ($1 instanceof Ok) {
        let name = $1[0][0];
        let rest = $1[0][1];
        let $2 = $dict.get(state.dtd.parameter_entities, name);
        if ($2 instanceof Ok) {
          let replacement = $2[0];
          return $result.try$(
            expand_parameter_references(rest, state, allowed),
            (rest) => { return new Ok((before + replacement) + rest); },
          );
        } else {
          return new Error(new UnknownEntity(name));
        }
      } else {
        return new Error(new MalformedEntity());
      }
    } else {
      return new Error(new MalformedDoctype());
    }
  } else {
    return new Ok(text);
  }
}

/**
 * Parse a quoted entity value, which must close within the entity it
 * opened in. Parameter entity references and character references are
 * expanded now, at declaration time; general entity references are kept
 * for expansion when the entity is used.
 * 
 * @ignore
 */
function parse_entity_value(input, state, quote) {
  let $ = scan_to_byte(input.current, 0, quote);
  if ($ instanceof Ok) {
    let count = $[0][0];
    let rest = $[0][1];
    let _block;
    let _pipe = take_string(input.current, count);
    let _pipe$1 = expand_parameter_references(
      _pipe,
      state,
      may_expand_here(input, state),
    );
    _block = $result.try$(_pipe$1, expand_character_references);
    let processed = _block;
    if (processed instanceof Ok) {
      let replacement = processed[0];
      return new Ok(
        [new InternalEntity(replacement), advance(input, rest), state],
      );
    } else {
      let kind = processed[0];
      return new Error([kind, dtd_position(input)]);
    }
  } else {
    let kind = $[0][0];
    return new Error([kind, dtd_position(input)]);
  }
}

function parse_entity_definition(input, state, declared_in) {
  let $ = input.current;
  if ($.bitSize >= 8) {
    if ($.byteAt(0) === 34) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 8);
        return parse_entity_value(advance(input, rest), state, double_quote);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if ($.byteAt(0) === 39) {
      if ($.bitSize % 8 === 0) {
        let rest = bitArraySlice($, 8);
        return parse_entity_value(advance(input, rest), state, single_quote);
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else if ($.bitSize >= 48) {
      if (
        $.byteAt(0) === 83 &&
          $.byteAt(1) === 89 &&
          $.byteAt(2) === 83 &&
          $.byteAt(3) === 84 &&
          $.byteAt(4) === 69 &&
          $.byteAt(5) === 77
      ) {
        if ($.bitSize % 8 === 0) {
          return $result.try$(
            parse_external_id_in_dtd(input, state, true),
            (_use0) => {
              let id = _use0[0];
              let input$1 = _use0[1];
              let state$1 = _use0[2];
              let $1 = skip_whitespace(input$1.current);
              if (
                $1.bitSize >= 40 &&
                $1.byteAt(0) === 78 &&
                  $1.byteAt(1) === 68 &&
                  $1.byteAt(2) === 65 &&
                  $1.byteAt(3) === 84 &&
                  $1.byteAt(4) === 65 &&
                $1.bitSize % 8 === 0
              ) {
                let ndata_rest = bitArraySlice($1, 40);
                let $2 = $bit_array.byte_size(skip_whitespace(input$1.current)) < $bit_array.byte_size(
                  input$1.current,
                );
                if ($2) {
                  let input$2 = advance(input$1, ndata_rest);
                  return $result.try$(
                    require_dtd_space(
                      input$2,
                      state$1,
                      may_expand_here(input$2, state$1),
                    ),
                    (_use0) => {
                      let input$3 = _use0[0];
                      let state$2 = _use0[1];
                      return $result.try$(
                        dtd_name(input$3),
                        (_use0) => {
                          let notation = _use0[0];
                          let rest = _use0[1];
                          return new Ok(
                            [
                              new ExternalEntity(
                                id,
                                new Some(notation),
                                declared_in,
                              ),
                              advance(input$3, rest),
                              state$2,
                            ],
                          );
                        },
                      );
                    },
                  );
                } else {
                  return new Error(
                    [new MissingWhitespace(), dtd_position(input$1)],
                  );
                }
              } else {
                return new Ok(
                  [
                    new ExternalEntity(id, new None(), declared_in),
                    input$1,
                    state$1,
                  ],
                );
              }
            },
          );
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input)]);
        }
      } else if (
        $.byteAt(0) === 80 &&
          $.byteAt(1) === 85 &&
          $.byteAt(2) === 66 &&
          $.byteAt(3) === 76 &&
          $.byteAt(4) === 73 &&
          $.byteAt(5) === 67 &&
        $.bitSize % 8 === 0
      ) {
        return $result.try$(
          parse_external_id_in_dtd(input, state, true),
          (_use0) => {
            let id = _use0[0];
            let input$1 = _use0[1];
            let state$1 = _use0[2];
            let $1 = skip_whitespace(input$1.current);
            if (
              $1.bitSize >= 40 &&
              $1.byteAt(0) === 78 &&
                $1.byteAt(1) === 68 &&
                $1.byteAt(2) === 65 &&
                $1.byteAt(3) === 84 &&
                $1.byteAt(4) === 65 &&
              $1.bitSize % 8 === 0
            ) {
              let ndata_rest = bitArraySlice($1, 40);
              let $2 = $bit_array.byte_size(skip_whitespace(input$1.current)) < $bit_array.byte_size(
                input$1.current,
              );
              if ($2) {
                let input$2 = advance(input$1, ndata_rest);
                return $result.try$(
                  require_dtd_space(
                    input$2,
                    state$1,
                    may_expand_here(input$2, state$1),
                  ),
                  (_use0) => {
                    let input$3 = _use0[0];
                    let state$2 = _use0[1];
                    return $result.try$(
                      dtd_name(input$3),
                      (_use0) => {
                        let notation = _use0[0];
                        let rest = _use0[1];
                        return new Ok(
                          [
                            new ExternalEntity(
                              id,
                              new Some(notation),
                              declared_in,
                            ),
                            advance(input$3, rest),
                            state$2,
                          ],
                        );
                      },
                    );
                  },
                );
              } else {
                return new Error(
                  [new MissingWhitespace(), dtd_position(input$1)],
                );
              }
            } else {
              return new Ok(
                [
                  new ExternalEntity(id, new None(), declared_in),
                  input$1,
                  state$1,
                ],
              );
            }
          },
        );
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input)]);
      }
    } else {
      return new Error([new MalformedDoctype(), dtd_position(input)]);
    }
  } else {
    return new Error([new MalformedDoctype(), dtd_position(input)]);
  }
}

/**
 * The external parameter entity whose replacement text the parser is
 * currently reading, skipping internally declared parameter entities,
 * whose text belongs to wherever they are referenced.
 * 
 * @ignore
 */
function declaring_entity(loop$input, loop$state) {
  while (true) {
    let input = loop$input;
    let state = loop$state;
    let $ = input.entity;
    if ($ instanceof Some) {
      let name = $[0];
      let $1 = $dict.has_key(state.internal_parameter_entities, name);
      if ($1) {
        let $2 = input.parent;
        if ($2 instanceof Some) {
          let parent = $2[0];
          loop$input = parent;
          loop$state = state;
        } else {
          return $2;
        }
      } else {
        return new Some(name);
      }
    } else {
      return $;
    }
  }
}

/**
 * Parse an `<!ENTITY ...>` declaration. The first declaration of a name is
 * binding; later ones are ignored, as the specification requires.
 * 
 * @ignore
 */
function parse_entity_declaration(input, state, opened_in) {
  let declared_in = declaring_entity(input, state);
  return $result.try$(
    require_dtd_space(input, state, false),
    (_use0) => {
      let input$1 = _use0[0];
      let state$1 = _use0[1];
      let $ = input$1.current;
      if ($.bitSize >= 16) {
        if ($.byteAt(0) === 37 && $.byteAt(1) === 32) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 16);
            return $result.try$(
              skip_dtd_space(advance(input$1, rest), state$1, false),
              (_use0) => {
                let input$2 = _use0[0];
                let state$2 = _use0[1];
                return $result.try$(
                  dtd_name(input$2),
                  (_use0) => {
                    let name = _use0[0];
                    let rest$1 = _use0[1];
                    let input$3 = advance(input$2, rest$1);
                    return $result.try$(
                      require_dtd_space(
                        input$3,
                        state$2,
                        may_expand_here(input$3, state$2),
                      ),
                      (_use0) => {
                        let input$4 = _use0[0];
                        let state$3 = _use0[1];
                        return $result.try$(
                          parse_entity_definition(input$4, state$3, declared_in),
                          (_use0) => {
                            let entity = _use0[0];
                            let input$5 = _use0[1];
                            let state$4 = _use0[2];
                            return require(
                              (() => {
                                if (entity instanceof ExternalEntity) {
                                  let $1 = entity.notation;
                                  if ($1 instanceof Some) {
                                    return false;
                                  } else {
                                    return true;
                                  }
                                } else {
                                  return true;
                                }
                              })(),
                              [new MalformedDoctype(), dtd_position(input$5)],
                              () => {
                                return $result.try$(
                                  close_declaration(input$5, state$4, opened_in),
                                  (_use0) => {
                                    let input$6 = _use0[0];
                                    let state$5 = _use0[1];
                                    let dtd = state$5.dtd;
                                    let _block;
                                    if (entity instanceof InternalEntity) {
                                      let replacement = entity.replacement;
                                      let $1 = $dict.has_key(
                                        dtd.parameter_entities,
                                        name,
                                      );
                                      if ($1) {
                                        _block = state$5;
                                      } else {
                                        _block = new DtdState(
                                          new Dtd(
                                            dtd.elements,
                                            dtd.attribute_lists,
                                            dtd.entities,
                                            $dict.insert(
                                              dtd.parameter_entities,
                                              name,
                                              replacement,
                                            ),
                                            dtd.notations,
                                            dtd.duplicate_elements,
                                            dtd.pe_nesting_violations,
                                          ),
                                          state$5.external,
                                          state$5.next_id,
                                          state$5.pe_used,
                                          $dict.insert(
                                            state$5.internal_parameter_entities,
                                            name,
                                            undefined,
                                          ),
                                        );
                                      }
                                    } else {
                                      _block = state$5;
                                    }
                                    let state$6 = _block;
                                    return new Ok([input$6, state$6]);
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            return $result.try$(
              skip_dtd_space(
                input$1,
                state$1,
                may_expand_here(input$1, state$1),
              ),
              (_use0) => {
                let input$2 = _use0[0];
                let state$2 = _use0[1];
                return $result.try$(
                  dtd_name(input$2),
                  (_use0) => {
                    let name = _use0[0];
                    let rest = _use0[1];
                    let input$3 = advance(input$2, rest);
                    return $result.try$(
                      require_dtd_space(
                        input$3,
                        state$2,
                        may_expand_here(input$3, state$2),
                      ),
                      (_use0) => {
                        let input$4 = _use0[0];
                        let state$3 = _use0[1];
                        return $result.try$(
                          parse_entity_definition(input$4, state$3, declared_in),
                          (_use0) => {
                            let entity = _use0[0];
                            let input$5 = _use0[1];
                            let state$4 = _use0[2];
                            return $result.try$(
                              close_declaration(input$5, state$4, opened_in),
                              (_use0) => {
                                let input$6 = _use0[0];
                                let state$5 = _use0[1];
                                let dtd = state$5.dtd;
                                let _block;
                                let $1 = $dict.has_key(dtd.entities, name);
                                if ($1) {
                                  _block = state$5;
                                } else {
                                  _block = new DtdState(
                                    new Dtd(
                                      dtd.elements,
                                      dtd.attribute_lists,
                                      $dict.insert(dtd.entities, name, entity),
                                      dtd.parameter_entities,
                                      dtd.notations,
                                      dtd.duplicate_elements,
                                      dtd.pe_nesting_violations,
                                    ),
                                    state$5.external,
                                    state$5.next_id,
                                    state$5.pe_used,
                                    state$5.internal_parameter_entities,
                                  );
                                }
                                let state$6 = _block;
                                return new Ok([input$6, state$6]);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        } else if ($.byteAt(0) === 37 && $.byteAt(1) === 9) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 16);
            return $result.try$(
              skip_dtd_space(advance(input$1, rest), state$1, false),
              (_use0) => {
                let input$2 = _use0[0];
                let state$2 = _use0[1];
                return $result.try$(
                  dtd_name(input$2),
                  (_use0) => {
                    let name = _use0[0];
                    let rest$1 = _use0[1];
                    let input$3 = advance(input$2, rest$1);
                    return $result.try$(
                      require_dtd_space(
                        input$3,
                        state$2,
                        may_expand_here(input$3, state$2),
                      ),
                      (_use0) => {
                        let input$4 = _use0[0];
                        let state$3 = _use0[1];
                        return $result.try$(
                          parse_entity_definition(input$4, state$3, declared_in),
                          (_use0) => {
                            let entity = _use0[0];
                            let input$5 = _use0[1];
                            let state$4 = _use0[2];
                            return require(
                              (() => {
                                if (entity instanceof ExternalEntity) {
                                  let $1 = entity.notation;
                                  if ($1 instanceof Some) {
                                    return false;
                                  } else {
                                    return true;
                                  }
                                } else {
                                  return true;
                                }
                              })(),
                              [new MalformedDoctype(), dtd_position(input$5)],
                              () => {
                                return $result.try$(
                                  close_declaration(input$5, state$4, opened_in),
                                  (_use0) => {
                                    let input$6 = _use0[0];
                                    let state$5 = _use0[1];
                                    let dtd = state$5.dtd;
                                    let _block;
                                    if (entity instanceof InternalEntity) {
                                      let replacement = entity.replacement;
                                      let $1 = $dict.has_key(
                                        dtd.parameter_entities,
                                        name,
                                      );
                                      if ($1) {
                                        _block = state$5;
                                      } else {
                                        _block = new DtdState(
                                          new Dtd(
                                            dtd.elements,
                                            dtd.attribute_lists,
                                            dtd.entities,
                                            $dict.insert(
                                              dtd.parameter_entities,
                                              name,
                                              replacement,
                                            ),
                                            dtd.notations,
                                            dtd.duplicate_elements,
                                            dtd.pe_nesting_violations,
                                          ),
                                          state$5.external,
                                          state$5.next_id,
                                          state$5.pe_used,
                                          $dict.insert(
                                            state$5.internal_parameter_entities,
                                            name,
                                            undefined,
                                          ),
                                        );
                                      }
                                    } else {
                                      _block = state$5;
                                    }
                                    let state$6 = _block;
                                    return new Ok([input$6, state$6]);
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            return $result.try$(
              skip_dtd_space(
                input$1,
                state$1,
                may_expand_here(input$1, state$1),
              ),
              (_use0) => {
                let input$2 = _use0[0];
                let state$2 = _use0[1];
                return $result.try$(
                  dtd_name(input$2),
                  (_use0) => {
                    let name = _use0[0];
                    let rest = _use0[1];
                    let input$3 = advance(input$2, rest);
                    return $result.try$(
                      require_dtd_space(
                        input$3,
                        state$2,
                        may_expand_here(input$3, state$2),
                      ),
                      (_use0) => {
                        let input$4 = _use0[0];
                        let state$3 = _use0[1];
                        return $result.try$(
                          parse_entity_definition(input$4, state$3, declared_in),
                          (_use0) => {
                            let entity = _use0[0];
                            let input$5 = _use0[1];
                            let state$4 = _use0[2];
                            return $result.try$(
                              close_declaration(input$5, state$4, opened_in),
                              (_use0) => {
                                let input$6 = _use0[0];
                                let state$5 = _use0[1];
                                let dtd = state$5.dtd;
                                let _block;
                                let $1 = $dict.has_key(dtd.entities, name);
                                if ($1) {
                                  _block = state$5;
                                } else {
                                  _block = new DtdState(
                                    new Dtd(
                                      dtd.elements,
                                      dtd.attribute_lists,
                                      $dict.insert(dtd.entities, name, entity),
                                      dtd.parameter_entities,
                                      dtd.notations,
                                      dtd.duplicate_elements,
                                      dtd.pe_nesting_violations,
                                    ),
                                    state$5.external,
                                    state$5.next_id,
                                    state$5.pe_used,
                                    state$5.internal_parameter_entities,
                                  );
                                }
                                let state$6 = _block;
                                return new Ok([input$6, state$6]);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        } else if (
          $.byteAt(0) === 37 && $.byteAt(1) === 10 &&
          $.bitSize % 8 === 0
        ) {
          let rest = bitArraySlice($, 16);
          return $result.try$(
            skip_dtd_space(advance(input$1, rest), state$1, false),
            (_use0) => {
              let input$2 = _use0[0];
              let state$2 = _use0[1];
              return $result.try$(
                dtd_name(input$2),
                (_use0) => {
                  let name = _use0[0];
                  let rest$1 = _use0[1];
                  let input$3 = advance(input$2, rest$1);
                  return $result.try$(
                    require_dtd_space(
                      input$3,
                      state$2,
                      may_expand_here(input$3, state$2),
                    ),
                    (_use0) => {
                      let input$4 = _use0[0];
                      let state$3 = _use0[1];
                      return $result.try$(
                        parse_entity_definition(input$4, state$3, declared_in),
                        (_use0) => {
                          let entity = _use0[0];
                          let input$5 = _use0[1];
                          let state$4 = _use0[2];
                          return require(
                            (() => {
                              if (entity instanceof ExternalEntity) {
                                let $1 = entity.notation;
                                if ($1 instanceof Some) {
                                  return false;
                                } else {
                                  return true;
                                }
                              } else {
                                return true;
                              }
                            })(),
                            [new MalformedDoctype(), dtd_position(input$5)],
                            () => {
                              return $result.try$(
                                close_declaration(input$5, state$4, opened_in),
                                (_use0) => {
                                  let input$6 = _use0[0];
                                  let state$5 = _use0[1];
                                  let dtd = state$5.dtd;
                                  let _block;
                                  if (entity instanceof InternalEntity) {
                                    let replacement = entity.replacement;
                                    let $1 = $dict.has_key(
                                      dtd.parameter_entities,
                                      name,
                                    );
                                    if ($1) {
                                      _block = state$5;
                                    } else {
                                      _block = new DtdState(
                                        new Dtd(
                                          dtd.elements,
                                          dtd.attribute_lists,
                                          dtd.entities,
                                          $dict.insert(
                                            dtd.parameter_entities,
                                            name,
                                            replacement,
                                          ),
                                          dtd.notations,
                                          dtd.duplicate_elements,
                                          dtd.pe_nesting_violations,
                                        ),
                                        state$5.external,
                                        state$5.next_id,
                                        state$5.pe_used,
                                        $dict.insert(
                                          state$5.internal_parameter_entities,
                                          name,
                                          undefined,
                                        ),
                                      );
                                    }
                                  } else {
                                    _block = state$5;
                                  }
                                  let state$6 = _block;
                                  return new Ok([input$6, state$6]);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        } else {
          return $result.try$(
            skip_dtd_space(input$1, state$1, may_expand_here(input$1, state$1)),
            (_use0) => {
              let input$2 = _use0[0];
              let state$2 = _use0[1];
              return $result.try$(
                dtd_name(input$2),
                (_use0) => {
                  let name = _use0[0];
                  let rest = _use0[1];
                  let input$3 = advance(input$2, rest);
                  return $result.try$(
                    require_dtd_space(
                      input$3,
                      state$2,
                      may_expand_here(input$3, state$2),
                    ),
                    (_use0) => {
                      let input$4 = _use0[0];
                      let state$3 = _use0[1];
                      return $result.try$(
                        parse_entity_definition(input$4, state$3, declared_in),
                        (_use0) => {
                          let entity = _use0[0];
                          let input$5 = _use0[1];
                          let state$4 = _use0[2];
                          return $result.try$(
                            close_declaration(input$5, state$4, opened_in),
                            (_use0) => {
                              let input$6 = _use0[0];
                              let state$5 = _use0[1];
                              let dtd = state$5.dtd;
                              let _block;
                              let $1 = $dict.has_key(dtd.entities, name);
                              if ($1) {
                                _block = state$5;
                              } else {
                                _block = new DtdState(
                                  new Dtd(
                                    dtd.elements,
                                    dtd.attribute_lists,
                                    $dict.insert(dtd.entities, name, entity),
                                    dtd.parameter_entities,
                                    dtd.notations,
                                    dtd.duplicate_elements,
                                    dtd.pe_nesting_violations,
                                  ),
                                  state$5.external,
                                  state$5.next_id,
                                  state$5.pe_used,
                                  state$5.internal_parameter_entities,
                                );
                              }
                              let state$6 = _block;
                              return new Ok([input$6, state$6]);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        }
      } else {
        return $result.try$(
          skip_dtd_space(input$1, state$1, may_expand_here(input$1, state$1)),
          (_use0) => {
            let input$2 = _use0[0];
            let state$2 = _use0[1];
            return $result.try$(
              dtd_name(input$2),
              (_use0) => {
                let name = _use0[0];
                let rest = _use0[1];
                let input$3 = advance(input$2, rest);
                return $result.try$(
                  require_dtd_space(
                    input$3,
                    state$2,
                    may_expand_here(input$3, state$2),
                  ),
                  (_use0) => {
                    let input$4 = _use0[0];
                    let state$3 = _use0[1];
                    return $result.try$(
                      parse_entity_definition(input$4, state$3, declared_in),
                      (_use0) => {
                        let entity = _use0[0];
                        let input$5 = _use0[1];
                        let state$4 = _use0[2];
                        return $result.try$(
                          close_declaration(input$5, state$4, opened_in),
                          (_use0) => {
                            let input$6 = _use0[0];
                            let state$5 = _use0[1];
                            let dtd = state$5.dtd;
                            let _block;
                            let $1 = $dict.has_key(dtd.entities, name);
                            if ($1) {
                              _block = state$5;
                            } else {
                              _block = new DtdState(
                                new Dtd(
                                  dtd.elements,
                                  dtd.attribute_lists,
                                  $dict.insert(dtd.entities, name, entity),
                                  dtd.parameter_entities,
                                  dtd.notations,
                                  dtd.duplicate_elements,
                                  dtd.pe_nesting_violations,
                                ),
                                state$5.external,
                                state$5.next_id,
                                state$5.pe_used,
                                state$5.internal_parameter_entities,
                              );
                            }
                            let state$6 = _block;
                            return new Ok([input$6, state$6]);
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      }
    },
  );
}

/**
 * Skip an IGNORE section body up to its matching `]]>`, which must lie in
 * the same entity (the section's content is not parsed, so segments are
 * never pushed here).
 * 
 * @ignore
 */
function skip_ignore_section(loop$input, loop$depth) {
  while (true) {
    let input = loop$input;
    let depth = loop$depth;
    if (input.bitSize >= 24) {
      if (
        input.byteAt(0) === 93 &&
          input.byteAt(1) === 93 &&
          input.byteAt(2) === 62
      ) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 24);
          if (depth === 0) {
            return new Ok(rest);
          } else {
            loop$input = rest;
            loop$depth = depth - 1;
          }
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (
        input.byteAt(0) === 60 &&
          input.byteAt(1) === 33 &&
          input.byteAt(2) === 91
      ) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 24);
          loop$input = rest;
          loop$depth = depth + 1;
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if (input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        loop$input = rest;
        loop$depth = depth;
      } else {
        return new Error([new UnexpectedEndOfInput(), 0]);
      }
    } else if (input.bitSize >= 8 && input.bitSize % 8 === 0) {
      let rest = bitArraySlice(input, 8);
      loop$input = rest;
      loop$depth = depth;
    } else {
      return new Error([new UnexpectedEndOfInput(), 0]);
    }
  }
}

/**
 * Handle `INCLUDE [` or `IGNORE [` after `<![`. Returns `True` when an
 * INCLUDE section was opened. The `[` must be in the same entity as the
 * `<![`.
 * 
 * @ignore
 */
function parse_conditional_start(input, state, opened_in) {
  return $result.try$(
    skip_dtd_space(input, state, true),
    (_use0) => {
      let input$1 = _use0[0];
      let state$1 = _use0[1];
      let $ = input$1.current;
      if ($.bitSize >= 56) {
        if (
          $.byteAt(0) === 73 &&
            $.byteAt(1) === 78 &&
            $.byteAt(2) === 67 &&
            $.byteAt(3) === 76 &&
            $.byteAt(4) === 85 &&
            $.byteAt(5) === 68 &&
            $.byteAt(6) === 69
        ) {
          if ($.bitSize % 8 === 0) {
            let rest = bitArraySlice($, 56);
            let $1 = skip_dtd_space(advance(input$1, rest), state$1, true);
            if ($1 instanceof Ok) {
              let input$2 = $1[0][0];
              let state$2 = $1[0][1];
              let $2 = input$2.current;
              if ($2.bitSize >= 8 && $2.byteAt(0) === 91 && $2.bitSize % 8 === 0) {
                let rest$1 = bitArraySlice($2, 8);
                let $3 = check_same_segment(
                  input$2,
                  state$2,
                  opened_in,
                  "a conditional section",
                );
                if ($3 instanceof Ok) {
                  let state$3 = $3[0];
                  return new Ok([true, advance(input$2, rest$1), state$3]);
                } else {
                  return $3;
                }
              } else {
                return new Error(
                  [new MalformedDoctype(), dtd_position(input$2)],
                );
              }
            } else {
              return $1;
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if (
          $.byteAt(0) === 73 &&
            $.byteAt(1) === 71 &&
            $.byteAt(2) === 78 &&
            $.byteAt(3) === 79 &&
            $.byteAt(4) === 82 &&
            $.byteAt(5) === 69 &&
          $.bitSize % 8 === 0
        ) {
          let rest = bitArraySlice($, 48);
          let $1 = skip_dtd_space(advance(input$1, rest), state$1, true);
          if ($1 instanceof Ok) {
            let input$2 = $1[0][0];
            let state$2 = $1[0][1];
            let $2 = input$2.current;
            if ($2.bitSize >= 8 && $2.byteAt(0) === 91 && $2.bitSize % 8 === 0) {
              let rest$1 = bitArraySlice($2, 8);
              let $3 = check_same_segment(
                input$2,
                state$2,
                opened_in,
                "a conditional section",
              );
              if ($3 instanceof Ok) {
                let state$3 = $3[0];
                let $4 = skip_ignore_section(rest$1, 0);
                if ($4 instanceof Ok) {
                  let rest$2 = $4[0];
                  return new Ok([false, advance(input$2, rest$2), state$3]);
                } else {
                  return $4;
                }
              } else {
                return $3;
              }
            } else {
              return new Error([new MalformedDoctype(), dtd_position(input$2)]);
            }
          } else {
            return $1;
          }
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input$1)]);
        }
      } else if (
        $.bitSize >= 48 &&
        $.byteAt(0) === 73 &&
          $.byteAt(1) === 71 &&
          $.byteAt(2) === 78 &&
          $.byteAt(3) === 79 &&
          $.byteAt(4) === 82 &&
          $.byteAt(5) === 69 &&
        $.bitSize % 8 === 0
      ) {
        let rest = bitArraySlice($, 48);
        let $1 = skip_dtd_space(advance(input$1, rest), state$1, true);
        if ($1 instanceof Ok) {
          let input$2 = $1[0][0];
          let state$2 = $1[0][1];
          let $2 = input$2.current;
          if ($2.bitSize >= 8 && $2.byteAt(0) === 91 && $2.bitSize % 8 === 0) {
            let rest$1 = bitArraySlice($2, 8);
            let $3 = check_same_segment(
              input$2,
              state$2,
              opened_in,
              "a conditional section",
            );
            if ($3 instanceof Ok) {
              let state$3 = $3[0];
              let $4 = skip_ignore_section(rest$1, 0);
              if ($4 instanceof Ok) {
                let rest$2 = $4[0];
                return new Ok([false, advance(input$2, rest$2), state$3]);
              } else {
                return $4;
              }
            } else {
              return $3;
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$2)]);
          }
        } else {
          return $1;
        }
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input$1)]);
      }
    },
  );
}

/**
 * The between-declarations variant: references expanded here must hold
 * complete declarations.
 * 
 * @ignore
 */
function skip_declaration_separators(input, state) {
  return do_skip_dtd_space(input, state, true, true);
}

function continue_declaration(result, kind, conditionals) {
  if (result instanceof Ok) {
    let input = result[0][0];
    let state = result[0][1];
    return parse_dtd_declarations(input, state, kind, conditionals);
  } else {
    return result;
  }
}

/**
 * Parse the declarations of a DTD subset. An internal subset ends at `]`
 * in the outermost segment, an external one at the end of input.
 * `conditionals` holds the segment ids of the open `<![INCLUDE[`
 * sections.
 * 
 * @ignore
 */
function parse_dtd_declarations(
  loop$input,
  loop$state,
  loop$kind,
  loop$conditionals
) {
  while (true) {
    let input = loop$input;
    let state = loop$state;
    let kind = loop$kind;
    let conditionals = loop$conditionals;
    let $ = skip_declaration_separators(input, state);
    if ($ instanceof Ok) {
      let input$1 = $[0][0];
      let state$1 = $[0][1];
      let $1 = input$1.current;
      if ($1.bitSize === 0) {
        if (kind instanceof ExternalSubset && conditionals instanceof $Empty) {
          return new Ok([state$1, input$1.current]);
        } else {
          return new Error([new UnexpectedEndOfInput(), 0]);
        }
      } else if ($1.bitSize >= 24) {
        if ($1.byteAt(0) === 93 && $1.byteAt(1) === 93 && $1.byteAt(2) === 62) {
          if ($1.bitSize % 8 === 0) {
            let rest = bitArraySlice($1, 24);
            if (conditionals instanceof $Empty) {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            } else {
              let opened_in = conditionals.head;
              let conditionals$1 = conditionals.tail;
              let $2 = check_same_segment(
                input$1,
                state$1,
                opened_in,
                "a conditional section",
              );
              if ($2 instanceof Ok) {
                let state$2 = $2[0];
                loop$input = advance(input$1, rest);
                loop$state = state$2;
                loop$kind = kind;
                loop$conditionals = conditionals$1;
              } else {
                return $2;
              }
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if ($1.byteAt(0) === 93) {
          if ($1.bitSize % 8 === 0) {
            let rest = bitArraySlice($1, 8);
            let $2 = input$1.parent;
            if (
              kind instanceof InternalSubset &&
              conditionals instanceof $Empty &&
              $2 instanceof None
            ) {
              return new Ok([state$1, rest]);
            } else {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if ($1.bitSize >= 32) {
          if (
            $1.byteAt(0) === 60 &&
              $1.byteAt(1) === 33 &&
              $1.byteAt(2) === 45 &&
              $1.byteAt(3) === 45
          ) {
            if ($1.bitSize % 8 === 0) {
              let rest = bitArraySlice($1, 32);
              let $2 = parse_comment(rest);
              if ($2 instanceof Ok) {
                let rest$1 = $2[0][1];
                loop$input = advance(input$1, rest$1);
                loop$state = state$1;
                loop$kind = kind;
                loop$conditionals = conditionals;
              } else {
                return $2;
              }
            } else {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            }
          } else if ($1.byteAt(0) === 60 && $1.byteAt(1) === 63) {
            if ($1.bitSize % 8 === 0) {
              let rest = bitArraySlice($1, 16);
              let $2 = parse_processing_instruction(rest);
              if ($2 instanceof Ok) {
                let rest$1 = $2[0][1];
                loop$input = advance(input$1, rest$1);
                loop$state = state$1;
                loop$kind = kind;
                loop$conditionals = conditionals;
              } else {
                return $2;
              }
            } else {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            }
          } else if (
            $1.byteAt(0) === 60 && $1.byteAt(1) === 33 && $1.byteAt(2) === 91
          ) {
            if ($1.bitSize % 8 === 0) {
              let rest = bitArraySlice($1, 24);
              let $2 = state$1.external || $option.is_some(input$1.parent);
              if ($2) {
                let opened_in = input$1.id;
                let $3 = parse_conditional_start(
                  advance(input$1, rest),
                  state$1,
                  opened_in,
                );
                if ($3 instanceof Ok) {
                  let $4 = $3[0][0];
                  if ($4) {
                    let input$2 = $3[0][1];
                    let state$2 = $3[0][2];
                    loop$input = input$2;
                    loop$state = state$2;
                    loop$kind = kind;
                    loop$conditionals = listPrepend(opened_in, conditionals);
                  } else {
                    let input$2 = $3[0][1];
                    let state$2 = $3[0][2];
                    loop$input = input$2;
                    loop$state = state$2;
                    loop$kind = kind;
                    loop$conditionals = conditionals;
                  }
                } else {
                  return $3;
                }
              } else {
                return new Error(
                  [new MalformedDoctype(), dtd_position(input$1)],
                );
              }
            } else {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            }
          } else if ($1.bitSize >= 64) {
            if (
              $1.byteAt(0) === 60 &&
                $1.byteAt(1) === 33 &&
                $1.byteAt(2) === 69 &&
                $1.byteAt(3) === 78 &&
                $1.byteAt(4) === 84 &&
                $1.byteAt(5) === 73 &&
                $1.byteAt(6) === 84 &&
                $1.byteAt(7) === 89
            ) {
              if ($1.bitSize % 8 === 0) {
                let rest = bitArraySlice($1, 64);
                return continue_declaration(
                  parse_entity_declaration(
                    advance(input$1, rest),
                    state$1,
                    input$1.id,
                  ),
                  kind,
                  conditionals,
                );
              } else {
                return new Error(
                  [new MalformedDoctype(), dtd_position(input$1)],
                );
              }
            } else if ($1.bitSize >= 72) {
              if (
                $1.byteAt(0) === 60 &&
                  $1.byteAt(1) === 33 &&
                  $1.byteAt(2) === 69 &&
                  $1.byteAt(3) === 76 &&
                  $1.byteAt(4) === 69 &&
                  $1.byteAt(5) === 77 &&
                  $1.byteAt(6) === 69 &&
                  $1.byteAt(7) === 78 &&
                  $1.byteAt(8) === 84
              ) {
                if ($1.bitSize % 8 === 0) {
                  let rest = bitArraySlice($1, 72);
                  return continue_declaration(
                    parse_element_declaration(
                      advance(input$1, rest),
                      state$1,
                      input$1.id,
                    ),
                    kind,
                    conditionals,
                  );
                } else {
                  return new Error(
                    [new MalformedDoctype(), dtd_position(input$1)],
                  );
                }
              } else if (
                $1.byteAt(0) === 60 &&
                  $1.byteAt(1) === 33 &&
                  $1.byteAt(2) === 65 &&
                  $1.byteAt(3) === 84 &&
                  $1.byteAt(4) === 84 &&
                  $1.byteAt(5) === 76 &&
                  $1.byteAt(6) === 73 &&
                  $1.byteAt(7) === 83 &&
                  $1.byteAt(8) === 84
              ) {
                if ($1.bitSize % 8 === 0) {
                  let rest = bitArraySlice($1, 72);
                  return continue_declaration(
                    parse_attlist_declaration(
                      advance(input$1, rest),
                      state$1,
                      input$1.id,
                    ),
                    kind,
                    conditionals,
                  );
                } else {
                  return new Error(
                    [new MalformedDoctype(), dtd_position(input$1)],
                  );
                }
              } else if (
                $1.bitSize >= 80 &&
                $1.byteAt(0) === 60 &&
                  $1.byteAt(1) === 33 &&
                  $1.byteAt(2) === 78 &&
                  $1.byteAt(3) === 79 &&
                  $1.byteAt(4) === 84 &&
                  $1.byteAt(5) === 65 &&
                  $1.byteAt(6) === 84 &&
                  $1.byteAt(7) === 73 &&
                  $1.byteAt(8) === 79 &&
                  $1.byteAt(9) === 78 &&
                $1.bitSize % 8 === 0
              ) {
                let rest = bitArraySlice($1, 80);
                return continue_declaration(
                  parse_notation_declaration(
                    advance(input$1, rest),
                    state$1,
                    input$1.id,
                  ),
                  kind,
                  conditionals,
                );
              } else {
                return new Error(
                  [new MalformedDoctype(), dtd_position(input$1)],
                );
              }
            } else {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if ($1.byteAt(0) === 60 && $1.byteAt(1) === 63) {
          if ($1.bitSize % 8 === 0) {
            let rest = bitArraySlice($1, 16);
            let $2 = parse_processing_instruction(rest);
            if ($2 instanceof Ok) {
              let rest$1 = $2[0][1];
              loop$input = advance(input$1, rest$1);
              loop$state = state$1;
              loop$kind = kind;
              loop$conditionals = conditionals;
            } else {
              return $2;
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if (
          $1.byteAt(0) === 60 && $1.byteAt(1) === 33 && $1.byteAt(2) === 91 &&
          $1.bitSize % 8 === 0
        ) {
          let rest = bitArraySlice($1, 24);
          let $2 = state$1.external || $option.is_some(input$1.parent);
          if ($2) {
            let opened_in = input$1.id;
            let $3 = parse_conditional_start(
              advance(input$1, rest),
              state$1,
              opened_in,
            );
            if ($3 instanceof Ok) {
              let $4 = $3[0][0];
              if ($4) {
                let input$2 = $3[0][1];
                let state$2 = $3[0][2];
                loop$input = input$2;
                loop$state = state$2;
                loop$kind = kind;
                loop$conditionals = listPrepend(opened_in, conditionals);
              } else {
                let input$2 = $3[0][1];
                let state$2 = $3[0][2];
                loop$input = input$2;
                loop$state = state$2;
                loop$kind = kind;
                loop$conditionals = conditionals;
              }
            } else {
              return $3;
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input$1)]);
        }
      } else if ($1.bitSize >= 8) {
        if ($1.byteAt(0) === 93) {
          if ($1.bitSize % 8 === 0) {
            let rest = bitArraySlice($1, 8);
            let $2 = input$1.parent;
            if (
              kind instanceof InternalSubset &&
              conditionals instanceof $Empty &&
              $2 instanceof None
            ) {
              return new Ok([state$1, rest]);
            } else {
              return new Error([new MalformedDoctype(), dtd_position(input$1)]);
            }
          } else {
            return new Error([new MalformedDoctype(), dtd_position(input$1)]);
          }
        } else if (
          $1.bitSize >= 16 &&
          $1.byteAt(0) === 60 && $1.byteAt(1) === 63 &&
          $1.bitSize % 8 === 0
        ) {
          let rest = bitArraySlice($1, 16);
          let $2 = parse_processing_instruction(rest);
          if ($2 instanceof Ok) {
            let rest$1 = $2[0][1];
            loop$input = advance(input$1, rest$1);
            loop$state = state$1;
            loop$kind = kind;
            loop$conditionals = conditionals;
          } else {
            return $2;
          }
        } else {
          return new Error([new MalformedDoctype(), dtd_position(input$1)]);
        }
      } else {
        return new Error([new MalformedDoctype(), dtd_position(input$1)]);
      }
    } else {
      return $;
    }
  }
}

function require_whitespace(input) {
  let stripped = skip_whitespace(input);
  let $ = $bit_array.byte_size(stripped) < $bit_array.byte_size(input);
  if ($) {
    return new Ok(stripped);
  } else {
    return new Error([new MissingWhitespace(), $bit_array.byte_size(input)]);
  }
}

/**
 * Parse a SYSTEM or PUBLIC identifier. A system literal is required after
 * a public one everywhere except in notation declarations.
 * 
 * @ignore
 */
function parse_external_id(input, require_system) {
  if (input.bitSize >= 48) {
    if (
      input.byteAt(0) === 83 &&
        input.byteAt(1) === 89 &&
        input.byteAt(2) === 83 &&
        input.byteAt(3) === 84 &&
        input.byteAt(4) === 69 &&
        input.byteAt(5) === 77
    ) {
      if (input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 48);
        return $result.try$(
          require_whitespace(rest),
          (rest) => {
            return $result.try$(
              parse_quoted_literal(rest),
              (_use0) => {
                let system = _use0[0];
                let rest$1 = _use0[1];
                return new Ok([new System(system), rest$1]);
              },
            );
          },
        );
      } else {
        return new Error([new MalformedDoctype(), $bit_array.byte_size(input)]);
      }
    } else if (
      input.byteAt(0) === 80 &&
        input.byteAt(1) === 85 &&
        input.byteAt(2) === 66 &&
        input.byteAt(3) === 76 &&
        input.byteAt(4) === 73 &&
        input.byteAt(5) === 67 &&
      input.bitSize % 8 === 0
    ) {
      let rest = bitArraySlice(input, 48);
      return $result.try$(
        require_whitespace(rest),
        (rest) => {
          return $result.try$(
            parse_quoted_literal(rest),
            (_use0) => {
              let public$ = _use0[0];
              let rest$1 = _use0[1];
              let $ = is_valid_public_id(public$);
              if ($) {
                if (require_system) {
                  return $result.try$(
                    require_whitespace(rest$1),
                    (rest) => {
                      return $result.try$(
                        parse_quoted_literal(rest),
                        (_use0) => {
                          let system = _use0[0];
                          let rest$1 = _use0[1];
                          return new Ok(
                            [new Public(public$, new Some(system)), rest$1],
                          );
                        },
                      );
                    },
                  );
                } else {
                  let after_public = skip_whitespace(rest$1);
                  let $1 = parse_quoted_literal(after_public);
                  if ($1 instanceof Ok) {
                    let system = $1[0][0];
                    let rest$2 = $1[0][1];
                    return new Ok(
                      [new Public(public$, new Some(system)), rest$2],
                    );
                  } else {
                    return new Ok([new Public(public$, new None()), rest$1]);
                  }
                }
              } else {
                return new Error(
                  [new MalformedDoctype(), $bit_array.byte_size(rest$1)],
                );
              }
            },
          );
        },
      );
    } else {
      return new Error([new MalformedDoctype(), $bit_array.byte_size(input)]);
    }
  } else {
    return new Error([new MalformedDoctype(), $bit_array.byte_size(input)]);
  }
}

/**
 * Parse a DOCTYPE declaration. The input begins immediately after
 * `<!DOCTYPE`.
 * 
 * @ignore
 */
function parse_doctype(input, external) {
  let input$1 = skip_whitespace(input);
  return $result.try$(
    parse_name(input$1),
    (_use0) => {
      let name = _use0[0];
      let rest = _use0[1];
      let rest$1 = skip_whitespace(rest);
      return $result.try$(
        (() => {
          if (rest$1.bitSize >= 48) {
            if (
              rest$1.byteAt(0) === 83 &&
                rest$1.byteAt(1) === 89 &&
                rest$1.byteAt(2) === 83 &&
                rest$1.byteAt(3) === 84 &&
                rest$1.byteAt(4) === 69 &&
                rest$1.byteAt(5) === 77
            ) {
              if (rest$1.bitSize % 8 === 0) {
                return $result.try$(
                  parse_external_id(rest$1, true),
                  (_use0) => {
                    let id = _use0[0];
                    let rest$2 = _use0[1];
                    return new Ok([new Some(id), rest$2]);
                  },
                );
              } else {
                return new Ok([new None(), rest$1]);
              }
            } else if (
              rest$1.byteAt(0) === 80 &&
                rest$1.byteAt(1) === 85 &&
                rest$1.byteAt(2) === 66 &&
                rest$1.byteAt(3) === 76 &&
                rest$1.byteAt(4) === 73 &&
                rest$1.byteAt(5) === 67 &&
              rest$1.bitSize % 8 === 0
            ) {
              return $result.try$(
                parse_external_id(rest$1, true),
                (_use0) => {
                  let id = _use0[0];
                  let rest$2 = _use0[1];
                  return new Ok([new Some(id), rest$2]);
                },
              );
            } else {
              return new Ok([new None(), rest$1]);
            }
          } else {
            return new Ok([new None(), rest$1]);
          }
        })(),
        (_use0) => {
          let external_id = _use0[0];
          let rest$2 = _use0[1];
          let rest$3 = skip_whitespace(rest$2);
          return $result.try$(
            (() => {
              if (
                rest$3.bitSize >= 8 &&
                rest$3.byteAt(0) === 91 &&
                rest$3.bitSize % 8 === 0
              ) {
                let rest$4 = bitArraySlice(rest$3, 8);
                let _block;
                let _record = empty_dtd();
                _block = new Dtd(
                  _record.elements,
                  _record.attribute_lists,
                  _record.entities,
                  external.parameter_entities,
                  _record.notations,
                  _record.duplicate_elements,
                  _record.pe_nesting_violations,
                );
                let seed = _block;
                let subset_input = new DtdInput(
                  rest$4,
                  new None(),
                  0,
                  false,
                  new None(),
                );
                let subset_state = new DtdState(
                  seed,
                  false,
                  1,
                  false,
                  $dict.new$(),
                );
                return $result.try$(
                  parse_dtd_declarations(
                    subset_input,
                    subset_state,
                    new InternalSubset(),
                    toList([]),
                  ),
                  (_use0) => {
                    let state = _use0[0];
                    let rest$5 = _use0[1];
                    return new Ok(
                      [state.dtd, state.pe_used, skip_whitespace(rest$5)],
                    );
                  },
                );
              } else {
                return new Ok([empty_dtd(), false, rest$3]);
              }
            })(),
            (_use0) => {
              let declarations = _use0[0];
              let used_parameter_entities = _use0[1];
              let rest$4 = _use0[2];
              if (rest$4.bitSize >= 8) {
                if (rest$4.byteAt(0) === 62 && rest$4.bitSize % 8 === 0) {
                  let rest$5 = bitArraySlice(rest$4, 8);
                  return new Ok(
                    [
                      new Doctype(name, external_id, declarations),
                      used_parameter_entities,
                      rest$5,
                    ],
                  );
                } else {
                  return new Error(
                    [new MalformedDoctype(), $bit_array.byte_size(rest$4)],
                  );
                }
              } else if (rest$4.bitSize === 0) {
                return new Error([new UnexpectedEndOfInput(), 0]);
              } else {
                return new Error(
                  [new MalformedDoctype(), $bit_array.byte_size(rest$4)],
                );
              }
            },
          );
        },
      );
    },
  );
}

/**
 * Read whitespace, comments, processing instructions, and at most one
 * DOCTYPE declaration before the root element, keeping the comments and
 * processing instructions in document order.
 * 
 * @ignore
 */
function parse_prolog(loop$input, loop$doctype, loop$nodes, loop$external) {
  while (true) {
    let input = loop$input;
    let doctype = loop$doctype;
    let nodes = loop$nodes;
    let external = loop$external;
    let input$1 = skip_whitespace(input);
    if (input$1.bitSize >= 32) {
      if (
        input$1.byteAt(0) === 60 &&
          input$1.byteAt(1) === 33 &&
          input$1.byteAt(2) === 45 &&
          input$1.byteAt(3) === 45
      ) {
        if (input$1.bitSize % 8 === 0) {
          let rest = bitArraySlice(input$1, 32);
          let $ = parse_comment(rest);
          if ($ instanceof Ok) {
            let content = $[0][0];
            let rest$1 = $[0][1];
            loop$input = rest$1;
            loop$doctype = doctype;
            loop$nodes = listPrepend(new CommentNode(content), nodes);
            loop$external = external;
          } else {
            return $;
          }
        } else {
          return new Ok([doctype, $list.reverse(nodes), input$1]);
        }
      } else if (input$1.bitSize >= 72) {
        if (
          input$1.byteAt(0) === 60 &&
            input$1.byteAt(1) === 33 &&
            input$1.byteAt(2) === 68 &&
            input$1.byteAt(3) === 79 &&
            input$1.byteAt(4) === 67 &&
            input$1.byteAt(5) === 84 &&
            input$1.byteAt(6) === 89 &&
            input$1.byteAt(7) === 80 &&
            input$1.byteAt(8) === 69
        ) {
          if (input$1.bitSize % 8 === 0) {
            let rest = bitArraySlice(input$1, 72);
            if (doctype instanceof Some) {
              return new Error(
                [new MalformedDoctype(), $bit_array.byte_size(input$1)],
              );
            } else {
              let $ = parse_doctype(rest, external);
              if ($ instanceof Ok) {
                let doctype$1 = $[0][0];
                let used_parameter_entities = $[0][1];
                let rest$1 = $[0][2];
                loop$input = rest$1;
                loop$doctype = new Some([doctype$1, used_parameter_entities]);
                loop$nodes = nodes;
                loop$external = external;
              } else {
                return $;
              }
            }
          } else {
            return new Ok([doctype, $list.reverse(nodes), input$1]);
          }
        } else if (
          input$1.byteAt(0) === 60 &&
            input$1.byteAt(1) === 33 &&
            input$1.byteAt(2) === 100 &&
            input$1.byteAt(3) === 111 &&
            input$1.byteAt(4) === 99 &&
            input$1.byteAt(5) === 116 &&
            input$1.byteAt(6) === 121 &&
            input$1.byteAt(7) === 112 &&
            input$1.byteAt(8) === 101
        ) {
          if (input$1.bitSize % 8 === 0) {
            let rest = bitArraySlice(input$1, 72);
            if (doctype instanceof Some) {
              return new Error(
                [new MalformedDoctype(), $bit_array.byte_size(input$1)],
              );
            } else {
              let $ = parse_doctype(rest, external);
              if ($ instanceof Ok) {
                let doctype$1 = $[0][0];
                let used_parameter_entities = $[0][1];
                let rest$1 = $[0][2];
                loop$input = rest$1;
                loop$doctype = new Some([doctype$1, used_parameter_entities]);
                loop$nodes = nodes;
                loop$external = external;
              } else {
                return $;
              }
            }
          } else {
            return new Ok([doctype, $list.reverse(nodes), input$1]);
          }
        } else if (
          input$1.byteAt(0) === 60 && input$1.byteAt(1) === 63 &&
          input$1.bitSize % 8 === 0
        ) {
          let rest = bitArraySlice(input$1, 16);
          let $ = parse_processing_instruction(rest);
          if ($ instanceof Ok) {
            let instruction = $[0][0];
            let rest$1 = $[0][1];
            loop$input = rest$1;
            loop$doctype = doctype;
            loop$nodes = listPrepend(instruction, nodes);
            loop$external = external;
          } else {
            return $;
          }
        } else {
          return new Ok([doctype, $list.reverse(nodes), input$1]);
        }
      } else if (
        input$1.byteAt(0) === 60 && input$1.byteAt(1) === 63 &&
        input$1.bitSize % 8 === 0
      ) {
        let rest = bitArraySlice(input$1, 16);
        let $ = parse_processing_instruction(rest);
        if ($ instanceof Ok) {
          let instruction = $[0][0];
          let rest$1 = $[0][1];
          loop$input = rest$1;
          loop$doctype = doctype;
          loop$nodes = listPrepend(instruction, nodes);
          loop$external = external;
        } else {
          return $;
        }
      } else {
        return new Ok([doctype, $list.reverse(nodes), input$1]);
      }
    } else if (
      input$1.bitSize >= 16 &&
      input$1.byteAt(0) === 60 && input$1.byteAt(1) === 63 &&
      input$1.bitSize % 8 === 0
    ) {
      let rest = bitArraySlice(input$1, 16);
      let $ = parse_processing_instruction(rest);
      if ($ instanceof Ok) {
        let instruction = $[0][0];
        let rest$1 = $[0][1];
        loop$input = rest$1;
        loop$doctype = doctype;
        loop$nodes = listPrepend(instruction, nodes);
        loop$external = external;
      } else {
        return $;
      }
    } else {
      return new Ok([doctype, $list.reverse(nodes), input$1]);
    }
  }
}

function attribute_value(attributes, name) {
  return $list.find_map(
    attributes,
    (attribute) => {
      let $ = attribute.name === name;
      if ($) {
        return new Ok(attribute.value);
      } else {
        return new Error(undefined);
      }
    },
  );
}

function is_valid_encoding_name(encoding) {
  let $ = $string.to_utf_codepoints(encoding);
  if ($ instanceof $Empty) {
    return false;
  } else {
    let first = $.head;
    let rest = $.tail;
    let is_alpha = (code) => {
      return ((code >= 0x41) && (code <= 0x5A)) || ((code >= 0x61) && (code <= 0x7A));
    };
    return is_alpha($string.utf_codepoint_to_int(first)) && $list.all(
      rest,
      (codepoint) => {
        let code = $string.utf_codepoint_to_int(codepoint);
        return (((is_alpha(code) || ((code >= 0x30) && (code <= 0x39))) || (code === 0x2E)) || (code === 0x5F)) || (code === 0x2D);
      },
    );
  }
}

function is_all_digits(text) {
  let _pipe = $string.to_utf_codepoints(text);
  return $list.all(
    _pipe,
    (codepoint) => {
      let code = $string.utf_codepoint_to_int(codepoint);
      return (code >= 0x30) && (code <= 0x39);
    },
  );
}

function is_valid_xml_version(version) {
  if (version.startsWith("1.")) {
    let minor = version.slice(2);
    return (minor !== "") && is_all_digits(minor);
  } else {
    return false;
  }
}

function ordered_declaration_attributes(attributes, continue$) {
  let names = $list.map(attributes, (attribute) => { return attribute.name; });
  if (names instanceof $Empty) {
    return new Error(new MalformedAttribute("xml declaration"));
  } else {
    let $ = names.tail;
    if ($ instanceof $Empty) {
      let $1 = names.head;
      if ($1 === "version") {
        return continue$();
      } else {
        return new Error(new MalformedAttribute("xml declaration"));
      }
    } else {
      let $1 = $.tail;
      if ($1 instanceof $Empty) {
        let $2 = names.head;
        if ($2 === "version") {
          let $3 = $.head;
          if ($3 === "encoding") {
            return continue$();
          } else if ($3 === "standalone") {
            return continue$();
          } else {
            return new Error(new MalformedAttribute("xml declaration"));
          }
        } else {
          return new Error(new MalformedAttribute("xml declaration"));
        }
      } else {
        let $2 = $1.tail;
        if ($2 instanceof $Empty) {
          let $3 = names.head;
          if ($3 === "version") {
            let $4 = $.head;
            if ($4 === "encoding") {
              let $5 = $1.head;
              if ($5 === "standalone") {
                return continue$();
              } else {
                return new Error(new MalformedAttribute("xml declaration"));
              }
            } else {
              return new Error(new MalformedAttribute("xml declaration"));
            }
          } else {
            return new Error(new MalformedAttribute("xml declaration"));
          }
        } else {
          return new Error(new MalformedAttribute("xml declaration"));
        }
      }
    }
  }
}

/**
 * The XML declaration allows exactly `version`, then optionally
 * `encoding`, then optionally `standalone`, with restricted values.
 * 
 * @ignore
 */
function validate_declaration(attributes) {
  return ordered_declaration_attributes(
    attributes,
    () => {
      return $result.try$(
        (() => {
          let $ = attribute_value(attributes, "version");
          if ($ instanceof Ok) {
            let version = $[0];
            let $1 = is_valid_xml_version(version);
            if ($1) {
              return new Ok(version);
            } else {
              return new Error(new MalformedAttribute("version"));
            }
          } else {
            return new Error(new MalformedAttribute("version"));
          }
        })(),
        (version) => {
          return $result.try$(
            (() => {
              let $ = attribute_value(attributes, "encoding");
              if ($ instanceof Ok) {
                let encoding = $[0];
                let $1 = is_valid_encoding_name(encoding);
                if ($1) {
                  return new Ok(new Some(encoding));
                } else {
                  return new Error(new MalformedAttribute("encoding"));
                }
              } else {
                return new Ok(new None());
              }
            })(),
            (encoding) => {
              return $result.try$(
                (() => {
                  let $ = attribute_value(attributes, "standalone");
                  if ($ instanceof Ok) {
                    let $1 = $[0];
                    if ($1 === "yes") {
                      return new Ok(true);
                    } else if ($1 === "no") {
                      return new Ok(false);
                    } else {
                      return new Error(new MalformedAttribute("standalone"));
                    }
                  } else {
                    return new Ok(false);
                  }
                })(),
                (standalone) => {
                  return new Ok([version, encoding, standalone]);
                },
              );
            },
          );
        },
      );
    },
  );
}

function parse_declaration_attributes(input, acc) {
  let stripped = skip_whitespace(input);
  if (stripped.bitSize === 0) {
    return new Error([new UnexpectedEndOfInput(), 0]);
  } else if (
    stripped.bitSize >= 16 &&
    stripped.byteAt(0) === 63 && stripped.byteAt(1) === 62 &&
    stripped.bitSize % 8 === 0
  ) {
    let rest = bitArraySlice(stripped, 16);
    return new Ok([$list.reverse(acc), rest]);
  } else {
    let had_space = $bit_array.byte_size(stripped) < $bit_array.byte_size(input);
    return $result.try$(
      (() => {
        let $ = had_space || (isEqual(acc, toList([])));
        if ($) {
          return new Ok(stripped);
        } else {
          return new Error(
            [new MissingWhitespace(), $bit_array.byte_size(stripped)],
          );
        }
      })(),
      (input) => {
        let $ = parse_attribute(input, empty_dtd());
        if ($ instanceof Ok) {
          let attribute$1 = $[0][0];
          let rest = $[0][1];
          let $1 = has_attribute(acc, attribute$1.name);
          if ($1) {
            return new Error(
              [
                new DuplicateAttribute(attribute$1.name),
                $bit_array.byte_size(input),
              ],
            );
          } else {
            return parse_declaration_attributes(
              rest,
              listPrepend(attribute$1, acc),
            );
          }
        } else {
          return $;
        }
      },
    );
  }
}

function parse_declaration(input) {
  if (input.bitSize >= 48) {
    if (
      input.byteAt(0) === 60 &&
        input.byteAt(1) === 63 &&
        input.byteAt(2) === 120 &&
        input.byteAt(3) === 109 &&
        input.byteAt(4) === 108 &&
        input.byteAt(5) === 32
    ) {
      if (input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 48);
        return $result.try$(
          parse_declaration_attributes(rest, toList([])),
          (_use0) => {
            let attributes = _use0[0];
            let rest$1 = _use0[1];
            let $ = validate_declaration(attributes);
            if ($ instanceof Ok) {
              let version = $[0][0];
              let encoding = $[0][1];
              let standalone = $[0][2];
              return new Ok([version, encoding, standalone, rest$1]);
            } else {
              let kind = $[0];
              return new Error([kind, $bit_array.byte_size(rest$1)]);
            }
          },
        );
      } else {
        return new Ok(["1.0", new None(), false, input]);
      }
    } else if (
      input.byteAt(0) === 60 &&
        input.byteAt(1) === 63 &&
        input.byteAt(2) === 120 &&
        input.byteAt(3) === 109 &&
        input.byteAt(4) === 108 &&
        input.byteAt(5) === 9
    ) {
      if (input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 48);
        return $result.try$(
          parse_declaration_attributes(rest, toList([])),
          (_use0) => {
            let attributes = _use0[0];
            let rest$1 = _use0[1];
            let $ = validate_declaration(attributes);
            if ($ instanceof Ok) {
              let version = $[0][0];
              let encoding = $[0][1];
              let standalone = $[0][2];
              return new Ok([version, encoding, standalone, rest$1]);
            } else {
              let kind = $[0];
              return new Error([kind, $bit_array.byte_size(rest$1)]);
            }
          },
        );
      } else {
        return new Ok(["1.0", new None(), false, input]);
      }
    } else if (
      input.byteAt(0) === 60 &&
        input.byteAt(1) === 63 &&
        input.byteAt(2) === 120 &&
        input.byteAt(3) === 109 &&
        input.byteAt(4) === 108 &&
        input.byteAt(5) === 10 &&
      input.bitSize % 8 === 0
    ) {
      let rest = bitArraySlice(input, 48);
      return $result.try$(
        parse_declaration_attributes(rest, toList([])),
        (_use0) => {
          let attributes = _use0[0];
          let rest$1 = _use0[1];
          let $ = validate_declaration(attributes);
          if ($ instanceof Ok) {
            let version = $[0][0];
            let encoding = $[0][1];
            let standalone = $[0][2];
            return new Ok([version, encoding, standalone, rest$1]);
          } else {
            let kind = $[0];
            return new Error([kind, $bit_array.byte_size(rest$1)]);
          }
        },
      );
    } else {
      return new Ok(["1.0", new None(), false, input]);
    }
  } else {
    return new Ok(["1.0", new None(), false, input]);
  }
}

function parse_document(input, external) {
  return $result.try$(
    parse_declaration(input),
    (_use0) => {
      let version = _use0[0];
      let encoding = _use0[1];
      let standalone = _use0[2];
      let input$1 = _use0[3];
      return $result.try$(
        parse_prolog(input$1, new None(), toList([]), external),
        (_use0) => {
          let doctype_info = _use0[0];
          let prolog = _use0[1];
          let input$2 = _use0[2];
          let doctype = $option.map(doctype_info, (info) => { return info[0]; });
          let _block;
          if (doctype instanceof Some) {
            let doctype$1 = doctype[0];
            _block = merge_dtds(doctype$1.declarations, external);
          } else {
            _block = external;
          }
          let dtd = _block;
          let _block$1;
          if (standalone) {
            if (doctype instanceof Some) {
              let doctype$1 = doctype[0];
              _block$1 = new Dtd(
                dtd.elements,
                dtd.attribute_lists,
                doctype$1.declarations.entities,
                dtd.parameter_entities,
                dtd.notations,
                dtd.duplicate_elements,
                dtd.pe_nesting_violations,
              );
            } else {
              _block$1 = new Dtd(
                dtd.elements,
                dtd.attribute_lists,
                $dict.new$(),
                dtd.parameter_entities,
                dtd.notations,
                dtd.duplicate_elements,
                dtd.pe_nesting_violations,
              );
            }
          } else {
            _block$1 = dtd;
          }
          let dtd$1 = _block$1;
          let _block$2;
          if (doctype_info instanceof Some && !standalone) {
            let doctype$1 = doctype_info[0][0];
            let used_parameter_entities = doctype_info[0][1];
            _block$2 = $option.is_some(doctype$1.external_id) || used_parameter_entities;
          } else {
            _block$2 = false;
          }
          let relaxed_entities = _block$2;
          if (
            input$2.bitSize >= 8 &&
            input$2.byteAt(0) === 60 &&
            input$2.bitSize % 8 === 0
          ) {
            let rest = bitArraySlice(input$2, 8);
            return $result.try$(
              parse_element(rest, dtd$1, relaxed_entities),
              (_use0) => {
                let root = _use0[0];
                let input$3 = _use0[1];
                return $result.try$(
                  parse_epilogue(input$3, toList([])),
                  (_use0) => {
                    let epilogue = _use0[0];
                    let input$4 = _use0[1];
                    if (input$4.bitSize === 0) {
                      return new Ok(
                        new Document(
                          version,
                          encoding,
                          standalone,
                          doctype,
                          prolog,
                          root,
                          epilogue,
                        ),
                      );
                    } else {
                      return new Error(
                        [
                          new ContentAfterRootElement(),
                          $bit_array.byte_size(input$4),
                        ],
                      );
                    }
                  },
                );
              },
            );
          } else {
            return new Error(
              [new MissingRootElement(), $bit_array.byte_size(input$2)],
            );
          }
        },
      );
    },
  );
}

function scan_to_carriage_return(loop$input, loop$count) {
  while (true) {
    let input = loop$input;
    let count = loop$count;
    if (input.bitSize >= 8) {
      if (input.byteAt(0) === 13) {
        if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 8);
          return new Ok([count, rest]);
        } else {
          return new Error(undefined);
        }
      } else if (input.bitSize % 8 === 0) {
        let rest = bitArraySlice(input, 8);
        loop$input = rest;
        loop$count = count + 1;
      } else {
        return new Error(undefined);
      }
    } else {
      return new Error(undefined);
    }
  }
}

function do_normalise_line_endings(loop$input, loop$acc) {
  while (true) {
    let input = loop$input;
    let acc = loop$acc;
    let $ = scan_to_carriage_return(input, 0);
    if ($ instanceof Ok) {
      let count = $[0][0];
      let rest = $[0][1];
      let $1 = $bit_array.slice(input, 0, count);
      let before;
      if ($1 instanceof Ok) {
        before = $1[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "glexml",
          546,
          "do_normalise_line_endings",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $1,
            start: 21146,
            end: 21202,
            pattern_start: 21157,
            pattern_end: 21167
          }
        )
      }
      let _block;
      if (rest.bitSize >= 8 && rest.byteAt(0) === 10 && rest.bitSize % 8 === 0) {
        let tail = bitArraySlice(rest, 8);
        _block = tail;
      } else {
        _block = rest;
      }
      let rest$1 = _block;
      loop$input = rest$1;
      loop$acc = listPrepend(
        toBitArray([stringBits("\n")]),
        listPrepend(before, acc),
      );
    } else {
      return $list.reverse(listPrepend(input, acc));
    }
  }
}

/**
 * XML 1.0 section 2.11: normalise `\r\n` and lone `\r` to a single line
 * feed. This works on bytes rather than strings because Erlang's string
 * functions treat `\r\n` as a single grapheme, which makes sequences like
 * `\r\r\n` impossible to normalise with `string.replace`.
 * 
 * @ignore
 */
function normalise_line_endings(input) {
  let $ = scan_to_carriage_return(input, 0);
  if ($ instanceof Ok) {
    return $bit_array.concat(do_normalise_line_endings(input, toList([])));
  } else {
    return input;
  }
}

/**
 * Parse a string of XML with extra DTD declarations available, typically
 * an external DTD subset loaded separately and parsed with `parse_dtd`.
 *
 * Entities declared in the document's own internal subset take precedence
 * over the ones given here, mirroring how XML processors read the internal
 * subset first.
 *
 * ```gleam
 * let assert Ok(xhtml_dtd) = glexml.parse_dtd("<!ENTITY nbsp \"&#160;\">")
 * glexml.parse_with_dtd("<p>a&nbsp;b</p>", xhtml_dtd)
 * // -> Ok(...)
 * ```
 */
export function parse_with_dtd(input, dtd) {
  let _block;
  if (input.charCodeAt(0) === 65279) {
    let rest = input.slice(1);
    _block = rest;
  } else {
    _block = input;
  }
  let input$1 = _block;
  let bytes = normalise_line_endings($bit_array.from_string(input$1));
  let $ = parse_document(bytes, dtd);
  if ($ instanceof Ok) {
    return $;
  } else {
    let kind = $[0][0];
    let remaining = $[0][1];
    return new Error(make_error(bytes, kind, remaining));
  }
}

/**
 * Parse a string of XML into a `Document`.
 *
 * ```gleam
 * let assert Ok(document) = glexml.parse("<greeting lang=\"en\">Hello</greeting>")
 * document.root.name
 * // -> "greeting"
 * ```
 */
export function parse(input) {
  return parse_with_dtd(input, empty_dtd());
}

/**
 * Encoding problems have no meaningful position in the decoded text; they
 * are reported at the start of the document.
 * 
 * @ignore
 */
function encoding_error(kind) {
  return new ParseError(kind, 1, 1, 0);
}

/**
 * It is a fatal error for the encoding declaration to name an encoding
 * other than the one the document is actually in. We only flag
 * contradictions we can be certain of: a UTF-16 document declaring
 * something else, or a UTF-8 document declaring a UTF-16 or UTF-32
 * family encoding.
 * 
 * @ignore
 */
function declaration_matches_encoding(declared, detected) {
  if (declared instanceof Some) {
    let declared$1 = declared[0];
    let name = $string.lowercase(declared$1);
    let declares_utf16 = $string.starts_with(name, "utf-16") || $string.starts_with(
      name,
      "ucs-2",
    );
    let declares_utf32 = $string.starts_with(name, "utf-32") || $string.starts_with(
      name,
      "ucs-4",
    );
    if (detected instanceof DetectedUtf8) {
      let $ = declares_utf16 || declares_utf32;
      if ($) {
        return new Error(new DeclaredEncodingMismatch(declared$1, "UTF-8"));
      } else {
        return new Ok(undefined);
      }
    } else {
      if (declares_utf16) {
        return new Ok(undefined);
      } else {
        return new Error(new DeclaredEncodingMismatch(declared$1, "UTF-16"));
      }
    }
  } else {
    return new Ok(undefined);
  }
}

/**
 * Decode UTF-16 in the given byte order, including surrogate pairs. Odd
 * input lengths and invalid surrogates are errors.
 * 
 * @ignore
 */
function decode_utf16(loop$input, loop$big_endian, loop$acc) {
  while (true) {
    let input = loop$input;
    let big_endian = loop$big_endian;
    let acc = loop$acc;
    if (input.bitSize === 0) {
      return new Ok($string.from_utf_codepoints($list.reverse(acc)));
    } else if (
      input.bitSize >= 8 &&
      input.bitSize >= 16 &&
      input.bitSize % 8 === 0
    ) {
      let a = input.byteAt(0);
      let b = input.byteAt(1);
      let rest = bitArraySlice(input, 16);
      let _block;
      if (big_endian) {
        _block = a * 256 + b;
      } else {
        _block = b * 256 + a;
      }
      let unit = _block;
      let $ = (unit >= 0xD800) && (unit <= 0xDBFF);
      if ($) {
        if (rest.bitSize >= 8 && rest.bitSize >= 16 && rest.bitSize % 8 === 0) {
          let c = rest.byteAt(0);
          let d = rest.byteAt(1);
          let rest$1 = bitArraySlice(rest, 16);
          let _block$1;
          if (big_endian) {
            _block$1 = c * 256 + d;
          } else {
            _block$1 = d * 256 + c;
          }
          let low = _block$1;
          let $1 = (low >= 0xDC00) && (low <= 0xDFFF);
          if ($1) {
            let code = (0x10000 + (unit - 0xD800) * 0x400) + (low - 0xDC00);
            let $2 = $string.utf_codepoint(code);
            if ($2 instanceof Ok) {
              let codepoint = $2[0];
              loop$input = rest$1;
              loop$big_endian = big_endian;
              loop$acc = listPrepend(codepoint, acc);
            } else {
              return new Error("UTF-16");
            }
          } else {
            return new Error("UTF-16");
          }
        } else {
          return new Error("UTF-16");
        }
      } else {
        let $1 = (unit >= 0xDC00) && (unit <= 0xDFFF);
        if ($1) {
          return new Error("UTF-16");
        } else {
          let $2 = $string.utf_codepoint(unit);
          if ($2 instanceof Ok) {
            let codepoint = $2[0];
            loop$input = rest;
            loop$big_endian = big_endian;
            loop$acc = listPrepend(codepoint, acc);
          } else {
            return new Error("UTF-16");
          }
        }
      }
    } else {
      return new Error("UTF-16");
    }
  }
}

/**
 * Appendix F encoding detection: byte order marks first, then the byte
 * pattern of a document starting with `<?xml` or `<`. Returns the
 * detected encoding and the input with any byte order mark removed.
 * 
 * @ignore
 */
function detect_encoding(input) {
  if (input.bitSize >= 8) {
    if (input.byteAt(0) === 0) {
      if (input.bitSize >= 16) {
        if (input.byteAt(1) === 0) {
          if (input.bitSize >= 24) {
            if (input.byteAt(2) === 254) {
              if (
                input.bitSize >= 32 &&
                input.byteAt(3) === 255 &&
                input.bitSize % 8 === 0
              ) {
                return new Error("UTF-32");
              } else {
                return new Ok([new DetectedUtf8(), input]);
              }
            } else if (
              input.byteAt(2) === 0 &&
              input.bitSize >= 32 &&
              input.byteAt(3) === 60 &&
              input.bitSize % 8 === 0
            ) {
              return new Error("UTF-32");
            } else {
              return new Ok([new DetectedUtf8(), input]);
            }
          } else {
            return new Ok([new DetectedUtf8(), input]);
          }
        } else if (
          input.byteAt(1) === 60 &&
          input.bitSize >= 24 &&
          input.byteAt(2) === 0 &&
          input.bitSize >= 32 &&
          input.byteAt(3) === 63 &&
          input.bitSize % 8 === 0
        ) {
          return new Ok([new DetectedUtf16(true), input]);
        } else {
          return new Ok([new DetectedUtf8(), input]);
        }
      } else {
        return new Ok([new DetectedUtf8(), input]);
      }
    } else if (input.byteAt(0) === 255) {
      if (input.bitSize >= 16 && input.byteAt(1) === 254) {
        if (
          input.bitSize >= 24 &&
          input.byteAt(2) === 0 &&
          input.bitSize >= 32 &&
          input.byteAt(3) === 0
        ) {
          if (input.bitSize % 8 === 0) {
            return new Error("UTF-32");
          } else {
            return new Ok([new DetectedUtf8(), input]);
          }
        } else if (input.bitSize % 8 === 0) {
          let rest = bitArraySlice(input, 16);
          return new Ok([new DetectedUtf16(false), rest]);
        } else {
          return new Ok([new DetectedUtf8(), input]);
        }
      } else {
        return new Ok([new DetectedUtf8(), input]);
      }
    } else if (input.byteAt(0) === 239) {
      if (
        input.bitSize >= 16 &&
        input.byteAt(1) === 187 &&
        input.bitSize >= 24 &&
        input.byteAt(2) === 191 &&
        input.bitSize % 8 === 0
      ) {
        let rest = bitArraySlice(input, 24);
        return new Ok([new DetectedUtf8(), rest]);
      } else {
        return new Ok([new DetectedUtf8(), input]);
      }
    } else if (input.byteAt(0) === 254) {
      if (
        input.bitSize >= 16 &&
        input.byteAt(1) === 255 &&
        input.bitSize % 8 === 0
      ) {
        let rest = bitArraySlice(input, 16);
        return new Ok([new DetectedUtf16(true), rest]);
      } else {
        return new Ok([new DetectedUtf8(), input]);
      }
    } else if (input.byteAt(0) === 60) {
      if (input.bitSize >= 16 && input.byteAt(1) === 0 && input.bitSize >= 24) {
        if (input.byteAt(2) === 0) {
          if (
            input.bitSize >= 32 &&
            input.byteAt(3) === 0 &&
            input.bitSize % 8 === 0
          ) {
            return new Error("UTF-32");
          } else {
            return new Ok([new DetectedUtf8(), input]);
          }
        } else if (
          input.byteAt(2) === 63 &&
          input.bitSize >= 32 &&
          input.byteAt(3) === 0 &&
          input.bitSize % 8 === 0
        ) {
          return new Ok([new DetectedUtf16(false), input]);
        } else {
          return new Ok([new DetectedUtf8(), input]);
        }
      } else {
        return new Ok([new DetectedUtf8(), input]);
      }
    } else if (
      input.byteAt(0) === 76 &&
      input.bitSize >= 16 &&
      input.byteAt(1) === 111 &&
      input.bitSize >= 24 &&
      input.byteAt(2) === 167 &&
      input.bitSize >= 32 &&
      input.byteAt(3) === 148 &&
      input.bitSize % 8 === 0
    ) {
      return new Error("EBCDIC");
    } else {
      return new Ok([new DetectedUtf8(), input]);
    }
  } else {
    return new Ok([new DetectedUtf8(), input]);
  }
}

/**
 * `parse_bytes` with extra DTD declarations available, as with
 * `parse_with_dtd`.
 */
export function parse_bytes_with_dtd(input, dtd) {
  let $ = detect_encoding(input);
  if ($ instanceof Ok) {
    let detected = $[0][0];
    let bytes = $[0][1];
    let _block;
    if (detected instanceof DetectedUtf8) {
      let _pipe = $bit_array.to_string(bytes);
      _block = $result.replace_error(_pipe, "UTF-8");
    } else {
      let big_endian = detected.big_endian;
      _block = decode_utf16(bytes, big_endian, toList([]));
    }
    let text = _block;
    if (text instanceof Ok) {
      let text$1 = text[0];
      return $result.try$(
        parse_with_dtd(text$1, dtd),
        (document) => {
          let $1 = declaration_matches_encoding(document.encoding, detected);
          if ($1 instanceof Ok) {
            return new Ok(document);
          } else {
            let kind = $1[0];
            return new Error(encoding_error(kind));
          }
        },
      );
    } else {
      let encoding = text[0];
      return new Error(encoding_error(new UnsupportedEncoding(encoding)));
    }
  } else {
    let encoding = $[0];
    return new Error(encoding_error(new UnsupportedEncoding(encoding)));
  }
}

/**
 * Parse raw bytes of XML, detecting the character encoding first.
 *
 * Detection follows Appendix F of the XML specification: a byte order
 * mark, or the byte pattern of `<?xml` at the start of the input. UTF-8
 * (the default) and UTF-16 in either byte order are decoded; UTF-32 and
 * EBCDIC are recognised but unsupported, and reported as
 * `UnsupportedEncoding`. An `encoding` declaration that contradicts the
 * detected encoding is an error, as the specification requires.
 *
 * Use this instead of `parse` when reading files whose encoding is not
 * known to be UTF-8, such as XML inside EPUB 2 publications.
 */
export function parse_bytes(input) {
  return parse_bytes_with_dtd(input, empty_dtd());
}

/**
 * Parse an external subset from its first byte.
 * 
 * @ignore
 */
function parse_subset(bytes, seed) {
  let input = new DtdInput(bytes, new None(), 0, false, new None());
  let state = new DtdState(seed, true, 1, false, $dict.new$());
  let $ = parse_dtd_declarations(input, state, new ExternalSubset(), toList([]));
  if ($ instanceof Ok) {
    let state$1 = $[0][0];
    return new Ok([state$1.dtd, state$1.pe_used]);
  } else {
    return $;
  }
}

/**
 * Parse the text of an external DTD subset (a `.dtd` file) into a `Dtd`.
 *
 * Parameter entities, conditional sections (`<![INCLUDE[`/`<![IGNORE[`),
 * and all four declaration kinds are supported. The result can be passed
 * to `parse_with_dtd` so its entities resolve during parsing, and to
 * `glexml/dtd.validate` to validate a document against it.
 */
export function parse_dtd(input) {
  let _block;
  if (input.charCodeAt(0) === 65279) {
    let rest = input.slice(1);
    _block = rest;
  } else {
    _block = input;
  }
  let input$1 = _block;
  let bytes = normalise_line_endings($bit_array.from_string(input$1));
  let $ = parse_subset(bytes, empty_dtd());
  if ($ instanceof Ok) {
    let dtd = $[0][0];
    return new Ok(dtd);
  } else {
    let kind = $[0][0];
    let remaining = $[0][1];
    return new Error(make_error(bytes, kind, remaining));
  }
}

/**
 * Like `parse_dtd`, but with declarations already in scope: the given
 * DTD's declarations bind first, exactly as if they had been read before
 * this subset. Use this when an external subset refers to parameter
 * entities declared in a document's internal subset, which is read first.
 */
export function parse_dtd_with(input, seed) {
  let _block;
  if (input.charCodeAt(0) === 65279) {
    let rest = input.slice(1);
    _block = rest;
  } else {
    _block = input;
  }
  let input$1 = _block;
  let bytes = normalise_line_endings($bit_array.from_string(input$1));
  let $ = parse_subset(bytes, seed);
  if ($ instanceof Ok) {
    let dtd = $[0][0];
    return new Ok(dtd);
  } else {
    let kind = $[0][0];
    let remaining = $[0][1];
    return new Error(make_error(bytes, kind, remaining));
  }
}

/**
 * Convert a `ParseError` into a human readable message, suitable for
 * showing to users of your tool.
 */
export function error_to_string(error) {
  let _block;
  let $ = error.kind;
  if ($ instanceof UnexpectedEndOfInput) {
    _block = "unexpected end of input";
  } else if ($ instanceof MissingRootElement) {
    _block = "expected a root element";
  } else if ($ instanceof ContentAfterRootElement) {
    _block = "unexpected content after the root element";
  } else if ($ instanceof InvalidName) {
    _block = "expected a valid name";
  } else if ($ instanceof MalformedAttribute) {
    let name = $.attribute;
    _block = ("expected =\"value\" after attribute \"" + name) + "\"";
  } else if ($ instanceof DuplicateAttribute) {
    let name = $.attribute;
    _block = ("duplicate attribute \"" + name) + "\"";
  } else if ($ instanceof MismatchedClosingTag) {
    let opening = $.opening;
    let closing = $.closing;
    _block = ((("expected closing tag for \"" + opening) + "\" but found \"") + closing) + "\"";
  } else if ($ instanceof MalformedEntity) {
    _block = "entity reference is missing a closing semicolon";
  } else if ($ instanceof UnknownEntity) {
    let entity = $.entity;
    _block = ("unknown entity \"&" + entity) + ";\"";
  } else if ($ instanceof InvalidCharacterReference) {
    let reference = $.reference;
    _block = ("invalid character reference \"&" + reference) + ";\"";
  } else if ($ instanceof MalformedDoctype) {
    _block = "malformed DOCTYPE or DTD declaration";
  } else if ($ instanceof RecursiveEntity) {
    let entity = $.entity;
    _block = ("entity \"&" + entity) + ";\" expands to itself";
  } else if ($ instanceof UnresolvableEntity) {
    let entity = $.entity;
    _block = ("the content of entity \"&" + entity) + ";\" is external and not available";
  } else if ($ instanceof MarkupInAttributeValue) {
    let entity = $.entity;
    _block = ("entity \"&" + entity) + ";\" puts a \"<\" inside an attribute value";
  } else if ($ instanceof InvalidCharacter) {
    _block = "character not allowed here";
  } else if ($ instanceof MalformedComment) {
    _block = "comments may not contain \"--\"";
  } else if ($ instanceof CdataEndInContent) {
    _block = "character data may not contain \"]]>\"";
  } else if ($ instanceof UnbalancedEntity) {
    let entity = $.entity;
    _block = ("the content of entity \"&" + entity) + ";\" is not balanced";
  } else if ($ instanceof MissingWhitespace) {
    _block = "whitespace is required here";
  } else if ($ instanceof UnsupportedEncoding) {
    let encoding = $.encoding;
    _block = "cannot decode the input as " + encoding;
  } else {
    let declared = $.declared;
    let detected = $.detected;
    _block = (("the declaration says encoding=\"" + declared) + "\" but the document is encoded as ") + detected;
  }
  let message = _block;
  return (((message + " at line ") + $int.to_string(error.line)) + ", column ") + $int.to_string(
    error.column,
  );
}

/**
 * Get the value of the named attribute of an element.
 */
export function attribute(element, name) {
  return attribute_value(element.attributes, name);
}

/**
 * Get the element children of an element, skipping text, comments, and
 * processing instructions.
 */
export function child_elements(element) {
  return $list.filter_map(
    element.children,
    (node) => {
      if (node instanceof ElementNode) {
        let child = node[0];
        return new Ok(child);
      } else {
        return new Error(undefined);
      }
    },
  );
}

/**
 * Get the element children of an element that have the given name.
 */
export function children_named(element, name) {
  return $list.filter(
    child_elements(element),
    (child) => { return child.name === name; },
  );
}

/**
 * Get the first element child of an element with the given name.
 */
export function first_child_named(element, name) {
  return $list.find_map(
    element.children,
    (node) => {
      if (node instanceof ElementNode) {
        let child = node[0];
        let $ = child.name === name;
        if ($) {
          return new Ok(child);
        } else {
          return new Error(undefined);
        }
      } else {
        return new Error(undefined);
      }
    },
  );
}

/**
 * Get every descendant element with the given name, in document order.
 *
 * ```gleam
 * glexml.descendants_named(package, "item")
 * // -> every <item> anywhere below <package>
 * ```
 */
export function descendants_named(element, name) {
  return $list.flat_map(
    child_elements(element),
    (child) => {
      let $ = child.name === name;
      if ($) {
        return listPrepend(child, descendants_named(child, name));
      } else {
        return descendants_named(child, name);
      }
    },
  );
}

/**
 * Follow a path of element names from an element, taking the first matching
 * child at each step.
 *
 * ```gleam
 * glexml.at(package, ["metadata", "dc:title"])
 * // -> Ok(the <dc:title> element inside <metadata>)
 * ```
 */
export function at(element, path) {
  if (path instanceof $Empty) {
    return new Ok(element);
  } else {
    let name = path.head;
    let rest = path.tail;
    return $result.try$(
      first_child_named(element, name),
      (child) => { return at(child, rest); },
    );
  }
}

/**
 * Concatenate all text in an element and its descendants, in document
 * order. Comments and processing instructions contribute nothing.
 */
export function text_content(element) {
  let _pipe = element.children;
  let _pipe$1 = $list.map(
    _pipe,
    (node) => {
      if (node instanceof ElementNode) {
        let child = node[0];
        return text_content(child);
      } else if (node instanceof TextNode) {
        let text = node.text;
        return text;
      } else if (node instanceof CommentNode) {
        return "";
      } else if (node instanceof ProcessingInstructionNode) {
        return "";
      } else {
        return "";
      }
    },
  );
  return $string.concat(_pipe$1);
}

/**
 * The part of a qualified name after any namespace prefix.
 *
 * ```gleam
 * glexml.local_name("dc:title")
 * // -> "title"
 * glexml.local_name("title")
 * // -> "title"
 * ```
 */
export function local_name(name) {
  let $ = $string.split_once(name, ":");
  if ($ instanceof Ok) {
    let local = $[0][1];
    return local;
  } else {
    return name;
  }
}

/**
 * The namespace prefix of a qualified name, if it has one.
 *
 * ```gleam
 * glexml.namespace_prefix("dc:title")
 * // -> Some("dc")
 * ```
 */
export function namespace_prefix(name) {
  let $ = $string.split_once(name, ":");
  if ($ instanceof Ok) {
    let prefix = $[0][0];
    return new Some(prefix);
  } else {
    return new None();
  }
}

function escape_text(text) {
  let _pipe = text;
  let _pipe$1 = $string.replace(_pipe, "&", "&amp;");
  let _pipe$2 = $string.replace(_pipe$1, "<", "&lt;");
  return $string.replace(_pipe$2, ">", "&gt;");
}

function escape_attribute(value) {
  let _pipe = value;
  let _pipe$1 = escape_text(_pipe);
  return $string.replace(_pipe$1, "\"", "&quot;");
}

function node_to_tree(node) {
  if (node instanceof ElementNode) {
    let element = node[0];
    return element_to_tree(element);
  } else if (node instanceof TextNode) {
    let text = node.text;
    return $string_tree.from_string(escape_text(text));
  } else if (node instanceof CommentNode) {
    let content = node[0];
    return $string_tree.from_string(("<!--" + content) + "-->");
  } else if (node instanceof ProcessingInstructionNode) {
    let $ = node.content;
    if ($ === "") {
      let target = node.target;
      return $string_tree.from_string(("<?" + target) + "?>");
    } else {
      let target = node.target;
      let content = $;
      return $string_tree.from_string(
        ((("<?" + target) + " ") + content) + "?>",
      );
    }
  } else {
    let entity = node.entity;
    return $string_tree.from_string(("&" + entity) + ";");
  }
}

function element_to_tree(element) {
  let name = element.name;
  let attributes = element.attributes;
  let children = element.children;
  let open = $list.fold(
    attributes,
    $string_tree.from_string("<" + name),
    (tree, attribute) => {
      return $string_tree.append(
        tree,
        (((" " + attribute.name) + "=\"") + escape_attribute(attribute.value)) + "\"",
      );
    },
  );
  if (children instanceof $Empty) {
    return $string_tree.append(open, "/>");
  } else {
    let _pipe = children;
    let _pipe$1 = $list.fold(
      _pipe,
      $string_tree.append(open, ">"),
      (tree, child) => {
        return $string_tree.append_tree(tree, node_to_tree(child));
      },
    );
    return $string_tree.append(_pipe$1, ("</" + name) + ">");
  }
}

/**
 * Serialise an element and its children to a string.
 */
export function element_to_string(element) {
  let _pipe = element;
  let _pipe$1 = element_to_tree(_pipe);
  return $string_tree.to_string(_pipe$1);
}

/**
 * Serialise a DOCTYPE declaration. The internal subset is not rendered,
 * only the root name and any external identifier.
 */
export function doctype_to_string(doctype) {
  let _block;
  let $ = doctype.external_id;
  if ($ instanceof Some) {
    let $1 = $[0];
    if ($1 instanceof System) {
      let system = $1.system;
      _block = (" SYSTEM \"" + system) + "\"";
    } else {
      let $2 = $1.system;
      if ($2 instanceof Some) {
        let public$ = $1.public;
        let system = $2[0];
        _block = (((" PUBLIC \"" + public$) + "\" \"") + system) + "\"";
      } else {
        let public$ = $1.public;
        _block = (" PUBLIC \"" + public$) + "\"";
      }
    }
  } else {
    _block = "";
  }
  let external = _block;
  return (("<!DOCTYPE " + doctype.root_name) + external) + ">";
}

/**
 * Serialise a document to a string, including an XML declaration.
 *
 * Text and attribute values are escaped as needed. Elements with no
 * children are rendered self-closing.
 */
export function document_to_string(document) {
  let _block;
  let $ = document.encoding;
  if ($ instanceof Some) {
    let encoding = $[0];
    _block = (" encoding=\"" + encoding) + "\"";
  } else {
    _block = "";
  }
  let encoding = _block;
  let _block$1;
  let $1 = document.standalone;
  if ($1) {
    _block$1 = " standalone=\"yes\"";
  } else {
    _block$1 = "";
  }
  let standalone = _block$1;
  let _block$2;
  let $2 = document.doctype;
  if ($2 instanceof Some) {
    let doctype = $2[0];
    _block$2 = doctype_to_string(doctype) + "\n";
  } else {
    _block$2 = "";
  }
  let doctype = _block$2;
  let _block$3;
  let _pipe = document.prolog;
  let _pipe$1 = $list.map(
    _pipe,
    (node) => { return $string_tree.to_string(node_to_tree(node)) + "\n"; },
  );
  _block$3 = $string.concat(_pipe$1);
  let prolog = _block$3;
  let _block$4;
  let _pipe$2 = document.epilogue;
  let _pipe$3 = $list.map(
    _pipe$2,
    (node) => { return "\n" + $string_tree.to_string(node_to_tree(node)); },
  );
  _block$4 = $string.concat(_pipe$3);
  let epilogue = _block$4;
  return (((((((("<?xml version=\"" + document.version) + "\"") + encoding) + standalone) + "?>\n") + doctype) + prolog) + element_to_string(
    document.root,
  )) + epilogue;
}
