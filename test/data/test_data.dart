library md_proc.test.data.test_data;

import 'package:md_proc/generators/embed_tests.dart';

part 'test_data.g.dart';

/// Specification tests
@EmbedTests('spec.txt')
final Map<String, String> specification = _$specificationTests;

/// Smart punctuation tests
@EmbedTests('smart_punct.txt')
final Map<String, String> smartPunctuation = _$smartPunctuationTests;

/// commonmark.js regression tests
@EmbedTests('regression.txt')
final Map<String, String> regression = _$regressionTests;

/// Additional md->md tests
@EmbedTests('markdownToMarkdown.txt')
final Map<String, String> markdownToMarkdown = _$markdownToMarkdownTests;

/// Additional md->html tests
@EmbedTests('additionalMarkdownToHtml.txt')
final Map<String, String> additionalMarkdownToHtml =
    _$additionalMarkdownToHtmlTests;

/// Strikeout extension tests
@EmbedTests('fenced_code_attributes.txt')
final Map<String, String> fencedCodeAttributes = _$fencedCodeAttributesTests;

/// Strikeout extension tests
@EmbedTests('heading_attributes.txt')
final Map<String, String> headingAttributes = _$headingAttributesTests;

/// Strikeout extension tests
@EmbedTests('inline_code_attributes.txt')
final Map<String, String> inlineCodeAttributes = _$inlineCodeAttributesTests;

/// Strikeout extension tests
@EmbedTests('strikeout.txt')
final Map<String, String> strikeout = _$strikeoutTests;

/// Strikeout and subscript extensions tests
@EmbedTests('strikeout_and_subscript.txt')
final Map<String, String> strikeoutAndSubscript = _$strikeoutAndSubscriptTests;

/// Subscript extension tests
@EmbedTests('subscript.txt')
final Map<String, String> subscript = _$subscriptTests;

/// Superscript extension tests
@EmbedTests('superscript.txt')
final Map<String, String> superscript = _$superscriptTests;

/// tex_math_dollars extension tests
@EmbedTests('tex_math_dollars.txt')
final Map<String, String> texMathDollars = _$texMathDollarsTests;

/// tex_math_single_backslash extension tests
@EmbedTests('tex_math_single_backslash.txt')
final Map<String, String> texMathSingleBackslash =
    _$texMathSingleBackslashTests;

/// tex_math_double_backslash extension tests
@EmbedTests('tex_math_double_backslash.txt')
final Map<String, String> texMathDoubleBackslash =
    _$texMathDoubleBackslashTests;

/// Tests for TeX custom classes
@EmbedTests('tex_math_custom_classes.txt')
final Map<String, String> texMathCustomClasses = _$texMathCustomClassesTests;

/// Tests for raw TeX.
@EmbedTests('raw_tex.txt')
final Map<String, String> rawTex = _$rawTexTests;
