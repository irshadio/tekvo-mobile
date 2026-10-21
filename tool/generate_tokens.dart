import 'dart:convert';
import 'dart:io';

/// Generates the core theme tokens from packages/core/tokens/tekvo_tokens.json
/// (exported from Figma with tool/figma/export_tokens.js).
///
///     dart run tool/generate_tokens.dart          # write the files
///     dart run tool/generate_tokens.dart --check  # fail if they are stale
const _source = 'packages/core/tokens/tekvo_tokens.json';
const _outDir = 'packages/core/lib/theme';
const _header =
    '// GENERATED CODE - DO NOT MODIFY BY HAND.\n'
    '// Source: $_source. Regenerate with `melos run tokens`.\n\n';

void main(List<String> args) {
  final check = args.contains('--check');
  final tokens =
      jsonDecode(File(_source).readAsStringSync()) as Map<String, dynamic>;
  final dimension = _map(tokens['dimension']);
  final files = <String, String>{
    'app_palette.dart': _palette(_map(tokens['palette'])),
    'app_color_schemes.dart': _schemes(tokens),
    'app_colors.dart': _colors(tokens),
    'app_spacing.dart': _spacing(dimension),
    'app_sizes.dart': _sizes(dimension),
    'app_motion.dart': _motion(dimension),
    'app_shadows.dart': _shadows(_map(tokens['elevation'])),
    'app_type_scale.dart': _typeScale(_map(tokens['typography'])),
  };

  final temp = Directory.systemTemp.createTempSync('tekvo_tokens');
  try {
    for (final entry in files.entries) {
      File('${temp.path}/${entry.key}').writeAsStringSync(entry.value);
    }
    final format = Process.runSync('dart', ['format', temp.path]);
    if (format.exitCode != 0) {
      stderr.writeln(format.stderr);
      exit(1);
    }
    final stale = <String>[];
    for (final name in files.keys) {
      final generated = File('${temp.path}/$name').readAsStringSync();
      final target = File('$_outDir/$name');
      final current = target.existsSync() ? target.readAsStringSync() : null;
      if (current == generated) continue;
      stale.add(name);
      if (!check) {
        target
          ..createSync(recursive: true)
          ..writeAsStringSync(generated);
      }
    }
    if (check && stale.isNotEmpty) {
      stderr.writeln(
        'Design tokens are out of date (${stale.join(', ')}). '
        'Run `melos run tokens`.',
      );
      exitCode = 1;
      return;
    }
    stdout.writeln(
      check
          ? 'OK: design tokens are up to date.'
          : 'Wrote ${stale.length} token file(s) to $_outDir.',
    );
  } finally {
    temp.deleteSync(recursive: true);
  }
}

Map<String, dynamic> _map(Object? value) => value! as Map<String, dynamic>;

String _camel(String path) {
  final parts = path.split(RegExp('[/ ]')).where((p) => p.isNotEmpty).toList();
  return [
    parts.first[0].toLowerCase() + parts.first.substring(1),
    for (final p in parts.skip(1)) p[0].toUpperCase() + p.substring(1),
  ].join();
}

String _capital(String s) => s[0].toUpperCase() + s.substring(1);

String _color(String hex) => 'Color(0x${hex.substring(1).toUpperCase()})';

String _number(Object? value) {
  final d = (value! as num).toDouble();
  return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toString();
}

/// Values of the `<group>/<name>` dimension tokens.
Map<String, Object?> _dimensionGroup(Map<String, dynamic> d, String group) => {
  for (final e in d.entries)
    if (e.key.startsWith('$group/')) e.key.substring(group.length + 1): e.value,
};

String _palette(Map<String, dynamic> palette) {
  final b = StringBuffer(_header)
    ..writeln("import 'dart:ui';\n")
    ..writeln('/// The primitive palette. Screens use colour roles, not these.')
    ..writeln('abstract final class AppPalette {');
  palette.forEach((name, hex) {
    b.writeln(
      '  static const Color ${_camel(name)} = ${_color(hex as String)};',
    );
  });
  b.writeln('}');
  return b.toString();
}

