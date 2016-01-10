library md_proc.test.data.test_data;

import 'package:md_proc/generators/embed_tests.dart';

part 'test_data.g.dart';

@EmbedTests('spec.txt')
final Map<String, String> specification = _$specificationTests;

@EmbedTests('smart_punct.txt')
final Map<String, String> smartPunctuation = _$smartPunctuationTests;

@EmbedTests('markdownToMarkdown.txt')
final Map<String, String> markdownToMarkdown = _$markdownToMarkdownTests;

@EmbedTests('additionalMarkdownToHtml.txt')
final Map<String, String> additionalMarkdownToHtml =
    _$additionalMarkdownToHtmlTests;

@EmbedTests('strikeout.txt')
final Map<String, String> strikeout = _$strikeoutTests;

@EmbedTests('strikeout_and_subscript.txt')
final Map<String, String> strikeoutAndSubscript = _$strikeoutAndSubscriptTests;

@EmbedTests('subscript.txt')
final Map<String, String> subscript = _$subscriptTests;

@EmbedTests('superscript.txt')
final Map<String, String> superscript = _$superscriptTests;

@EmbedTests('tex_math_dollars.txt')
final Map<String, String> texMathDollars = _$texMathDollarsTests;

@EmbedTests('tex_math_single_backslash.txt')
final Map<String, String> texMathSingleBackslash =
    _$texMathSingleBackslashTests;

@EmbedTests('tex_math_double_backslash.txt')
final Map<String, String> texMathDoubleBackslash =
    _$texMathDoubleBackslashTests;

@EmbedTests('tex_math_custom_classes.txt')
final Map<String, String> texMathCustomClasses = _$texMathCustomClassesTests;

@EmbedTests('raw_tex.txt')
final Map<String, String> rawTex  = _$rawTexTests;
