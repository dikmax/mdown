library mdown.test.data.test_data;

import 'dart:convert';

import 'package:mdown/generators/embed_tests.dart';
import 'package:mdown/generators/embed_blns_tests.dart';

// TODO move one folder up.

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

/// Additional tests
@EmbedTests('additional.txt')
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
@EmbedTests('link_attributes.txt')
final Map<String, String> linkAttributes = _$linkAttributesTests;

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

/// Tests for tables.
@EmbedTests('pipe_tables.txt')
final Map<String, String> pipeTables = _$pipeTablesTests;

/// Big list of naughty strings
@EmbedBlnsTests('blns.base64.json',
    'https://raw.githubusercontent.com/minimaxir/big-list-of-naughty-strings/master/blns.base64.json')
final Iterable<String> blns = _$blnsTests
    .map((String str) => UTF8.decode(BASE64.decode(str), allowMalformed: true));