String _role(Object? value) {
  final v = value! as String;
  return v.startsWith('@') ? 'AppPalette.${_camel(v.substring(1))}' : _color(v);
}

Map<String, String> _group(Map<String, dynamic> roles, String prefix) => {
  for (final e in roles.entries)
    if (e.key.startsWith('$prefix/'))
      e.key.substring(prefix.length + 1): _role(e.value),
};

String _schemes(Map<String, dynamic> tokens) {
  final b = StringBuffer(_header)
    ..writeln("import 'package:core/theme/app_palette.dart';")
    ..writeln("import 'package:flutter/material.dart';\n");
  for (final mode in ['light', 'dark']) {
    b
      ..writeln('/// The Material colour roles of the $mode theme.')
      ..writeln(
        'const ColorScheme app${_capital(mode)}ColorScheme = ColorScheme(',
      )
      ..writeln('  brightness: Brightness.$mode,');
    _group(
      _map(tokens[mode]),
      'scheme',
    ).forEach((n, v) => b.writeln('  $n: $v,'));
    b.writeln(');\n');
  }
  return b.toString();
}

const _roleGroups = ['status', 'commerce', 'rider', 'map'];

String _colors(Map<String, dynamic> tokens) {
  Map<String, String> roles(String mode) => {
    for (final g in _roleGroups)
      for (final e in _group(_map(tokens[mode]), g).entries)
        _camel('$g/${e.key}'): e.value,
  };
  final light = roles('light');
  final dark = roles('dark');
  final names = light.keys.toList();
  final b = StringBuffer(_header)
    ..writeln("import 'package:core/theme/app_palette.dart';")
    ..writeln("import 'package:flutter/material.dart';\n")
    ..writeln('/// Colour roles outside the Material scheme (status, commerce,')
    ..writeln('/// rider, map) in a light and a dark set. Read with')
    ..writeln('/// `context.appColors`.')
    ..writeln('@immutable')
    ..writeln('class AppColors extends ThemeExtension<AppColors> {')
    ..writeln('  const AppColors({');
  for (final n in names) {
    b.writeln('    required this.$n,');
  }
  b.writeln('  });\n');
  for (final mode in ['light', 'dark']) {
    final values = mode == 'light' ? light : dark;
    b.writeln('  static const AppColors $mode = AppColors(');
    for (final n in names) {
      b.writeln('    $n: ${values[n]},');
    }
    b.writeln('  );\n');
  }
  for (final n in names) {
    b.writeln('  final Color $n;');
  }
  b.writeln('\n  @override\n  AppColors copyWith({');
  for (final n in names) {
    b.writeln('    Color? $n,');
  }
  b.writeln('  }) => AppColors(');
  for (final n in names) {
    b.writeln('    $n: $n ?? this.$n,');
  }
  b
    ..writeln('  );\n')
    ..writeln('  @override')
    ..writeln('  AppColors lerp(AppColors? other, double t) {')
    ..writeln('    if (other == null) return this;')
    ..writeln('    return AppColors(');
  for (final n in names) {
    b.writeln('      $n: Color.lerp($n, other.$n, t)!,');
  }
  b.writeln('    );\n  }\n}');
  return b.toString();
}

/// Spacing names shared with the reference scale; other steps keep their
/// Figma value in the name.
const _spacingNames = {
  '0': 'none',
  '2': 'xxs',
  '4': 'xs',
  '8': 'sm',
  '12': 'md',
  '16': 'lg',
  '24': 'xl',
  '32': 'xxl',
};

void _constants(
  StringBuffer b,
  String className,
  String doc,
  Map<String, Object?> values,
  String Function(String) name,
) {
  b
    ..writeln('/// $doc')
    ..writeln('abstract final class $className {');
  values.forEach((key, value) {
    b.writeln('  static const double ${name(key)} = ${_number(value)};');
  });
  b.writeln('}\n');
}

