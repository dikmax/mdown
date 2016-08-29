library md_proc.test.custom_classes;

import 'package:md_proc/options.dart';
import 'parser.dart';
import 'data/test_data.dart';

/// Tests for TeX custom classes.
void customClassesTests() {
  tests(
      "Tex math custom classes",
      texMathCustomClasses,
      mdToHtmlTest(new Options(
          texMathDollars: true,
          inlineTexMathClasses: <String>['custom_inline'],
          displayTexMathClasses: <String>['custom_display'])));
}
