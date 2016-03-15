library md_proc.test.individual_parsers;

import 'package:test/test.dart';
import 'package:parsers/parsers.dart';

import 'package:md_proc/md_proc.dart';

String _rest(ParseResult<dynamic> parseResult) =>
    parseResult.text.substring(parseResult.position.offset);

/// Matcher for unsuccessful parsing results
class FailureMatcher extends Matcher {
  /// String rest
  String rest;

  /// Constructor.
  FailureMatcher(this.rest);

  @override
  bool matches(ParseResult<dynamic> parseResult, Map<String, dynamic> matchState) {
    return !parseResult.isSuccess && _rest(parseResult) == rest;
  }

  @override
  Description describe(Description description) =>
      description.add('a parse failure with rest "$rest"');
}

/// Matcher for successful parsing results
class SuccessMatcher extends Matcher {
  /// Result to compare
  final Object res;

  /// String rest
  final String rest;

  /// Constructor.
  SuccessMatcher(this.res, this.rest);

  @override
  bool matches(ParseResult<dynamic> parseResult, Map<String, dynamic> matchState) {
    return parseResult.isSuccess &&
        equals(parseResult.value).matches(res, matchState) &&
        parseResult.text.substring(parseResult.position.offset) == rest;
  }

  @override
  Description describe(Description description) =>
      description.add('a parse success with value $res and rest "$rest"');
}

/// Matches unsuccessful parsing result
Matcher isFailure(String rest) => new FailureMatcher(rest);

/// Matches successful parsing result
Matcher isSuccess(Object res, String rest) => new SuccessMatcher(res, rest);

Position _tabStopPosition = const Position(0, 1, 1, tabStop: 4);

/// Test for some individual parsers helpers
void individualParsersTests() {
  group('atMostIndent', () {
    Parser<int> atMostIndent = CommonMarkParser.atMostIndent(3);
    test('should succeed without consuming any input.', () {
      expect(atMostIndent.run("asdf", _tabStopPosition), isSuccess(0, 'asdf'));
    });
    test('should succeed with max consumed spaces.', () {
      expect(atMostIndent.run(" asdf", _tabStopPosition), isSuccess(1, 'asdf'));
      expect(
          atMostIndent.run("  asdf", _tabStopPosition), isSuccess(2, 'asdf'));
      expect(
          atMostIndent.run("   asdf", _tabStopPosition), isSuccess(3, 'asdf'));
    });
    test('should not take more than allowed.', () {
      expect(atMostIndent.run("    asdf", _tabStopPosition),
          isSuccess(3, ' asdf'));
      expect(
          atMostIndent.run("\tasdf", _tabStopPosition), isSuccess(0, '\tasdf'));
    });
  });

  group('count', () {
    Parser<List<dynamic>> count = CommonMarkParser.count(3, digit);
    test('should take exact count', () {
      expect(
          count.run('555', _tabStopPosition), isSuccess(["5", "5", "5"], ''));
    });
    test('should fail if less', () {
      expect(count.run('55.', _tabStopPosition), isFailure('55.'));
    });
    test('shouldn\'t take exceeded', () {
      expect(count.run('55555', _tabStopPosition),
          isSuccess(["5", "5", "5"], '55'));
    });
  });

  group('countBetween', () {
    Parser<List<dynamic>> countBeetween1 =
        CommonMarkParser.countBetween(2, 3, digit);
    Parser<List<dynamic>> countBeetween2 =
        CommonMarkParser.countBetween(0, 3, digit);
    test('should take defined count', () {
      expect(countBeetween1.run('55', _tabStopPosition),
          isSuccess(["5", "5"], ''));
      expect(countBeetween1.run('555', _tabStopPosition),
          isSuccess(["5", "5", "5"], ''));
    });
    test('should fail if less', () {
      expect(countBeetween1.run('5.', _tabStopPosition), isFailure('5.'));
    });
    test('should take maximum if there\'s more', () {
      expect(countBeetween1.run('55555', _tabStopPosition),
          isSuccess(["5", "5", "5"], '55'));
    });
    test('should succeed empty if 0 allowed', () {
      expect(
          countBeetween2.run('asdf', _tabStopPosition), isSuccess([], 'asdf'));
    });
  });
}
