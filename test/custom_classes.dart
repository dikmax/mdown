library mdown.test.custom_classes;

import 'package:mdown/options.dart';

import 'data/test_data.dart';
import 'parser.dart';

/// Tests for TeX custom classes.
void customClassesTests() {
  tests(
      'Tex math custom classes',
      texMathCustomClasses,
      generateTestFunc(const Options(
          texMathDollars: true,
          inlineTexMathClasses: <String>['custom_inline'],
          displayTexMathClasses: <String>['custom_display'])));
}
