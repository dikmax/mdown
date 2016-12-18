library md_proc.test.custom_classes;

import 'package:mdown/options.dart';
import 'parser.dart';
import 'data/test_data.dart';

/// Tests for TeX custom classes.
void customClassesTests() {
  tests(
      "Tex math custom classes",
      texMathCustomClasses,
      generateTestFunc(const Options(
          texMathDollars: true,
          inlineTexMathClasses: const <String>['custom_inline'],
          displayTexMathClasses: const <String>['custom_display'])));
}
