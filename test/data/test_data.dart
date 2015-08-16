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
final Map<String, String> additionalMarkdownToHtml = _$additionalMarkdownToHtmlTests;

@EmbedTests('strikeout.txt')
final Map<String, String> strikeout = _$strikeoutTests;

@EmbedTests('subscript.txt')
final Map<String, String> subscript = _$subscriptTests;

@EmbedTests('superscript.txt')
final Map<String, String> superscript = _$superscriptTests;
