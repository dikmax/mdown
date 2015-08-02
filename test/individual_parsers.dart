library individualParsersTest;

import 'package:test/test.dart';
import 'package:parsers/parsers.dart';

import 'package:md_proc/md_proc.dart';

_rest(parseResult) => parseResult.text.substring(parseResult.position.offset);

class FailureMatcher extends Matcher {
  String rest;

  FailureMatcher(this.rest);

  bool matches(ParseResult parseResult, Map matchState) {
    return !parseResult.isSuccess
        && _rest(parseResult) == rest;
  }

  Description describe(Description description) =>
      description.add('a parse failure with rest "$rest"');
}

class SuccessMatcher extends Matcher {
  final Object res;
  final String rest;

  SuccessMatcher(this.res, this.rest);

  bool matches(ParseResult parseResult, Map matchState) {
    return parseResult.isSuccess
        && equals(parseResult.value).matches(res, matchState)
        && parseResult.text.substring(parseResult.position.offset) == rest;
  }

  Description describe(Description description) =>
      description.add('a parse success with value $res and rest "$rest"');
}

isFailure(rest) => new FailureMatcher(rest);

isSuccess(res, rest) => new SuccessMatcher(res, rest);


var tabStopPosition = const TabStopPosition(0, 1, 1, tabStop: 4);

void individualParsersTests() {
  group('atMostIndent', () {
    var atMostIndent = CommonMarkParser.atMostIndent(3);
    test('should succeed without consuming any input.', () {
      expect(atMostIndent.run("asdf", tabStopPosition), isSuccess(0, 'asdf'));
    });
    test('should succeed with max consumed spaces.', () {
      expect(atMostIndent.run(" asdf", tabStopPosition), isSuccess(1, 'asdf'));
      expect(atMostIndent.run("  asdf", tabStopPosition), isSuccess(2, 'asdf'));
      expect(atMostIndent.run("   asdf", tabStopPosition), isSuccess(3, 'asdf'));
    });
    test('should not take more than allowed.', () {
      expect(atMostIndent.run("    asdf", tabStopPosition), isSuccess(3, ' asdf'));
      expect(atMostIndent.run("\tasdf", tabStopPosition), isSuccess(0, '\tasdf'));
    });
  });

  group('count', () {
    var count = CommonMarkParser.count(3, digit);
    test('should take exact count', () {
      expect(count.run('555', tabStopPosition), isSuccess(["5", "5", "5"], ''));
    });
    test('should fail if less', () {
      expect(count.run('55.', tabStopPosition), isFailure('55.'));
    });
    test('shouldn\'t take exceeded', () {
      expect(count.run('55555', tabStopPosition), isSuccess(["5", "5", "5"], '55'));
    });
  });

  group('countBetween', () {
    var countBeetween1 = CommonMarkParser.countBetween(2, 3, digit);
    var countBeetween2 = CommonMarkParser.countBetween(0, 3, digit);
    test('should take defined count', () {
      expect(countBeetween1.run('55', tabStopPosition), isSuccess(["5", "5"], ''));
      expect(countBeetween1.run('555', tabStopPosition), isSuccess(["5", "5", "5"], ''));
    });
    test('should fail if less', () {
      expect(countBeetween1.run('5.', tabStopPosition), isFailure('5.'));
    });
    test('should take maximum if there\'s more', () {
      expect(countBeetween1.run('55555', tabStopPosition), isSuccess(["5", "5", "5"], '55'));
    });
    test('should succeed empty if 0 allowed', () {
      expect(countBeetween2.run('asdf', tabStopPosition), isSuccess([], 'asdf'));
    });
  });
}