library mdown.src.ast.enums;

import 'package:mdown/ast/ast.dart';
import 'package:mdown/src/code_units.dart';

String alignmentToStyleString(Alignment alignment) {
  switch (alignment) {
    case Alignment.left:
      return ' style="text-align: left;"';
    case Alignment.center:
      return ' style="text-align: center;"';
    case Alignment.right:
      return ' style="text-align: right;"';
    default:
      return '';
  }
}

BulletType bulletTypeFromCodeUnit(int codeUnit) {
  if (codeUnit == minusCodeUnit) {
    return BulletType.minus;
  }
  if (codeUnit == plusCodeUnit) {
    return BulletType.plus;
  }
  if (codeUnit == starCodeUnit) {
    return BulletType.star;
  }

  return null;
}

String bulletTypeToChar(BulletType type) {
  switch (type) {
    case BulletType.minus:
      return '-';

    case BulletType.plus:
      return '+';

    case BulletType.star:
      return '*';
  }

  return null;
}

EmphasisDelimiterType emphasisDelimiterTypeFromCodeUnit(int codeUnit) {
  if (codeUnit == starCodeUnit) {
    return EmphasisDelimiterType.star;
  }
  if (codeUnit == underscoreCodeUnit) {
    return EmphasisDelimiterType.underscore;
  }

  return null;
}

String emphasisDelimiterTypeToChar(EmphasisDelimiterType delimiterType) {
  switch (delimiterType) {
    case EmphasisDelimiterType.star:
      return '*';

    case EmphasisDelimiterType.underscore:
      return '_';
  }

  return null;
}

FencedCodeBlockType fencedCodeBlockTypeFromCodeUnit(int codeUnit) {
  if (codeUnit == backtickCodeUnit) {
    return FencedCodeBlockType.backtick;
  }
  if (codeUnit == tildeCodeUnit) {
    return FencedCodeBlockType.tilde;
  }

  return null;
}

String fencedCodeBlockTypeToChar(FencedCodeBlockType type) {
  switch (type) {
    case FencedCodeBlockType.backtick:
      return '`';

    case FencedCodeBlockType.tilde:
      return '~';
  }

  return null;
}

IndexSeparator indexSeparatorFromCodeUnit(int codeUnit) {
  if (codeUnit == dotCodeUnit) {
    return IndexSeparator.dot;
  }
  if (codeUnit == closeParenCodeUnit) {
    return IndexSeparator.parenthesis;
  }

  return null;
}

String indexSeparatorToChar(IndexSeparator separator) {
  switch (separator) {
    case IndexSeparator.dot:
      return '.';

    case IndexSeparator.parenthesis:
      return ')';
  }

  return null;
}

ThematicBreakType thematicBreakTypeFromCodeUnit(int codeUnit) {
  if (codeUnit == minusCodeUnit) {
    return ThematicBreakType.minus;
  }
  if (codeUnit == starCodeUnit) {
    return ThematicBreakType.star;
  }
  if (codeUnit == underscoreCodeUnit) {
    return ThematicBreakType.underscore;
  }

  return null;
}

String thematicBreakTypeToChar(ThematicBreakType type) {
  switch (type) {
    case ThematicBreakType.minus:
      return '-';
    case ThematicBreakType.star:
      return '*';
    case ThematicBreakType.underscore:
      return '_';
  }

  return null;
}