String _spacing(Map<String, dynamic> d) {
  final b = StringBuffer(_header);
  _constants(
    b,
    'AppSpacing',
    'Spacing scale; use these instead of magic numbers.',
    _dimensionGroup(d, 'space'),
    (k) => _spacingNames[k] ?? 's$k',
  );
  _constants(
    b,
    'AppRadius',
    'Corner radii.',
    _dimensionGroup(d, 'radius'),
    (k) => k == 'full' ? 'pill' : k,
  );
  return b.toString();
}

String _sizes(Map<String, dynamic> d) {
  final b = StringBuffer(_header);
  _constants(
    b,
    'AppSizes',
    'Icon, control, avatar and touch-target sizes.',
    _dimensionGroup(d, 'size'),
    _camel,
  );
  _constants(
    b,
    'AppBorders',
    'Stroke widths.',
    _dimensionGroup(d, 'border'),
    (k) => k,
  );
  _constants(
    b,
    'AppOpacity',
    'State-layer and disabled opacities.',
    _dimensionGroup(d, 'opacity'),
    (k) => k,
  );
  _constants(
    b,
    'AppElevation',
    'Material elevation levels.',
    _dimensionGroup(d, 'elevation'),
    (k) => 'level$k',
  );
  return b.toString();
}

String _motion(Map<String, dynamic> d) {
  final b = StringBuffer(_header)
    ..writeln('/// Shared animation durations.')
    ..writeln('abstract final class AppMotion {');
  _dimensionGroup(d, 'duration').forEach((name, value) {
    final ms = _number(value);
    b.writeln(
      ms == '0'
          ? '  static const Duration $name = Duration.zero;'
          : '  static const Duration $name = Duration(milliseconds: $ms);',
    );
  });
  b.writeln('}');
  return b.toString();
}

String _shadows(Map<String, dynamic> elevation) {
  final b = StringBuffer(_header)
    ..writeln("import 'package:flutter/painting.dart';\n")
    ..writeln('/// Drop shadows of the Figma `DS/Elevation` effect styles.')
    ..writeln('abstract final class AppShadows {');
  elevation.forEach((level, value) {
    b.writeln('  static const List<BoxShadow> level$level = <BoxShadow>[');
    for (final s in value as List<dynamic>) {
      final shadow = _map(s);
      final spread = shadow['spread']! as num;
      // Figma's blur is twice the Gaussian sigma; Flutter's blurRadius maps
      // to sigma as 0.57735 * radius + 0.5.
      final sigma = (shadow['blur']! as num) / 2;
      final blur = sigma <= 0.5
          ? 0
          : ((sigma - 0.5) / 0.57735 * 100).round() / 100;
      b.writeln(
        '    BoxShadow(color: ${_color(shadow['color']! as String)}, '
        'offset: Offset(${shadow['x']}, ${shadow['y']}), '
        'blurRadius: $blur'
        '${spread == 0 ? '' : ', spreadRadius: $spread'}),',
      );
    }
    b.writeln('  ];');
  });
  b.writeln('}');
  return b.toString();
}

String _typeScale(Map<String, dynamic> typography) {
  final b = StringBuffer(_header)
    ..writeln("import 'package:core/theme/app_text_token.dart';\n")
    ..writeln('/// The Figma `DS/*` text styles, in design pixels.')
    ..writeln('abstract final class AppTypeScale {');
  typography.forEach((name, value) {
    final t = _map(value);
    b.writeln(
      '  static const AppTextToken ${_camel(name)} = AppTextToken( '
      "family: '${t['family']}', weight: ${t['weight']}, size: ${t['size']}, "
      'lineHeight: ${t['lineHeight']}, tracking: ${t['tracking']});',
    );
  });
  b.writeln('}');
  return b.toString();
}
