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

/// Simple lookup for blockquote.
class BlockquoteSimpleLookup extends Lookup {
  /// Constant constructor.
  const BlockquoteSimpleLookup();

  @override
  bool isFound(String text, int offset) {
    return text.codeUnitAt(offset) == greaterThanCodeUnit;
  }
}

const Lookup blockquoteSimpleLookup = const BlockquoteSimpleLookup();

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

const Lookup thematicBreakLookup = const ThematicBreakLookup();

final Lookup atxHeadingLookup =
    new Lookup.regExp(new RegExp('(#{1,6})(?:[ \t]|\$)'));
final Lookup fencedCodeStartLookup =
    new Lookup.regExp(new RegExp('(?:(`{3,})([^`]*)|(~{3,})([^~]*))\$'));

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

const Lookup htmlBlock1Lookup = const HtmlBlock1Lookup();

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

const Lookup htmlBlock2Lookup = const HtmlBlock2Lookup();

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

const Lookup htmlBlock3Lookup = const HtmlBlock3Lookup();

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

const Lookup htmlBlock4Lookup = const HtmlBlock4Lookup();

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

const Lookup htmlBlock5Lookup = const HtmlBlock5Lookup();
