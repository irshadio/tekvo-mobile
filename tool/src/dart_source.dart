/// Lexing helpers shared by the source checkers.
library;

final RegExp _quoted = RegExp('''['"]([^'"]*)['"]''');
final RegExp _condition = RegExp(r'\bif\s*\([^)]*\)');

/// [source] with comments replaced by spaces and, when [strings] is set,
/// string-literal contents too. Length and line breaks are preserved, so
/// offsets match the original.
String maskDart(String source, {bool strings = false}) {
  final out = StringBuffer();
  var i = 0;
  void keep(int end) {
    out.write(source.substring(i, end));
    i = end;
  }

  void blank(int end) {
    out.write(source.substring(i, end).replaceAll(RegExp(r'[^\n]'), ' '));
    i = end;
  }

  bool at(String token) => source.startsWith(token, i);

  while (i < source.length) {
    if (at('//')) {
      final end = source.indexOf('\n', i);
      blank(end == -1 ? source.length : end);
    } else if (at('/*')) {
      var depth = 0;
      var j = i;
      while (j < source.length) {
        if (source.startsWith('/*', j)) {
          depth++;
          j += 2;
        } else if (source.startsWith('*/', j)) {
          depth--;
          j += 2;
          if (depth == 0) break;
        } else {
          j++;
        }
      }
      blank(j);
    } else if (at("'") || at('"')) {
      final end = _stringEnd(source, i);
      if (strings) {
        final quote = source[i];
        final width = source.startsWith(quote * 3, i) ? 3 : 1;
        keep(i + width);
        blank(end - width > i ? end - width : i);
        keep(end);
      } else {
        keep(end);
      }
    } else {
      keep(i + 1);
    }
  }
  return out.toString();
}

/// Index just past the string literal whose opening quote is at [start].
int _stringEnd(String source, int start) {
  final quote = source[start];
  final triple = source.startsWith(quote * 3, start);
  final close = triple ? quote * 3 : quote;
  final raw =
      start > 0 &&
      source[start - 1] == 'r' &&
      (start < 2 || !RegExp(r'\w').hasMatch(source[start - 2]));
  var j = start + close.length;
  while (j < source.length) {
    if (!raw && source[j] == r'\') {
      j += 2;
    } else if (!raw && source.startsWith(r'${', j)) {
      j = _interpolationEnd(source, j + 2);
    } else if (source.startsWith(close, j)) {
      return j + close.length;
    } else if (!triple && source[j] == '\n') {
      return j;
    } else {
      j++;
    }
  }
  return source.length;
}

/// Index just past the `}` closing an interpolation whose body starts at
/// [start]. Nested strings are skipped whole, so their braces do not count.
int _interpolationEnd(String source, int start) {
  var depth = 1;
  var j = start;
  while (j < source.length) {
    final char = source[j];
    if (char == "'" || char == '"') {
      j = _stringEnd(source, j);
      continue;
    }
    if (source.startsWith('//', j)) {
      final end = source.indexOf('\n', j);
      j = end == -1 ? source.length : end;
      continue;
    }
    if (source.startsWith('/*', j)) {
      final end = source.indexOf('*/', j + 2);
      j = end == -1 ? source.length : end + 2;
      continue;
    }
    if (char == '{') depth++;
    if (char == '}' && --depth == 0) return j + 1;
    j++;
  }
  return source.length;
}

/// The URIs of one directive [body]: the main URI and each conditional one,
/// with adjacent string pieces joined as the analyzer joins them.
List<String> directiveUris(String body) {
  final uris = <String>[];
  for (final segment in body.split(_condition)) {
    final pieces = _quoted.allMatches(segment).map((m) => m.group(1)!);
    if (pieces.isNotEmpty) uris.add(pieces.join());
  }
  return uris;
}
