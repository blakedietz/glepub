import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { Some } from "../../gleam_stdlib/gleam/option.mjs";
import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $set from "../../gleam_stdlib/gleam/set.mjs";
import * as $string from "../../gleam_stdlib/gleam/string.mjs";
import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  isEqual,
} from "../gleam.mjs";
import * as $glexml from "../glexml.mjs";
import {
  AnyContent,
  Attribute,
  CdataAttribute,
  Choice,
  Default,
  Document,
  Element,
  ElementContent,
  ElementNode,
  EmptyContent,
  EntitiesAttribute,
  EntityAttribute,
  EnumeratedAttribute,
  ExactlyOne,
  ExternalEntity,
  Fixed,
  IdAttribute,
  IdRefAttribute,
  IdRefsAttribute,
  MixedContent,
  NameParticle,
  NmtokenAttribute,
  NmtokensAttribute,
  NotationAttribute,
  OneOrMore,
  Required,
  Sequence,
  TextNode,
  ZeroOrMore,
  ZeroOrOne,
} from "../glexml.mjs";

export class Violation extends $CustomType {
  constructor(path, problem) {
    super();
    this.path = path;
    this.problem = problem;
  }
}
export const Violation$Violation = (path, problem) =>
  new Violation(path, problem);
export const Violation$isViolation = (value) => value instanceof Violation;
export const Violation$Violation$path = (value) => value.path;
export const Violation$Violation$0 = (value) => value.path;
export const Violation$Violation$problem = (value) => value.problem;
export const Violation$Violation$1 = (value) => value.problem;

/**
 * The root element is not the one named by the DOCTYPE.
 */
export class RootElementMismatch extends $CustomType {
  constructor(expected, found) {
    super();
    this.expected = expected;
    this.found = found;
  }
}
export const Problem$RootElementMismatch = (expected, found) =>
  new RootElementMismatch(expected, found);
export const Problem$isRootElementMismatch = (value) =>
  value instanceof RootElementMismatch;
export const Problem$RootElementMismatch$expected = (value) => value.expected;
export const Problem$RootElementMismatch$0 = (value) => value.expected;
export const Problem$RootElementMismatch$found = (value) => value.found;
export const Problem$RootElementMismatch$1 = (value) => value.found;

/**
 * The element has no `<!ELEMENT>` declaration.
 */
export class UndeclaredElement extends $CustomType {
  constructor(element) {
    super();
    this.element = element;
  }
}
export const Problem$UndeclaredElement = (element) =>
  new UndeclaredElement(element);
export const Problem$isUndeclaredElement = (value) =>
  value instanceof UndeclaredElement;
export const Problem$UndeclaredElement$element = (value) => value.element;
export const Problem$UndeclaredElement$0 = (value) => value.element;

/**
 * The element's children do not match its declared content model.
 */
export class InvalidContent extends $CustomType {
  constructor(element, model) {
    super();
    this.element = element;
    this.model = model;
  }
}
export const Problem$InvalidContent = (element, model) =>
  new InvalidContent(element, model);
export const Problem$isInvalidContent = (value) =>
  value instanceof InvalidContent;
export const Problem$InvalidContent$element = (value) => value.element;
export const Problem$InvalidContent$0 = (value) => value.element;
export const Problem$InvalidContent$model = (value) => value.model;
export const Problem$InvalidContent$1 = (value) => value.model;

/**
 * Character data appears where the content model allows only elements.
 */
export class TextNotAllowed extends $CustomType {
  constructor(element) {
    super();
    this.element = element;
  }
}
export const Problem$TextNotAllowed = (element) => new TextNotAllowed(element);
export const Problem$isTextNotAllowed = (value) =>
  value instanceof TextNotAllowed;
export const Problem$TextNotAllowed$element = (value) => value.element;
export const Problem$TextNotAllowed$0 = (value) => value.element;

/**
 * The attribute has no `<!ATTLIST>` declaration.
 */
export class UndeclaredAttribute extends $CustomType {
  constructor(element, attribute) {
    super();
    this.element = element;
    this.attribute = attribute;
  }
}
export const Problem$UndeclaredAttribute = (element, attribute) =>
  new UndeclaredAttribute(element, attribute);
export const Problem$isUndeclaredAttribute = (value) =>
  value instanceof UndeclaredAttribute;
export const Problem$UndeclaredAttribute$element = (value) => value.element;
export const Problem$UndeclaredAttribute$0 = (value) => value.element;
export const Problem$UndeclaredAttribute$attribute = (value) => value.attribute;
export const Problem$UndeclaredAttribute$1 = (value) => value.attribute;

/**
 * A `#REQUIRED` attribute is missing.
 */
export class MissingRequiredAttribute extends $CustomType {
  constructor(element, attribute) {
    super();
    this.element = element;
    this.attribute = attribute;
  }
}
export const Problem$MissingRequiredAttribute = (element, attribute) =>
  new MissingRequiredAttribute(element, attribute);
export const Problem$isMissingRequiredAttribute = (value) =>
  value instanceof MissingRequiredAttribute;
export const Problem$MissingRequiredAttribute$element = (value) =>
  value.element;
export const Problem$MissingRequiredAttribute$0 = (value) => value.element;
export const Problem$MissingRequiredAttribute$attribute = (value) =>
  value.attribute;
export const Problem$MissingRequiredAttribute$1 = (value) => value.attribute;

