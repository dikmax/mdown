library mdown.src.lookup;

import 'package:mdown/src/code_units.dart';

/// Lookup class to check if some pattern appears on defined offset in string.
abstract class Lookup {
  /// Constructor
  const Lookup();

  /// Constructs lookup class from RegExp.
  factory Lookup.regExp(Pattern pattern) => PatternLookup(pattern);

  /// Abstract method, that returns true, when pattern is found on offset.
  bool isFound(String text, int offset);
}

/// RegExp lookup.
class PatternLookup extends Lookup {
  /// Constructs lookup with [_pattern].
  PatternLookup(this._pattern);

  final Pattern _pattern;

  @override
  bool isFound(String text, int offset) =>
      _pattern.matchAsPrefix(text, offset) != null;
}

/// Simple lookup for blockquote.
class BlockquoteSimpleLookup extends Lookup {
  /// Constant constructor.
  const BlockquoteSimpleLookup();

  @override
  bool isFound(String text, int offset) =>
      text.codeUnitAt(offset) == greaterThanCodeUnit;
}

/// Instance of [BlockquoteSimpleLookup].
const Lookup blockquoteSimpleLookup = BlockquoteSimpleLookup();

/// Simple lookup for thematic break.
class ThematicBreakLookup extends Lookup {
  /// Constant constructor.
  const ThematicBreakLookup();

  @override
  bool isFound(String text, int offset) {
    int off = offset;
    final int mainCodeUnit = text.codeUnitAt(off);
    if (mainCodeUnit != starCodeUnit &&
        mainCodeUnit != minusCodeUnit &&
        mainCodeUnit != underscoreCodeUnit) {
      return false;
    }

    final int length = text.length;
    off += 1;
    int count = 1;

    while (off < length) {
      final int codeUnit = text.codeUnitAt(off);

      if (codeUnit == mainCodeUnit) {
        ++count;
      } else if (codeUnit == carriageReturnCodeUnit ||
          codeUnit == newLineCodeUnit) {
        break;
      } else if (codeUnit != spaceCodeUnit && codeUnit != tabCodeUnit) {
        return false;
      }

      off += 1;
    }

    return count >= 3;
  }
}

/// Instance of [ThematicBreakLookup].
const Lookup thematicBreakLookup = ThematicBreakLookup();

/// Lookup for atx heading.
final Lookup atxHeadingLookup = Lookup.regExp(RegExp('(#{1,6})(?:[ \t]|\$)'));

/// Lookup for fenced code start.
final Lookup fencedCodeStartLookup =
    Lookup.regExp(RegExp('(?:(`{3,})([^`]*)|(~{3,})([^~]*))\$'));

/// Lookup for HTML block type 1: <(?:script|pre|style)(?:\s|>|$)
class HtmlBlock1Lookup extends Lookup {
  /// Constant constructor
  const HtmlBlock1Lookup();

  @override
  bool isFound(String text, int offset) {
    int off = offset;
    final int length = text.length;

    if (off + 4 > length || text.codeUnitAt(off) != lessThanCodeUnit) {
      // Check for minimal length `<pre`
      return false;
    }

    off += 1;

    int codeUnit = text.codeUnitAt(off);
    if (codeUnit == smallPCharCode || codeUnit == bigPCharCode) {
      // Could be <pre
      codeUnit = text.codeUnitAt(off + 1);
      if (codeUnit != smallRCharCode && codeUnit != bigRCharCode) {
        return false;
      }
      codeUnit = text.codeUnitAt(off + 2);
      if (codeUnit != smallECharCode && codeUnit != bigECharCode) {
        return false;
      }
      off = off + 3;
    } else if (codeUnit == smallSCharCode || codeUnit == bigSCharCode) {
      // Could be <script or <style
      codeUnit = text.codeUnitAt(off + 1);
      if (codeUnit == smallCCharCode || codeUnit == bigCCharCode) {
        // Could be <script
        if (off + 6 > length) {
          return false;
        }
        codeUnit = text.codeUnitAt(off + 2);
        if (codeUnit != smallRCharCode && codeUnit != bigRCharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(off + 3);
        if (codeUnit != smallICharCode && codeUnit != bigICharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(off + 4);
        if (codeUnit != smallPCharCode && codeUnit != bigPCharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(off + 5);
        if (codeUnit != smallTCharCode && codeUnit != bigTCharCode) {
          return false;
        }
        off = off + 6;
      } else if (codeUnit == smallTCharCode || codeUnit == bigTCharCode) {
        // Could be <style
        if (off + 5 > length) {
          return false;
        }
        codeUnit = text.codeUnitAt(off + 2);
        if (codeUnit != smallYCharCode && codeUnit != bigYCharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(off + 3);
        if (codeUnit != smallLCharCode && codeUnit != bigLCharCode) {
          return false;
        }
        codeUnit = text.codeUnitAt(off + 4);
        if (codeUnit != smallECharCode && codeUnit != bigECharCode) {
          return false;
        }
        off = off + 5;
      } else {
        return false;
      }
    } else {
      // No possible starts found
      return false;
    }

    if (off == length) {
      return true;
    }

    codeUnit = text.codeUnitAt(off);

    return codeUnit == greaterThanCodeUnit ||
        codeUnit == spaceCodeUnit ||
        codeUnit == tabCodeUnit ||
        codeUnit == newLineCodeUnit ||
        codeUnit == carriageReturnCodeUnit;
  }
}

/// Instance of [HtmlBlock1Lookup].
const Lookup htmlBlock1Lookup = HtmlBlock1Lookup();

/// Lookup for HTML block type 2: <!--
class HtmlBlock2Lookup extends Lookup {
  /// Constant constructor
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

/// Instance of [HtmlBlock2Lookup].
const Lookup htmlBlock2Lookup = HtmlBlock2Lookup();

/// Lookup for HTML block type 3: <?
class HtmlBlock3Lookup extends Lookup {
  /// Const constructor.
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

/// Instance of [HtmlBlock3Lookup].
const Lookup htmlBlock3Lookup = HtmlBlock3Lookup();

/// Lookup for HTML block type 4: <!
class HtmlBlock4Lookup extends Lookup {
  /// Constant constructor
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

/// Instance of [HtmlBlock4Lookup].
const Lookup htmlBlock4Lookup = HtmlBlock4Lookup();

/// Lookup for HTML block type 5: `<![CDATA[`
class HtmlBlock5Lookup extends Lookup {
  /// Constant constructor
  const HtmlBlock5Lookup();

  @override
  bool isFound(String text, int offset) {
    if (offset + 9 >= text.length) {
      return false;
    }

    return text.codeUnitAt(offset) == lessThanCodeUnit &&
        text.codeUnitAt(offset + 1) == exclamationMarkCodeUnit &&
        text.codeUnitAt(offset + 2) == openBracketCodeUnit &&
        text.codeUnitAt(offset + 3) == bigCCharCode &&
        text.codeUnitAt(offset + 4) == bigDCharCode &&
        text.codeUnitAt(offset + 5) == bigACharCode &&
        text.codeUnitAt(offset + 6) == bigTCharCode &&
        text.codeUnitAt(offset + 7) == bigACharCode &&
        text.codeUnitAt(offset + 8) == openBracketCodeUnit;
  }
}

/// Instance of [HtmlBlock5Lookup].
const Lookup htmlBlock5Lookup = HtmlBlock5Lookup();
