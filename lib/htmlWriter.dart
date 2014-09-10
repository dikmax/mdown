library markdown.htmlWriter;

import 'markdown.dart';
import 'dart:convert';

// TODO(floitsch) - Document - Issue 13097
const HtmlEscape HTML_ESCAPE = const HtmlEscape();

class HtmlEscapeMode {
  final String _name;
  final bool escapeLtGt;
  final bool escapeQuot;
  final bool escapeApos;
  final bool escapeSlash;

  // TODO(floitsch) - Document - Issue 13097
  static const HtmlEscapeMode UNKNOWN =
  const HtmlEscapeMode._('unknown', true, true, true, false);

  // TODO(floitsch) - Document - Issue 13097
  static const HtmlEscapeMode ATTRIBUTE =
  const HtmlEscapeMode._('attribute', false, true, false, false);

  // TODO(floitsch) - Document - Issue 13097
  static const HtmlEscapeMode ELEMENT =
  const HtmlEscapeMode._('element', true, false, false, true);

  // TODO(floitsch) - Document - Issue 13097
  const HtmlEscapeMode._(this._name, this.escapeLtGt, this.escapeQuot,
                         this.escapeApos, this.escapeSlash);

  String toString() => _name;
}

// TODO(floitsch) - Document - Issue 13097
class HtmlEscape extends Converter<String, String> {

  // TODO(floitsch) - Document - Issue 13097
  final HtmlEscapeMode mode;

  // TODO(floitsch) - Document - Issue 13097
  const HtmlEscape([this.mode = HtmlEscapeMode.UNKNOWN]);

  String convert(String text) {
    var val = _convert(text, 0, text.length);
    return val == null ? text : val;
  }

  String _convert(String text, int start, int end) {
    StringBuffer result = null;
    for (int i = start; i < end; i++) {
      var ch = text[i];
      String replace = null;
      switch (ch) {
        case '&': replace = '&amp;'; break;
        case '\u00A0'/*NO-BREAK SPACE*/: replace = '&nbsp;'; break;
        case '"': if (mode.escapeQuot) replace = '&quot;'; break;
        case "'": if (mode.escapeApos) replace = '&#x27;'; break;
        case '<': if (mode.escapeLtGt) replace = '&lt;'; break;
        case '>': if (mode.escapeLtGt) replace = '&gt;'; break;
        case '/': if (mode.escapeSlash) replace = '&#x2F;'; break;
      }
      if (replace != null) {
        if (result == null) result = new StringBuffer(text.substring(start, i));
        result.write(replace);
      } else if (result != null) {
        result.write(ch);
      }
    }

    return result != null ? result.toString() : null;
  }

  StringConversionSink startChunkedConversion(Sink<String> sink) {
    if (sink is! StringConversionSink) {
      sink = new StringConversionSink.from(sink);
    }
    return new _HtmlEscapeSink(this, sink);
  }
}

class _HtmlEscapeSink extends StringConversionSinkBase {
  final HtmlEscape _escape;
  final StringConversionSink _sink;

  _HtmlEscapeSink(this._escape, this._sink);

  void addSlice(String chunk, int start, int end, bool isLast) {
    var val = _escape._convert(chunk, start, end);
    if(val == null) {
      _sink.addSlice(chunk, start, end, isLast);
    } else {
      _sink.add(val);
      if (isLast) _sink.close();
    }
  }

  void close() => _sink.close();
}

String write(Document document) => writeBlocks(document.contents);

String writeAttributes(Attr attr) {
  if (attr is EmptyAttr) {
    return '';
  } else if (attr is InfoString) {
    if (attr.language == "") {
      return '';
    }
    return ' class="language-${attr.language}"';
  }
  throw new UnimplementedError(attr.toString());
}

// Blocks
String writeBlocks(Iterable<Block> blocks) => blocks.map((Block block) {
  if (block is HorizontalRule) {
    return '<hr/>';
  } else if (block is Header) {
    return writeHeader(block);
  } else if (block is CodeBlock) {
    return writeCodeBlock(block);
  } else if (block is RawBlock) {
    return block.contents;
  } else if (block is Para) {
    return writePara(block);
  }
  throw new UnimplementedError(block.toString());
}).join('\n');

String writeHeader(Header header) => "<h${header.level}>${writeInlines(header.contents)}</h${header.level}>";

String writeCodeBlock(CodeBlock codeBlock) => "<pre><code${writeAttributes(codeBlock.attributes)}>" +
  "${codeBlock.contents}</code></pre>";

String writePara(Para para) => "<p>${writeInlines(para.contents)}</p>";

// Inlines
String writeInlines(Iterable<Inline> inlines) {
  // TODO remove raw check
  if (inlines.raw != null) {
    return HTML_ESCAPE.convert(inlines.raw);
  }
  return inlines.map((Inline inline) {
    if (inline is Str) {
      return inline.contents;
    } else if (inline is Space) {
      return ' ';
    } else if (inline is NonBreakableSpace) {
      return '&nbsp;';
    } else if (inline is LineBreak) {
      return '<br/>';
    }
    throw new UnimplementedError(inline.toString());
  }).join();
}
