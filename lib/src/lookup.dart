library mdown.src.lookup;

import 'package:mdown/src/code_units.dart';

abstract class Lookup {
  const Lookup();

  factory Lookup.regExp(Pattern pattern) => new PatternLookup(pattern);

  bool isFound(String text, int offset);
}

class PatternLookup extends Lookup {
  final Pattern _pattern;

  PatternLookup(this._pattern);

  @override
  bool isFound(String text, int offset) =>
      _pattern.matchAsPrefix(text, offset) != null;
}

final Lookup atxHeadingLookup =
    new Lookup.regExp(new RegExp('(#{1,6})(?:[ \t]|\$)'));
final Lookup blockquoteSimpleLookup = new Lookup.regExp('>');
final Lookup fencedCodeStartLookup =
    new Lookup.regExp(new RegExp('(?:(`{3,})([^`]*)|(~{3,})([^~]*))\$'));
final Lookup thematicBreakLookup = new Lookup.regExp(
    new RegExp('((?:\\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\$'));

/*
final Lookup htmlBlock1Lookup = new Lookup.regExp(
    new RegExp(r'<(?:script|pre|style)(?:\s|>|$)', caseSensitive: false));
*/
final Lookup htmlBlock5Lookup = new Lookup.regExp('<!\[CDATA\[');
final Lookup htmlBlock6Lookup = new Lookup.regExp(new RegExp(
  r'</?([a-zA-Z1-6]+)(?:\s|/?>|$)',
));

/// Lookup for HTML block type 1: <(?:script|pre|style)(?:\s|>|$)
class HtmlBlock1Lookup extends Lookup {
  const HtmlBlock1Lookup();

  @override
  bool isFound(String text, int offset) {
    int length = text.length;

    if (offset + 4 > length || text.codeUnitAt(offset) != lessThanCodeUnit) {
      // Check for minimal length `<pre`
      return false;
    }

    offset += 1;

    int codeUnit = text.codeUnitAt(offset);
    if (codeUnit == smallPCharCode || codeUnit == bigPCharCode) {
      // Could be <pre
      codeUnit = text.codeUnitAt(offset + 1);
      if (codeUnit != smallRCharCode && codeUnit != bigRCharCode) {
        return false;
      }
      codeUnit = text.codeUnitAt(offset + 2);
      if (codeUnit != smallECharCode && codeUnit != bigECharCode) {
        return false;
      }
      offset = offset + 3;
    } else if (codeUnit == smallSCharCode || codeUnit == bigSCharCode) {
      // Could be <script or <style
      codeUnit = text.codeUnitAt(offset + 1);
      if (codeUnit == smallCCharCode || codeUnit == bigCCharCode) {
        // Could be <script
        if (offset + 6 > length) {
          return false;
        }
        codeUnit = text.codeUnitAt(offset + 2);
        if (codeUnit != smallRCharCode && codeUnit != bigRCharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(offset + 3);
        if (codeUnit != smallICharCode && codeUnit != bigICharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(offset + 4);
        if (codeUnit != smallPCharCode && codeUnit != bigPCharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(offset + 5);
        if (codeUnit != smallTCharCode && codeUnit != bigTCharCode) {
          return false;
        }
        offset = offset + 6;
      } else if (codeUnit == smallTCharCode || codeUnit == bigTCharCode) {
        // Could be <style
        if (offset + 5 > length) {
          return false;
        }
        codeUnit = text.codeUnitAt(offset + 2);
        if (codeUnit != smallYCharCode && codeUnit != bigYCharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(offset + 3);
        if (codeUnit != smallLCharCode && codeUnit != bigLCharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(offset + 4);
        if (codeUnit != smallECharCode && codeUnit != bigECharCode) {
          return false;
        }
        offset = offset + 5;
      } else {
        return false;
      }
    } else {
      // No possible starts found
      return false;
    }

    if (offset == length) {
      return true;
    }

    codeUnit = text.codeUnitAt(offset);

    return codeUnit == greaterThanCodeUnit ||
        codeUnit == spaceCodeUnit ||
        codeUnit == tabCodeUnit ||
        codeUnit == newLineCodeUnit ||
        codeUnit == carriageReturnCodeUnit;
  }
}

/// Lookup for HTML block type 2: <!--
class HtmlBlock2Lookup extends Lookup {
  const HtmlBlock2Lookup();

  @override
  bool isFound(String text, int offset) {
    if (offset + 4 >= text.length) {
      return false;
    }

    return text.codeUnitAt(offset) == lessThanCodeUnit &&
        text.codeUnitAt(offset + 1) == exclamationMarkCodeUnit &&
        text.codeUnitAt(offset + 2) == minusCodeUnit &&
        text.codeUnitAt(offset + 3) == minusCodeUnit;
  }
}

/// Lookup for HTML block type 3: <?
class HtmlBlock3Lookup extends Lookup {
  const HtmlBlock3Lookup();

  @override
  bool isFound(String text, int offset) {
    if (offset + 2 >= text.length) {
      return false;
    }

    return text.codeUnitAt(offset) == lessThanCodeUnit &&
        text.codeUnitAt(offset + 1) == questionMarkCodeUnit;
  }
}

/// Lookup for HTML block type 4: <!
class HtmlBlock4Lookup extends Lookup {
  const HtmlBlock4Lookup();

  @override
  bool isFound(String text, int offset) {
    if (offset + 2 >= text.length) {
      return false;
    }

    return text.codeUnitAt(offset) == lessThanCodeUnit &&
        text.codeUnitAt(offset + 1) == exclamationMarkCodeUnit;
  }
}