/**
 * The attribute value does not satisfy its declared type or `#FIXED`
 * value. `expected` describes what would be acceptable.
 */
export class InvalidAttributeValue extends $CustomType {
  constructor(element, attribute, value, expected) {
    super();
    this.element = element;
    this.attribute = attribute;
    this.value = value;
    this.expected = expected;
  }
}
export const Problem$InvalidAttributeValue = (element, attribute, value, expected) =>
  new InvalidAttributeValue(element, attribute, value, expected);
export const Problem$isInvalidAttributeValue = (value) =>
  value instanceof InvalidAttributeValue;
export const Problem$InvalidAttributeValue$element = (value) => value.element;
export const Problem$InvalidAttributeValue$0 = (value) => value.element;
export const Problem$InvalidAttributeValue$attribute = (value) =>
  value.attribute;
export const Problem$InvalidAttributeValue$1 = (value) => value.attribute;
export const Problem$InvalidAttributeValue$value = (value) => value.value;
export const Problem$InvalidAttributeValue$2 = (value) => value.value;
export const Problem$InvalidAttributeValue$expected = (value) => value.expected;
export const Problem$InvalidAttributeValue$3 = (value) => value.expected;

/**
 * The same ID value appears on more than one element.
 */
export class DuplicateId extends $CustomType {
  constructor(id) {
    super();
    this.id = id;
  }
}
export const Problem$DuplicateId = (id) => new DuplicateId(id);
export const Problem$isDuplicateId = (value) => value instanceof DuplicateId;
export const Problem$DuplicateId$id = (value) => value.id;
export const Problem$DuplicateId$0 = (value) => value.id;

/**
 * An IDREF or IDREFS value that no ID in the document matches.
 */
export class UnknownIdReference extends $CustomType {
  constructor(id) {
    super();
    this.id = id;
  }
}
export const Problem$UnknownIdReference = (id) => new UnknownIdReference(id);
export const Problem$isUnknownIdReference = (value) =>
  value instanceof UnknownIdReference;
export const Problem$UnknownIdReference$id = (value) => value.id;
export const Problem$UnknownIdReference$0 = (value) => value.id;

/**
 * A reference to an entity with no declaration. The parser only keeps
 * such references (rather than failing) when the DTD could not have
 * been read completely; validation reports them.
 */
export class UndeclaredEntity extends $CustomType {
  constructor(entity) {
    super();
    this.entity = entity;
  }
}
export const Problem$UndeclaredEntity = (entity) =>
  new UndeclaredEntity(entity);
export const Problem$isUndeclaredEntity = (value) =>
  value instanceof UndeclaredEntity;
export const Problem$UndeclaredEntity$entity = (value) => value.entity;
export const Problem$UndeclaredEntity$0 = (value) => value.entity;

/**
 * A document declaring `standalone="yes"` depends on markup
 * declarations from outside the document, which the standalone
 * declaration promises it does not.
 */
export class NotStandalone extends $CustomType {
  constructor(description) {
    super();
    this.description = description;
  }
}
export const Problem$NotStandalone = (description) =>
  new NotStandalone(description);
export const Problem$isNotStandalone = (value) =>
  value instanceof NotStandalone;
export const Problem$NotStandalone$description = (value) => value.description;
export const Problem$NotStandalone$0 = (value) => value.description;

/**
 * A markup declaration, content model group, or conditional section
 * opens in one parameter entity's replacement text and closes in
 * another (the Proper Declaration/Group/Conditional Section PE Nesting
 * validity constraints).
 */
export class ImproperPeNesting extends $CustomType {
  constructor(description) {
    super();
    this.description = description;
  }
}
export const Problem$ImproperPeNesting = (description) =>
  new ImproperPeNesting(description);
export const Problem$isImproperPeNesting = (value) =>
  value instanceof ImproperPeNesting;
export const Problem$ImproperPeNesting$description = (value) =>
  value.description;
export const Problem$ImproperPeNesting$0 = (value) => value.description;

/**
 * A problem in the DTD's own declarations, independent of the document:
 * duplicate names in mixed content or enumerations, an undeclared
 * notation, an ID attribute with a default, more than one ID attribute
 * on an element, or a default value that does not satisfy the
 * attribute's own type.
 */
export class InvalidDtdDeclaration extends $CustomType {
  constructor(element, description) {
    super();
    this.element = element;
    this.description = description;
  }
}
export const Problem$InvalidDtdDeclaration = (element, description) =>
  new InvalidDtdDeclaration(element, description);
export const Problem$isInvalidDtdDeclaration = (value) =>
  value instanceof InvalidDtdDeclaration;
export const Problem$InvalidDtdDeclaration$element = (value) => value.element;
export const Problem$InvalidDtdDeclaration$0 = (value) => value.element;
export const Problem$InvalidDtdDeclaration$description = (value) =>
  value.description;
export const Problem$InvalidDtdDeclaration$1 = (value) => value.description;

class State extends $CustomType {
  constructor(violations, ids, references) {
    super();
    this.violations = violations;
    this.ids = ids;
    this.references = references;
  }
}

function is_unparsed_entity(dtd, name) {
  let $ = $dict.get(dtd.entities, name);
  if ($ instanceof Ok) {
    let $1 = $[0];
    if ($1 instanceof $glexml.ExternalEntity) {
      let $2 = $1.notation;
      if ($2 instanceof Some) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

function tokens(value) {
  let _pipe = value;
  let _pipe$1 = $string.split(_pipe, " ");
  return $list.filter(_pipe$1, (token) => { return token !== ""; });
}

/**
 * Trim and collapse internal whitespace, the normalisation applied to
 * tokenized attribute types before checking them.
 * 
 * @ignore
 */
function collapse(value) {
  let _pipe = tokens(value);
  return $string.join(_pipe, " ");
}

function is_name_start_code(code) {
  return (((((code >= 97) && (code <= 122)) || ((code >= 65) && (code <= 90))) || (code === 95)) || (code === 58)) || (code > 127);
}

function is_name_code(code) {
  return ((is_name_start_code(code) || ((code >= 48) && (code <= 57))) || (code === 45)) || (code === 46);
}

function is_nmtoken(value) {
  let $ = $string.to_utf_codepoints(value);
  if ($ instanceof $Empty) {
    return false;
  } else {
    let codepoints = $;
    return $list.all(
      codepoints,
      (codepoint) => {
        return is_name_code($string.utf_codepoint_to_int(codepoint));
      },
    );
  }
}

function is_name(value) {
  let $ = $string.to_utf_codepoints(value);
  if ($ instanceof $Empty) {
    return false;
  } else {
    let first = $.head;
    let rest = $.tail;
    return is_name_start_code($string.utf_codepoint_to_int(first)) && $list.all(
      rest,
      (codepoint) => {
        return is_name_code($string.utf_codepoint_to_int(codepoint));
      },
    );
  }
}

function default_satisfies_kind(value, kind, dtd) {
  if (kind instanceof CdataAttribute) {
    return true;
  } else if (kind instanceof IdAttribute) {
    return true;
  } else if (kind instanceof IdRefAttribute) {
    return is_name(collapse(value));
  } else if (kind instanceof IdRefsAttribute) {
    return (!isEqual(tokens(value), toList([]))) && $list.all(
      tokens(value),
      is_name,
    );
  } else if (kind instanceof EntityAttribute) {
    return is_unparsed_entity(dtd, collapse(value));
  } else if (kind instanceof EntitiesAttribute) {
    return (!isEqual(tokens(value), toList([]))) && $list.all(
      tokens(value),
      (_capture) => { return is_unparsed_entity(dtd, _capture); },
    );
  } else if (kind instanceof NmtokenAttribute) {
    return is_nmtoken(collapse(value));
  } else if (kind instanceof NmtokensAttribute) {
    return (!isEqual(tokens(value), toList([]))) && $list.all(
      tokens(value),
      is_nmtoken,
    );
  } else if (kind instanceof NotationAttribute) {
    let allowed = kind.allowed;
    return $list.contains(allowed, collapse(value));
  } else {
    let allowed = kind.allowed;
    return $list.contains(allowed, collapse(value));
  }
}

function declaration_violation(element, description) {
  return new Violation(element, new InvalidDtdDeclaration(element, description));
}

function validate_attribute_declaration(element, declaration, dtd) {
  let named = (description) => {
    return declaration_violation(
      element,
      (("attribute \"" + declaration.name) + "\" ") + description,
    );
  };
  let _block;
  let $ = declaration.kind;
  let $1 = declaration.default;
  if ($1 instanceof Fixed && $ instanceof IdAttribute) {
    _block = toList([
      named("is an ID, so its default must be #IMPLIED or #REQUIRED"),
    ]);
  } else if ($1 instanceof Default && $ instanceof IdAttribute) {
    _block = toList([
      named("is an ID, so its default must be #IMPLIED or #REQUIRED"),
    ]);
  } else {
    _block = toList([]);
  }
  let id_rule = _block;
  let _block$1;
  let $2 = declaration.kind;
  if ($2 instanceof NotationAttribute) {
    let allowed = $2.allowed;
    let undeclared = $list.filter(
      allowed,
      (name) => { return !$list.contains(dtd.notations, name); },
    );
    let missing = $list.map(
      undeclared,
      (name) => {
        return named(("names the undeclared notation \"" + name) + "\"");
      },
    );
    let $3 = isEqual($list.unique(allowed), allowed);
    if ($3) {
      _block$1 = missing;
    } else {
      _block$1 = listPrepend(named("repeats a notation name"), missing);
    }
  } else if ($2 instanceof EnumeratedAttribute) {
    let allowed = $2.allowed;
    let $3 = isEqual($list.unique(allowed), allowed);
    if ($3) {
      _block$1 = toList([]);
    } else {
      _block$1 = toList([named("repeats an enumeration token")]);
    }
  } else {
    _block$1 = toList([]);
  }
  let tokens_rule = _block$1;
  let _block$2;
  let $3 = declaration.default;
  if ($3 instanceof Fixed) {
    let value = $3.value;
    let $4 = default_satisfies_kind(value, declaration.kind, dtd);
    if ($4) {
      _block$2 = toList([]);
    } else {
      _block$2 = toList([
        named("has a default value that does not match its type"),
      ]);
    }
  } else if ($3 instanceof Default) {
    let value = $3.value;
    let $4 = default_satisfies_kind(value, declaration.kind, dtd);
    if ($4) {
      _block$2 = toList([]);
    } else {
      _block$2 = toList([
        named("has a default value that does not match its type"),
      ]);
    }
  } else {
    _block$2 = toList([]);
  }
  let default_rule = _block$2;
  return $list.flatten(toList([id_rule, tokens_rule, default_rule]));
}

/**
 * Validity constraints on the DTD's own declarations.
 * 
 * @ignore
 */
function validate_declarations(dtd) {
  let _block;
  let _pipe = dtd.pe_nesting_violations;
  let _pipe$1 = $list.reverse(_pipe);
  _block = $list.map(
    _pipe$1,
    (description) => {
      return new Violation("(dtd)", new ImproperPeNesting(description));
    },
  );
  let nesting = _block;
  let _block$1;
  let _pipe$2 = dtd.duplicate_elements;
  let _pipe$3 = $list.unique(_pipe$2);
  _block$1 = $list.map(
    _pipe$3,
    (name) => {
      return declaration_violation(name, "element declared more than once");
    },
  );
  let duplicates = _block$1;
  let _block$2;
  let _pipe$4 = $dict.to_list(dtd.entities);
  _block$2 = $list.flat_map(
    _pipe$4,
    (pair) => {
      let $ = pair[1];
      if ($ instanceof $glexml.ExternalEntity) {
        let $1 = $.notation;
        if ($1 instanceof Some) {
          let notation = $1[0];
          let $2 = $list.contains(dtd.notations, notation);
          if ($2) {
            return toList([]);
          } else {
            return toList([
              declaration_violation(
                pair[0],
                ("the entity's notation \"" + notation) + "\" is not declared",
              ),
            ]);
          }
        } else {
          return toList([]);
        }
      } else {
        return toList([]);
      }
    },
  );
  let entity_notations = _block$2;
  let _block$3;
  let _pipe$5 = $dict.to_list(dtd.elements);
  _block$3 = $list.flat_map(
    _pipe$5,
    (pair) => {
      let $ = pair[1];
      if ($ instanceof MixedContent) {
        let allowed = $.allowed;
        let $1 = isEqual($list.unique(allowed), allowed);
        if ($1) {
          return toList([]);
        } else {
          return toList([
            declaration_violation(
              pair[0],
              "the same element may not be named twice in mixed content",
            ),
          ]);
        }
      } else {
        return toList([]);
      }
    },
  );
  let mixed = _block$3;
  let _block$4;
  let _pipe$6 = $dict.to_list(dtd.attribute_lists);
  _block$4 = $list.flat_map(
    _pipe$6,
    (pair) => {
      let element = pair[0];
      let declarations = pair[1];
      let ids = $list.filter(
        declarations,
        (d) => { return d.kind instanceof IdAttribute; },
      );
      let _block$5;
      if (ids instanceof $Empty) {
        _block$5 = toList([]);
      } else {
        let $ = ids.tail;
        if ($ instanceof $Empty) {
          _block$5 = toList([]);
        } else {
          _block$5 = toList([
            declaration_violation(
              element,
              "an element may declare only one ID attribute",
            ),
          ]);
        }
      }
      let multiple_ids = _block$5;
      return $list.append(
        multiple_ids,
        $list.flat_map(
          declarations,
          (declaration) => {
            return validate_attribute_declaration(element, declaration, dtd);
          },
        ),
      );
    },
  );
  let attributes = _block$4;
  return $list.flatten(
    toList([nesting, duplicates, entity_notations, mixed, attributes]),
  );
}

function add(state, path, problem) {
  return new State(
    listPrepend(new Violation(path, problem), state.violations),
    state.ids,
    state.references,
  );
}

/**
 * ENTITY and ENTITIES attributes must name declared unparsed entities:
 * external entities with an `NDATA` notation.
 * 
 * @ignore
 */
function validate_entity_tokens(
  element,
  attribute,
  value,
  names,
  path,
  dtd,
  state
) {
  return $list.fold(
    names,
    state,
    (state, name) => {
      let $ = $dict.get(dtd.entities, name);
      if ($ instanceof Ok) {
        let $1 = $[0];
        if ($1 instanceof ExternalEntity) {
          let $2 = $1.notation;
          if ($2 instanceof Some) {
            return state;
          } else {
            return add(
              state,
              path,
              new InvalidAttributeValue(
                element,
                attribute,
                value,
                "the name of a declared unparsed entity",
              ),
            );
          }
        } else {
          return add(
            state,
            path,
            new InvalidAttributeValue(
              element,
              attribute,
              value,
              "the name of a declared unparsed entity",
            ),
          );
        }
      } else {
        return add(
          state,
          path,
          new InvalidAttributeValue(
            element,
            attribute,
            value,
            "the name of a declared unparsed entity",
          ),
        );
      }
    },
  );
}

function validate_attribute_kind(
  element,
  attribute,
  value,
  kind,
  path,
  dtd,
  state
) {
  let invalid = (state, expected) => {
    return add(
      state,
      path,
      new InvalidAttributeValue(element, attribute, value, expected),
    );
  };
  if (kind instanceof CdataAttribute) {
    return state;
  } else if (kind instanceof IdAttribute) {
    let id = collapse(value);
    let $ = is_name(id);
    if ($) {
      let $1 = $set.contains(state.ids, id);
      if ($1) {
        return add(state, path, new DuplicateId(id));
      } else {
        return new State(
          state.violations,
          $set.insert(state.ids, id),
          state.references,
        );
      }
    } else {
      return invalid(state, "a single XML name");
    }
  } else if (kind instanceof IdRefAttribute) {
    let id = collapse(value);
    let $ = is_name(id);
    if ($) {
      return new State(
        state.violations,
        state.ids,
        listPrepend([path, id], state.references),
      );
    } else {
      return invalid(state, "a single XML name");
    }
  } else if (kind instanceof IdRefsAttribute) {
    let $ = tokens(value);
    if ($ instanceof $Empty) {
      return invalid(state, "one or more XML names");
    } else {
      let ids = $;
      return $list.fold(
        ids,
        state,
        (state, id) => {
          let $1 = is_name(id);
          if ($1) {
            return new State(
              state.violations,
              state.ids,
              listPrepend([path, id], state.references),
            );
          } else {
            return invalid(state, "XML names");
          }
        },
      );
    }
  } else if (kind instanceof EntityAttribute) {
    return validate_entity_tokens(
      element,
      attribute,
      value,
      toList([collapse(value)]),
      path,
      dtd,
      state,
    );
  } else if (kind instanceof EntitiesAttribute) {
    let $ = tokens(value);
    if ($ instanceof $Empty) {
      return invalid(state, "one or more unparsed entity names");
    } else {
      let names = $;
      return validate_entity_tokens(
        element,
        attribute,
        value,
        names,
        path,
        dtd,
        state,
      );
    }
  } else if (kind instanceof NmtokenAttribute) {
    let $ = is_nmtoken(collapse(value));
    if ($) {
      return state;
    } else {
      return invalid(state, "a name token");
    }
  } else if (kind instanceof NmtokensAttribute) {
    let $ = tokens(value);
    if ($ instanceof $Empty) {
      return invalid(state, "one or more name tokens");
    } else {
      let names = $;
      let $1 = $list.all(names, is_nmtoken);
      if ($1) {
        return state;
      } else {
        return invalid(state, "name tokens");
      }
    }
  } else if (kind instanceof NotationAttribute) {
    let allowed = kind.allowed;
    let name = collapse(value);
    let $ = $list.contains(allowed, name) && $list.contains(dtd.notations, name);
    if ($) {
      return state;
    } else {
      return invalid(
        state,
        "one of the declared notations " + $string.join(allowed, ", "),
      );
    }
  } else {
    let allowed = kind.allowed;
    let $ = $list.contains(allowed, collapse(value));
    if ($) {
      return state;
    } else {
      return invalid(state, "one of " + $string.join(allowed, ", "));
    }
  }
}

function validate_attribute_value(
  element,
  attribute,
  value,
  declaration,
  path,
  dtd,
  state
) {
  let _block;
  let $ = declaration.default;
  if ($ instanceof Fixed) {
    let expected = $.value;
    let $1 = value === expected;
    if ($1) {
      _block = state;
    } else {
      _block = add(
        state,
        path,
        new InvalidAttributeValue(
          element,
          attribute,
          value,
          ("the fixed value \"" + expected) + "\"",
        ),
      );
    }
  } else {
    _block = state;
  }
  let state$1 = _block;
  return validate_attribute_kind(
    element,
    attribute,
    value,
    declaration.kind,
    path,
    dtd,
    state$1,
  );
}

function validate_attributes(element, path, dtd, state) {
  let _block;
  let _pipe = $dict.get(dtd.attribute_lists, element.name);
  _block = $result.unwrap(_pipe, toList([]));
  let declarations = _block;
  let state$1 = $list.fold(
    element.attributes,
    state,
    (state, attribute) => {
      let name = attribute.name;
      let value = attribute.value;
      let $ = $list.find(declarations, (d) => { return d.name === name; });
      if ($ instanceof Ok) {
        let declaration = $[0];
        return validate_attribute_value(
          element.name,
          name,
          value,
          declaration,
          path,
          dtd,
          state,
        );
      } else {
        return add(state, path, new UndeclaredAttribute(element.name, name));
      }
    },
  );
  return $list.fold(
    declarations,
    state$1,
    (state, declaration) => {
      let $ = declaration.default;
      if ($ instanceof Required) {
        let $1 = $list.any(
          element.attributes,
          (a) => { return a.name === declaration.name; },
        );
        if ($1) {
          return state;
        } else {
          return add(
            state,
            path,
            new MissingRequiredAttribute(element.name, declaration.name),
          );
        }
      } else {
        return state;
      }
    },
  );
}

function occurrence_suffix(occurrence) {
  if (occurrence instanceof ExactlyOne) {
    return "";
  } else if (occurrence instanceof ZeroOrOne) {
    return "?";
  } else if (occurrence instanceof ZeroOrMore) {
    return "*";
  } else {
    return "+";
  }
}

function particle_to_string(particle) {
  if (particle instanceof NameParticle) {
    let name = particle.name;
    let occurrence = particle.occurrence;
    return name + occurrence_suffix(occurrence);
  } else if (particle instanceof Sequence) {
    let particles = particle.particles;
    let occurrence = particle.occurrence;
    return (("(" + $string.join($list.map(particles, particle_to_string), ", ")) + ")") + occurrence_suffix(
      occurrence,
    );
  } else {
    let particles = particle.particles;
    let occurrence = particle.occurrence;
    return (("(" + $string.join($list.map(particles, particle_to_string), " | ")) + ")") + occurrence_suffix(
      occurrence,
    );
  }
}

/**
 * Match the particle itself exactly once, ignoring its own occurrence
 * suffix.
 * 
 * @ignore
 */
function match_once(particle, names) {
  if (particle instanceof NameParticle) {
    let name = particle.name;
    if (names instanceof $Empty) {
      return names;
    } else {
      let first = names.head;
      let rest = names.tail;
      let $ = first === name;
      if ($) {
        return toList([rest]);
      } else {
        return toList([]);
      }
    }
  } else if (particle instanceof Sequence) {
    let particles = particle.particles;
    return $list.fold(
      particles,
      toList([names]),
      (frontier, item) => {
        let _pipe = $list.flat_map(
          frontier,
          (remaining) => { return match_particle(item, remaining); },
        );
        return $list.unique(_pipe);
      },
    );
  } else {
    let particles = particle.particles;
    let _pipe = $list.flat_map(
      particles,
      (option) => { return match_particle(option, names); },
    );
    return $list.unique(_pipe);
  }
}

/**
 * Keep matching the particle against every frontier remainder until no new
 * remainders appear.
 * 
 * @ignore
 */
function match_repeatedly(loop$particle, loop$frontier, loop$seen) {
  while (true) {
    let particle = loop$particle;
    let frontier = loop$frontier;
    let seen = loop$seen;
    let _block;
    let _pipe = $list.flat_map(
      frontier,
      (names) => { return match_once(particle, names); },
    );
    _block = $list.unique(_pipe);
    let next = _block;
    let new$ = $list.filter(
      next,
      (names) => { return !$list.contains(seen, names); },
    );
    if (new$ instanceof $Empty) {
      return seen;
    } else {
      loop$particle = particle;
      loop$frontier = new$;
      loop$seen = $list.append(seen, new$);
    }
  }
}

/**
 * Match a particle against a list of child element names, returning every
 * possible remainder. The children match the particle exactly when `[]` is
 * among the remainders.
 * 
 * @ignore
 */
function match_particle(particle, names) {
  let $ = particle.occurrence;
  if ($ instanceof ExactlyOne) {
    return match_once(particle, names);
  } else if ($ instanceof ZeroOrOne) {
    let _pipe = listPrepend(names, match_once(particle, names));
    return $list.unique(_pipe);
  } else if ($ instanceof ZeroOrMore) {
    return match_repeatedly(particle, toList([names]), toList([names]));
  } else {
    let _block;
    let _pipe = match_once(particle, names);
    _block = $list.unique(_pipe);
    let first = _block;
    return match_repeatedly(particle, first, first);
  }
}

/**
 * In element-only content, text is allowed only as separator whitespace:
 * it must be whitespace and it must be literal (not from a CDATA section
 * or a character reference recognised in content).
 * 
 * @ignore
 */
function has_significant_text(element) {
  return $list.any(
    element.children,
    (node) => {
      if (node instanceof TextNode) {
        let text = node.text;
        let literal = node.literal;
        return ($string.trim(text) !== "") || !literal;
      } else {
        return false;
      }
    },
  );
}

/**
 * Render a content model the way it would appear in an `<!ELEMENT>`
 * declaration, e.g. `(head, body)` or `(#PCDATA | em)*`.
 */
export function content_model_to_string(model) {
  if (model instanceof EmptyContent) {
    return "EMPTY";
  } else if (model instanceof AnyContent) {
    return "ANY";
  } else if (model instanceof MixedContent) {
    let $ = model.allowed;
    if ($ instanceof $Empty) {
      return "(#PCDATA)";
    } else {
      let allowed = $;
      return ("(#PCDATA | " + $string.join(allowed, " | ")) + ")*";
    }
  } else {
    let particle = model.particle;
    return particle_to_string(particle);
  }
}

function validate_content(element, path, dtd, state) {
  let $ = $dict.get(dtd.elements, element.name);
  if ($ instanceof Ok) {
    let $1 = $[0];
    if ($1 instanceof EmptyContent) {
      let $2 = element.children;
      if ($2 instanceof $Empty) {
        return state;
      } else {
        return add(state, path, new InvalidContent(element.name, "EMPTY"));
      }
    } else if ($1 instanceof AnyContent) {
      return state;
    } else if ($1 instanceof MixedContent) {
      let allowed = $1.allowed;
      let _block;
      let _pipe = $glexml.child_elements(element);
      _block = $list.filter(
        _pipe,
        (child) => { return !$list.contains(allowed, child.name); },
      );
      let stray = _block;
      if (stray instanceof $Empty) {
        return state;
      } else {
        return add(
          state,
          path,
          new InvalidContent(
            element.name,
            content_model_to_string(new MixedContent(allowed)),
          ),
        );
      }
    } else {
      let particle = $1.particle;
      let _block;
      let $2 = has_significant_text(element);
      if ($2) {
        _block = add(state, path, new TextNotAllowed(element.name));
      } else {
        _block = state;
      }
      let state$1 = _block;
      let _block$1;
      let _pipe = $glexml.child_elements(element);
      _block$1 = $list.map(_pipe, (child) => { return child.name; });
      let names = _block$1;
      let $3 = $list.contains(match_particle(particle, names), toList([]));
      if ($3) {
        return state$1;
      } else {
        return add(
          state$1,
          path,
          new InvalidContent(element.name, particle_to_string(particle)),
        );
      }
    }
  } else {
    return add(state, path, new UndeclaredElement(element.name));
  }
}

function validate_element(element, path, dtd, state) {
  let state$1 = validate_content(element, path, dtd, state);
  let state$2 = validate_attributes(element, path, dtd, state$1);
  let state$3 = $list.fold(
    element.children,
    state$2,
    (state, node) => {
      if (node instanceof $glexml.EntityReferenceNode) {
        let entity = node.entity;
        return add(state, path, new UndeclaredEntity(entity));
      } else {
        return state;
      }
    },
  );
  return $list.fold(
    $glexml.child_elements(element),
    state$3,
    (state, child) => {
      return validate_element(child, (path + "/") + child.name, dtd, state);
    },
  );
}

/**
 * Validate a document against a DTD, returning every violation found. An
 * empty list means the document is valid.
 *
 * The DTD is passed separately from the document so you can decide what to
 * validate against: the internal subset (`doctype.declarations`), a loaded
 * external DTD (`glexml.parse_dtd`), or both merged with
 * `glexml.merge_dtds`.
 */
export function validate(document, dtd) {
  let root = document.root;
  let state = new State(toList([]), $set.new$(), toList([]));
  let _block;
  let $ = document.doctype;
  if ($ instanceof Some) {
    let doctype = $[0];
    let $1 = doctype.root_name === root.name;
    if ($1) {
      _block = state;
    } else {
      _block = add(
        state,
        root.name,
        new RootElementMismatch(doctype.root_name, root.name),
      );
    }
  } else {
    _block = state;
  }
  let state$1 = _block;
  let state$2 = validate_element(root, root.name, dtd, state$1);
  let _block$1;
  let _pipe = state$2.references;
  let _pipe$1 = $list.reverse(_pipe);
  let _pipe$2 = $list.filter(
    _pipe$1,
    (reference) => { return !$set.contains(state$2.ids, reference[1]); },
  );
  _block$1 = $list.map(
    _pipe$2,
    (reference) => {
      return new Violation(reference[0], new UnknownIdReference(reference[1]));
    },
  );
  let unresolved = _block$1;
  return $list.flatten(
    toList([
      validate_declarations(dtd),
      $list.reverse(state$2.violations),
      unresolved,
    ]),
  );
}

/**
 * Render a violation as a human readable message.
 */
export function violation_to_string(violation) {
  let _block;
  let $ = violation.problem;
  if ($ instanceof RootElementMismatch) {
    let expected = $.expected;
    let found = $.found;
    _block = ((("the root element is <" + found) + "> but the DOCTYPE names \"") + expected) + "\"";
  } else if ($ instanceof UndeclaredElement) {
    let element = $.element;
    _block = ("element <" + element) + "> is not declared";
  } else if ($ instanceof InvalidContent) {
    let element = $.element;
    let model = $.model;
    _block = (("the content of <" + element) + "> does not match ") + model;
  } else if ($ instanceof TextNotAllowed) {
    let element = $.element;
    _block = ("element <" + element) + "> may not contain text";
  } else if ($ instanceof UndeclaredAttribute) {
    let element = $.element;
    let attribute = $.attribute;
    _block = ((("attribute \"" + attribute) + "\" is not declared on <") + element) + ">";
  } else if ($ instanceof MissingRequiredAttribute) {
    let element = $.element;
    let attribute = $.attribute;
    _block = ((("element <" + element) + "> is missing the required attribute \"") + attribute) + "\"";
  } else if ($ instanceof InvalidAttributeValue) {
    let element = $.element;
    let attribute = $.attribute;
    let value = $.value;
    let expected = $.expected;
    _block = (((((("the value \"" + value) + "\" of attribute \"") + attribute) + "\" on <") + element) + "> is not valid: expected ") + expected;
  } else if ($ instanceof DuplicateId) {
    let id = $.id;
    _block = ("the ID \"" + id) + "\" is used more than once";
  } else if ($ instanceof UnknownIdReference) {
    let id = $.id;
    _block = ("no element has the ID \"" + id) + "\"";
  } else if ($ instanceof UndeclaredEntity) {
    let entity = $.entity;
    _block = ("the entity \"&" + entity) + ";\" is not declared";
  } else if ($ instanceof NotStandalone) {
    let description = $.description;
    _block = "the document says standalone=\"yes\" but " + description;
  } else if ($ instanceof ImproperPeNesting) {
    let description = $.description;
    _block = description;
  } else {
    let element = $.element;
    let description = $.description;
    _block = (("in the declarations for <" + element) + ">: ") + description;
  }
  let message = _block;
  return ((message + " (at ") + violation.path) + ")";
}

function element_with_defaults(element, dtd) {
  let _block;
  let _pipe = $dict.get(dtd.attribute_lists, element.name);
  _block = $result.unwrap(_pipe, toList([]));
  let declarations = _block;
  let missing = $list.filter_map(
    declarations,
    (declaration) => {
      let $ = declaration.default;
      if ($ instanceof Fixed) {
        let value = $.value;
        let $1 = $list.any(
          element.attributes,
          (a) => { return a.name === declaration.name; },
        );
        if ($1) {
          return new Error(undefined);
        } else {
          return new Ok(new Attribute(declaration.name, value));
        }
      } else if ($ instanceof Default) {
        let value = $.value;
        let $1 = $list.any(
          element.attributes,
          (a) => { return a.name === declaration.name; },
        );
        if ($1) {
          return new Error(undefined);
        } else {
          return new Ok(new Attribute(declaration.name, value));
        }
      } else {
        return new Error(undefined);
      }
    },
  );
  let children = $list.map(
    element.children,
    (node) => {
      if (node instanceof ElementNode) {
        let child = node[0];
        return new ElementNode(element_with_defaults(child, dtd));
      } else {
        return node;
      }
    },
  );
  return new Element(
    element.name,
    $list.append(element.attributes, missing),
    children,
  );
}

/**
 * Return a copy of the document with attribute defaults from the DTD
 * filled in: any attribute declared with a default or `#FIXED` value that
 * is absent from an element is added, as a validating XML processor would.
 */
export function with_default_attributes(document, dtd) {
  return new Document(
    document.version,
    document.encoding,
    document.standalone,
    document.doctype,
    document.prolog,
    element_with_defaults(document.root, dtd),
    document.epilogue,
  );
}

function standalone_check(element, path, internal, external, violations) {
  let _block;
  let _pipe = $dict.get(external.attribute_lists, element.name);
  let _pipe$1 = $result.unwrap(_pipe, toList([]));
  _block = $list.filter(
    _pipe$1,
    (declaration) => {
      let _block$1;
      let _pipe$2 = $dict.get(internal.attribute_lists, element.name);
      _block$1 = $result.unwrap(_pipe$2, toList([]));
      let internal_declarations = _block$1;
      return !$list.any(
        internal_declarations,
        (d) => { return d.name === declaration.name; },
      );
    },
  );
  let external_attributes = _block;
  let violations$1 = $list.fold(
    external_attributes,
    violations,
    (violations, declaration) => {
      let specified = $list.any(
        element.attributes,
        (a) => { return a.name === declaration.name; },
      );
      let $ = declaration.default;
      if (!specified) {
        if ($ instanceof $glexml.Fixed) {
          return listPrepend(
            new Violation(
              path,
              new NotStandalone(
                ((("the attribute \"" + declaration.name) + "\" on <") + element.name) + "> takes its default from an external declaration",
              ),
            ),
            violations,
          );
        } else if ($ instanceof $glexml.Default) {
          return listPrepend(
            new Violation(
              path,
              new NotStandalone(
                ((("the attribute \"" + declaration.name) + "\" on <") + element.name) + "> takes its default from an external declaration",
              ),
            ),
            violations,
          );
        } else {
          return violations;
        }
      } else {
        return violations;
      }
    },
  );
  let violations$2 = $list.fold(
    element.attributes,
    violations$1,
    (violations, attribute) => {
      let $ = $list.find(
        external_attributes,
        (d) => { return d.name === attribute.name; },
      );
      if ($ instanceof Ok) {
        let declaration = $[0];
        let $1 = (!(declaration.kind instanceof $glexml.CdataAttribute)) && (collapse(
          attribute.value,
        ) !== attribute.value);
        if ($1) {
          return listPrepend(
            new Violation(
              path,
              new NotStandalone(
                (((("the value of attribute \"" + attribute.name) + "\" on <") + element.name) + "> is changed by the normalisation its external ") + "declaration requires",
              ),
            ),
            violations,
          );
        } else {
          return violations;
        }
      } else {
        return violations;
      }
    },
  );
  let externally_declared_model = !$dict.has_key(
    internal.elements,
    element.name,
  ) && (() => {
    let $ = $dict.get(external.elements, element.name);
    if ($ instanceof Ok) {
      let $1 = $[0];
      if ($1 instanceof ElementContent) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  })();
  let has_whitespace_content = $list.any(
    element.children,
    (node) => {
      if (node instanceof TextNode) {
        let text = node.text;
        return ($string.trim(text) === "") && (text !== "");
      } else {
        return false;
      }
    },
  );
  let _block$1;
  let $ = externally_declared_model && has_whitespace_content;
  if ($) {
    _block$1 = listPrepend(
      new Violation(
        path,
        new NotStandalone(
          ("whitespace occurs in the content of <" + element.name) + ">, whose element content model is declared externally",
        ),
      ),
      violations$2,
    );
  } else {
    _block$1 = violations$2;
  }
  let violations$3 = _block$1;
  return $list.fold(
    $glexml.child_elements(element),
    violations$3,
    (violations, child) => {
      return standalone_check(
        child,
        (path + "/") + child.name,
        internal,
        external,
        violations,
      );
    },
  );
}

/**
 * Check the Standalone Document Declaration validity constraint: a
 * document declaring `standalone="yes"` may not depend on markup
 * declarations made outside it. Pass the external declarations (an
 * external subset loaded with `glexml.parse_dtd`, and any external
 * parameter entities); declarations also made in the document's own
 * internal subset do not count as external.
 *
 * Violations are reported when the document is standalone and, per
 * section 2.9 of the specification: an element lacks an attribute whose
 * default value is declared externally; a specified attribute value
 * would be changed by the normalisation its externally declared type
 * requires; or whitespace occurs directly in the content of an element
 * whose element-only content model is declared externally.
 */
export function standalone_violations(document, external) {
  let $ = document.standalone;
  if ($) {
    let _block;
    let $1 = document.doctype;
    if ($1 instanceof Some) {
      let doctype = $1[0];
      _block = doctype.declarations;
    } else {
      _block = $glexml.empty_dtd();
    }
    let internal = _block;
    let _pipe = standalone_check(
      document.root,
      document.root.name,
      internal,
      external,
      toList([]),
    );
    return $list.reverse(_pipe);
  } else {
    return toList([]);
  }
}
